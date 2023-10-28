{
  description = "Andromeda Neoim Config Flake";

  outputs = inputs @ {
    self,
    fup,
    nixpkgs,
    ...
  }: let
    core-inputs = inputs // {src = ./.;};
    lib = import ./andromeda-lib core-inputs;

    inherit (lib.nvim.plugins) rawPlugins;

    #***********
    #* BUIILD
    #***********
    neovimConfiguration = {modules ? [], ...} @ args:
      import ./modules
      (args
        // {
          inherit lib;
          modules = [{config.build.rawPlugins = rawPlugins;}] ++ modules;
        });

    nvimBin = pkg: "${pkg}/bin/nvim";
    buildPkg = pkgs: modules: (neovimConfiguration {
      inherit pkgs modules;
    });

    #***********
    #* CONFIG
    #***********
    mainConfig = import ./config.nix {inherit lib;};
    nixConfig = mainConfig false;
    maximalConfig = mainConfig true;
  in
    fup.lib.mkFlake {
      inherit self inputs lib;
      channelsConfig.allowUnfree = true;

      ###########
      # OVERLAYS
      ###########
      sharedOverlays = with inputs; [
        neovim-nightly-overlay.overlay
      ];

      # Overlays to apply on a selected channel.
      channels.nixpkgs.overlaysBuilder = _channels: [
        (_final: prev: {
          inherit neovimConfiguration;
          neovim-nix = buildPkg prev [nixConfig];
          neovim-maximal = buildPkg prev [maximalConfig];
        })
      ];

      ##########
      # Outputs
      ##########
      outputsBuilder = channels: let
        nixPkg = buildPkg channels.nixpkgs [nixConfig];
        maximalPkg = buildPkg channels.nixpkgs [maximalConfig];
        devPkg = nixPkg.extendConfiguration {
          modules = [
            {
              vim.syntaxHighlighting = false;
              vim.languages.bash.enable = true;
              # vim.languages.html.enable = true;
              vim.filetree.nvimTreeLua.enable = true;
              vim.languages.nix.format.type = "alejandra";
            }
          ];
        };
      in
        # Core Outputs
        {
          apps = rec {
            default = nix;

            nix = {
              type = "app";
              program = nvimBin nixPkg;
            };

            maximal = {
              type = "app";
              program = nvimBin maximalPkg;
            };
          };

          defaultPackage = nixPkg;
          packages = {
            nix = nixPkg;
            maximal = maximalPkg;
          };
        }
        // {
          # Dev Outputs
          formatter = channels.nixpkgs.alejandra;
          devShells.default = channels.nixpkgs.mkShell {nativeBuildInputs = [devPkg];};
          checks.pre-commit-check = inputs.pre-commit-hooks.lib.${channels.nixpkgs.system}.run {
            src = ./.;
            hooks = {
              alejandra.enable = true;
              deadnix.enable = true;
              gptcommit.enable = true;
              nil.enable = true;
              prettier.enable = true;
              statix.enable = true;
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
