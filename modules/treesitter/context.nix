{
  lib,
  config,
  ...
}:
with lib;
with lib.andromeda;
with builtins; let
  inherit (config.vim) treesitter;
  cfg = treesitter.context;
in {
  options.vim.treesitter.context = with types; {
    enable = mkEnableOption "context of current buffer contents [nvim-treesitter-context] ";

    maxLines =
      mkIntOpt 0
      "How many lines the window should span. Values &lt;=0 mean no limit.";

    minWindowHeight =
      mkIntOpt 0
      "Minimum editor window height to enable context. Values &lt;= 0 mean no limit.";

    lineNumbers =
      mkBoolOpt true
      "Show line numbers in context window.";

    multilineThreshold =
      mkIntOpt 20
      "Maximum number of lines to collapse for a single context line.";

    trimScope =
      mkEnumOpt ["inner" "outer"] "outer"
      "Which context lines to discard if <<opt-vim.treesitter.context.maxLines>> is exceeded.";

    mode =
      mkEnumOpt ["cursor" "topline"] "cursor"
      "Line used to calculate context.";

    separator = mkNullOpt (nullOr str) ''
      Separator between context and content. Should be a single character string, like '-'.

      When separator is set, the context will only show up when there are at least 2 lines above cursorline.
    '';

    zindex =
      mkIntOpt 20
      "The Z-index of the context window.";
  };

  config = mkIf (treesitter.enable && cfg.enable) {
    vim = {
      startPlugins = ["nvim-treesitter-context"];

      luaConfigRC.treesitter-context =
        nvim.dag.entryAnywhere
        /*
        lua
        */
        ''
          require'treesitter-context'.setup {
            enable = true,
            max_lines = ${toString cfg.maxLines},
            min_window_height = ${toString cfg.minWindowHeight},
            line_numbers = ${boolToString cfg.lineNumbers},
            multiline_threshold = ${toString cfg.multilineThreshold},
            trim_scope = '${cfg.trimScope}',
            mode = '${cfg.mode}',
            separator = ${nvim.lua.nullString cfg.separator},
            max_lines = ${toString cfg.zindex},
          }
        '';
    };
  };
}
