{
  lib,
  config,
  ...
}:
with lib;
with lib.andromeda;
with builtins; let
  cfg = config.vim.visuals;
in {
  options.vim.visuals = with types; {
    enable = mkEnableOption "visual enhancements.";
    nvimWebDevicons.enable = mkEnableOption "dev icons. Required for certain plugins [nvim-web-devicons].";

    cursorWordline = {
      enable = mkEnableOption "word and delayed line highlight [nvim-cursorline].";
      lineTimeout = mkIntOpt 500 "Time in milliseconds for cursorline to appear.";
    };

    indentBlankline = {
      enable = mkEnableOption "indentation guides [indent-blankline].";

      listChar = mkStrOpt "│" "Character for indentation line.";
      fillChar = mkOpt (nullOr str) "." "Character to fill indents";

      eolChar = mkOption {
        description = "Character at end of line";
        type = with types; nullOr types.str;
        default = "↴";
      };

      showEndOfLine = mkBoolOpt (cfg.indentBlankline.eolChar != null) ''
        Displays the end of line character set by <<opt-vim.visuals.indentBlankline.eolChar>> instead of the
        indent guide on line returns.
      '';

      showCurrContext =
        (mkBoolOpt config.vim.treesitter.enable "Highlight current context from treesitter.")
        // {defaultText = literalExpression "config.vim.treesitter.enable";};

      useTreesitter =
        (mkBoolOpt config.vim.treesitter.enable "Use treesitter to calculate indentation when possible.")
        // {defaultText = literalExpression "config.vim.treesitter.enable";};
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.indentBlankline.enable {
      vim = {
        startPlugins = ["indent-blankline"];
        luaConfigRC.indent-blankline =
          nvim.dag.entryAnywhere
          /*
          lua
          */
          ''
            vim.opt.list = true

            ${optionalString (cfg.indentBlankline.eolChar != null) ''
              vim.opt.listchars:append({ eol = "${cfg.indentBlankline.eolChar}" })
            ''}
            ${optionalString (cfg.indentBlankline.fillChar != null) ''
              vim.opt.listchars:append({ space = "${cfg.indentBlankline.fillChar}" })
            ''}

            local highlight = {
              "RainbowRed",
              "RainbowYellow",
              "RainbowBlue",
              "RainbowOrange",
              "RainbowGreen",
              "RainbowViolet",
              "RainbowCyan",
            }

            local hooks = require "ibl.hooks"
            -- create the highlight groups in the highlight setup hook, so they are reset
            -- every time the colorscheme changes
            hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
                vim.api.nvim_set_hl(0, "RainbowRed", { fg = "#E06C75" })
                vim.api.nvim_set_hl(0, "RainbowYellow", { fg = "#E5C07B" })
                vim.api.nvim_set_hl(0, "RainbowBlue", { fg = "#61AFEF" })
                vim.api.nvim_set_hl(0, "RainbowOrange", { fg = "#D19A66" })
                vim.api.nvim_set_hl(0, "RainbowGreen", { fg = "#98C379" })
                vim.api.nvim_set_hl(0, "RainbowViolet", { fg = "#C678DD" })
                vim.api.nvim_set_hl(0, "RainbowCyan", { fg = "#56B6C2" })

            end)

            ${optionalString (cfg.rainbow-delimiters.enable) ''
              vim.g.rainbow_delimiters = { highlight = highlight }
            ''}

            require("ibl").setup { indent = { highlight = highlight } }
            hooks.register(hooks.type.SCOPE_HIGHLIGHT, hooks.builtin.scope_highlight_from_extmark)
          '';
      };
    })

    (mkIf cfg.cursorWordline.enable {
      vim = {
        startPlugins = ["nvim-cursorline"];
        luaConfigRC.cursorline =
          nvim.dag.entryAnywhere
          /*
          lua
          */
          ''
            vim.g.cursorline_timeout = ${toString cfg.cursorWordline.lineTimeout}
          '';
      };
    })
    (mkIf cfg.nvimWebDevicons.enable {
      vim.startPlugins = ["nvim-web-devicons"];
    })
  ]);
}
