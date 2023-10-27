{
  lib,
  config,
  ...
}:
with lib;
with lib.andromeda;
with builtins; let
  cfg = config.vim.autopairs;
in {
  options.vim.autopairs = {
    enable = mkBoolOpt false "Enable autopairs";
    type =
      mkEnumOpt ["nvim-autopairs"] "nvim-autopairs"
      "Set the autopairs type. Options: nvim-autopairs [nvim-autopairs]";
  };

  config =
    mkIf cfg.enable
    {
      vim = {
        startPlugins = ["nvim-autopairs"];

        luaConfigRC.autopairs =
          nvim.dag.entryAnywhere
          /*
          lua
          */
          ''
            require("nvim-autopairs").setup{}
          '';
      };
    };
}
