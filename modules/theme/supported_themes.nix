{
  lib,
  config,
  ...
}:
with lib;
with builtins;
with lib.andromeda; let
  themeSubmodule.options = with types; {
    setup = mkNullOpt str "Lua code to initialize theme";
    defaultStyle = mkNullOpt str "The default style for the theme";
    styles = mkNullOpt (nullOr (listOf str)) "The available styles for the theme";
  };

  cfg = config.vim.theme;
in {
  options.vim.theme = with types; {
    supportedThemes = mkOpt (attrsOf (submodule themeSubmodule)) null "Supported themes";
  };

  config.vim.theme.supportedThemes = {
    onedark = {
      defaultStyle = "dark";
      styles = ["dark" "darker" "cool" "deep" "warm" "warmer"];

      setup = ''
        -- OneDark theme
        require('onedark').setup {
          style = "${cfg.style}"
        }
        require('onedark').load()
      '';
    };

    tokyonight = {
      defaultStyle = "night";
      styles = ["day" "night" "storm" "moon"];

      setup = ''
        -- need to set style before colorscheme to apply
        require("tokyonight").setup({
          style = "${cfg.style}",
        })
        vim.cmd[[colorscheme tokyonight]]
      '';
    };

    catppuccin = {
      defaultStyle = "mocha";
      styles = ["latte" "frappe" "macchiato" "mocha"];

      setup = ''
        -- Catppuccin theme
        require('catppuccin').setup {
          flavour = "${cfg.style}"
        }
        -- setup must be called before loading
        vim.cmd.colorscheme "catppuccin"
      '';
    };

    dracula-nvim = {
      setup = ''
        require('dracula').setup({});
        require('dracula').load();
      '';
    };

    dracula = {
      setup = ''
        vim.cmd[[colorscheme dracula]]
      '';
    };

    gruvbox = {
      defaultStyle = "dark";
      styles = ["dark" "light"];

      setup = ''
        -- gruvbox theme
        vim.o.background = "${cfg.style}"
        vim.cmd.colorscheme "gruvbox"
      '';
    };
  };
}
