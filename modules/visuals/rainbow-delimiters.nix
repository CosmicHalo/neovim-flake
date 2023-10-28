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
  options.vim.visuals.rainbow-delimiters = with types; {
    enable = mkEnableOption "rainbow visual enhancements.";
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.indentBlankline.enable {
      vim = {
        startPlugins = ["rainbow-delimiters"];
        luaConfigRC.indent-blankline =
          nvim.dag.entryAnywhere
          /*
          lua
          */
          "
            -- This module contains a number of default definitions
            local rainbow_delimiters = require 'rainbow-delimiters'
            vim.g.rainbow_delimiters = {
              strategy = {
                [''] = rainbow_delimiters.strategy['global'],
                vim = rainbow_delimiters.strategy['local'],
              },
              query = {
                [''] = 'rainbow-delimiters',
                 lua = 'rainbow-blocks',

              },
              highlight = {
                'RainbowDelimiterRed',
                'RainbowDelimiterYellow',
                'RainbowDelimiterBlue',
                'RainbowDelimiterOrange',
                'RainbowDelimiterGreen',
                'RainbowDelimiterViolet',
                'RainbowDelimiterCyan',
              }
            }
          ";
      };
    })
  ]);
}
