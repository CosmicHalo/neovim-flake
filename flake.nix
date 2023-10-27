{
  description = "A very basic flake";

  outputs = inputs @ {
    self,
    fu,
    fup,
    nixpkgs,
    ...
  }: let
    core-inputs =
      inputs
      // {
        src = ./.;
      };

    internalLib = import ./andromeda-lib core-inputs;

    extendedLib = import ./lib/stdlib-extended.nix nixpkgs.lib;
    nvimLib = extendedLib.nvim;

    rawPlugins = nvimLib.plugins.pluginsFromInputs inputs;
    neovimConfiguration = {modules ? [], ...} @ args:
      import ./modules
      (args
        // {
          inherit extendedLib;
          modules = [{config.build.rawPlugins = rawPlugins;}] ++ modules;
        });

    nvimBin = pkg: "${pkg}/bin/nvim";
    buildPkg = pkgs: modules: (neovimConfiguration {inherit pkgs modules;});

    mainConfig = import ./config.nix {lib = nixpkgs.lib;};
    nixConfig = mainConfig false;
  in
    fup.lib.mkFlake {
      inherit self inputs internalLib;

      channelsConfig.allowUnfree = true;

      ###########
      # OVERLAYS
      ###########
      sharedOverlays = with inputs; [
        neovim-nightly-overlay.overlay
      ];

      # Overlays to apply on a selected channel.
      channels."nixpkgs".overlaysBuilder = channels: [
        (final: prev: {
          inherit neovimConfiguration;
          neovim-nix = buildPkg prev [nixConfig];
        })
      ];

      ##########
      # Outputs
      ##########
      outputsBuilder = channels: let
        nixPkg = buildPkg channels.nixpkgs [nixConfig];
        devPkg = nixPkg.extendConfiguration {
          modules = [
            {
              vim.syntaxHighlighting = false;
              # vim.languages.bash.enable = true;
              # vim.languages.html.enable = true;
              # vim.filetree.nvimTreeLua.enable = false;
              # vim.languages.nix.format.type = "nixpkgs-fmt";
            }
          ];
        };
      in
        # Core Outputs
        {
          lib = {
            nvim = nvimLib;
            inherit neovimConfiguration;
          };

          apps = rec {
            default = nix;
            nix = {
              type = "app";
              program = nvimBin nixPkg;
            };
          };

          packages = {
            nix = nixPkg;
            default = nixPkg;
          };
        }
        # Dev Outputs
        // {
          formatter = channels.nixpkgs.alejandra;
          devShell = channels.nixpkgs.mkShell {nativeBuildInputs = [devPkg];};
          checks.pre-commit-check = inputs.pre-commit-hooks.lib.${channels.nixpkgs.system}.run {
            src = ./.;
            hooks = {
              alejandra.enable = true;
            };
          };
        };
    };

  #**********
  #* CORE
  #**********
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-23.05";

    # Andromeda
    andromeda = {
      url = "git+file:///home/n16hth4wk/dev/nixos/lib";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    fup = {
      url = "github:milkyway-org/flake-utils-plus";
      inputs.flake-utils.follows = "fu";
    };

    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  #*************
  #* HELPERS
  #*************
  inputs = {
    nil = {
      url = "github:oxalica/nil";
      inputs.flake-utils.follows = "fu";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  #************
  #* PLUGINS
  #************
  inputs = {
    # Plenary (required by crates-nvim)
    plugin-plenary-nvim.url = "github:nvim-lua/plenary.nvim";
    plugin-plenary-nvim.flake = false;
  };

  #***********************
  #* DEVONLY INPUTS
  #***********************
  inputs = {
    # Flake
    fu.url = "github:numtide/flake-utils";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };

    # Easy linting of the flake
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs = {
        flake-utils.follows = "fu";
        nixpkgs.follows = "nixpkgs";
        flake-compat.follows = "flake-compat";
        nixpkgs-stable.follows = "nixpkgs-stable";
      };
    };
  };
}
