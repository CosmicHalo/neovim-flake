{
  lib,
  config,
  ...
}:
with lib;
with builtins;
with lib.andromeda; let
  cfg = config.vim.keys;
in {
  options.vim.keys = {
    enable = mkEnableOption "key binding plugins";
    whichKey = mkEnableOpt "which-key";
  };

  config = mkIf (cfg.enable && cfg.whichKey.enable) {
    vim.startPlugins = ["which-key"];

    vim.luaConfigRC.whichkey =
      nvim.dag.entryAnywhere
      /*
      lua
      */
      ''
        local wk = require("which-key").setup {}
      '';
  };
}
