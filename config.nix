{lib, ...}: let
  overrideable = lib.mkOverride 1200; # between mkOptionDefault and mkDefault
in
  isMaximal: {
    config = {
      build.viAlias = overrideable false;
      build.vimAlias = overrideable true;

      vim.autopairs.enable = overrideable true;
      vim.autocomplete = {
        enable = overrideable true;
        type = overrideable "nvim-cmp";
      };

      vim.debugger.ui.enable = overrideable true;
      vim.filetree.nvimTreeLua.enable = overrideable true;

      # vim.git = {
      #   enable = overrideable true;
      #   gitsigns.enable = overrideable true;
      #   gitsigns.codeActions = overrideable true;
      # };

      vim.keys = {
        enable = overrideable true;
        whichKey.enable = overrideable true;
      };

      vim.languages = {
        enableLSP = overrideable true;
        enableFormat = overrideable true;
        enableTreesitter = overrideable true;
        enableExtraDiagnostics = overrideable true;
        enableDebugger = overrideable true;

        bash.enable = overrideable isMaximal;
        # clang.enable = overrideable isMaximal;
        # go.enable = overrideable isMaximal;
        # html.enable = overrideable isMaximal;
        # markdown.enable = overrideable true;
        nix.enable = overrideable true;
        # plantuml.enable = overrideable isMaximal;
        # python.enable = overrideable isMaximal;
        # rust = {
        #   enable = overrideable isMaximal;
        #   crates.enable = overrideable true;
        # };
        # sql.enable = overrideable isMaximal;
        # ts.enable = overrideable isMaximal;
        # zig.enable = overrideable isMaximal;

        # See tidal config
        # tidal.enable = overrideable false;
      };

      vim.lsp = {
        formatOnSave = overrideable true;
        lspkind.enable = overrideable true;
        # lightbulb.enable = overrideable true;
        # lspsaga.enable = overrideable false;
        # nvimCodeActionMenu.enable = overrideable true;
        # trouble.enable = overrideable true;
        # lspSignature.enable = overrideable true;
      };

      vim.statusline.lualine.enable = overrideable true;
      vim.theme.enable = true;

      # vim.tabline.nvimBufferline.enable = overrideable true;
      vim.treesitter.context.enable = overrideable true;

      # vim.telescope = {
      #   enable = overrideable true;
      #   fileBrowser.enable = overrideable true;
      #   liveGrepArgs.enable = overrideable true;
      # };

      # vim.visuals = {
      #   enable = overrideable true;
      #   nvimWebDevicons.enable = overrideable true;
      #   indentBlankline = {
      #     enable = overrideable true;
      #     fillChar = overrideable null;
      #     eolChar = overrideable null;
      #     showCurrContext = overrideable true;
      #   };
      #   cursorWordline = {
      #     enable = overrideable true;
      #     lineTimeout = overrideable 0;
      #   };
      # };
    };
  }
