{
  description = "Andromeda Neoim Config Flake";

  outputs = inputs @ {
    self,
    fu,
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
              vim.languages.bash.enable = true;
              # vim.languages.html.enable = true;
              vim.filetree.nvimTreeLua.enable = false;
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
          };

          packages = {
            nix = nixPkg;
            default = nixPkg;
          };
        }
        // {
          # Dev Outputs
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
    # Autocompletes
    plugin-cmp-buffer.url = "github:hrsh7th/cmp-buffer";
    plugin-cmp-buffer.flake = false;

    plugin-cmp-dap.url = "github:rcarriga/cmp-dap";
    plugin-cmp-dap.flake = false;

    plugin-cmp-nvim-lsp.url = "github:hrsh7th/cmp-nvim-lsp";
    plugin-cmp-nvim-lsp.flake = false;

    plugin-cmp-path.url = "github:hrsh7th/cmp-path";
    plugin-cmp-path.flake = false;

    plugin-cmp-vsnip.url = "github:hrsh7th/cmp-vsnip";
    plugin-cmp-vsnip.flake = false;

    plugin-cmp-treesitter.url = "github:ray-x/cmp-treesitter";
    plugin-cmp-treesitter.flake = false;

    plugin-nvim-cmp.url = "github:hrsh7th/nvim-cmp";
    plugin-nvim-cmp.flake = false;

    # Autopairs
    plugin-nvim-autopairs.url = "github:windwp/nvim-autopairs";
    plugin-nvim-autopairs.flake = false;

    # Filetrees
    plugin-nvim-tree-lua.url = "github:kyazdani42/nvim-tree.lua";
    plugin-nvim-tree-lua.flake = false;

    # Key binding help
    plugin-which-key.url = "github:folke/which-key.nvim";
    plugin-which-key.flake = false;

    # LSP plugins
    plugin-nvim-lspconfig.url = "github:neovim/nvim-lspconfig";
    plugin-nvim-lspconfig.flake = false;

    plugin-lspkind.url = "github:onsails/lspkind-nvim";
    plugin-lspkind.flake = false;

    # Plenary (required by crates-nvim)
    plugin-plenary-nvim.url = "github:nvim-lua/plenary.nvim";
    plugin-plenary-nvim.flake = false;

    # snippets
    plugin-vim-vsnip.url = "github:hrsh7th/vim-vsnip";
    plugin-vim-vsnip.flake = false;

    # Statuslines
    plugin-lualine.url = "github:hoob3rt/lualine.nvim";
    plugin-lualine.flake = false;

    # Telescope
    plugin-telescope.url = "github:nvim-telescope/telescope.nvim";
    plugin-telescope.flake = false;

    plugin-telescope-file-browser.url = "github:nvim-telescope/telescope-file-browser.nvim";
    plugin-telescope-file-browser.flake = false;

    plugin-telescope-live-grep-args.url = "github:nvim-telescope/telescope-live-grep-args.nvim";
    plugin-telescope-live-grep-args.flake = false;

    # tresitter plugins
    plugin-nvim-treesitter-context.url = "github:nvim-treesitter/nvim-treesitter-context";
    plugin-nvim-treesitter-context.flake = false;
  };

  #************
  #* THEMES
  #************
  inputs = {
    # Themes
    plugin-tokyonight.url = "github:folke/tokyonight.nvim";
    plugin-tokyonight.flake = false;

    plugin-onedark.url = "github:navarasu/onedark.nvim";
    plugin-onedark.flake = false;

    plugin-catppuccin.url = "github:catppuccin/nvim";
    plugin-catppuccin.flake = false;

    plugin-dracula-nvim.url = "github:Mofiqul/dracula.nvim";
    plugin-dracula-nvim.flake = false;

    plugin-dracula.url = "github:dracula/vim";
    plugin-dracula.flake = false;

    plugin-gruvbox.url = "github:ellisonleao/gruvbox.nvim";
    plugin-gruvbox.flake = false;
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
