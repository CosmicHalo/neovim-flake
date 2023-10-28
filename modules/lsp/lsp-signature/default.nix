{
  lib,
  config,
  ...
}:
with lib;
with lib.andromeda;
with builtins; let
  cfg = config.vim.lsp;
in {
  options.vim.lsp = {
    lspSignature = {
      enable = mkEnableOption "lsp signature viewer";
    };
  };

  config = mkIf (cfg.enable && cfg.lspSignature.enable) {
    vim = {
      startPlugins = ["lsp-signature"];
      luaConfigRC.lsp-signature =
        nvim.dag.entryAnywhere
        /*
        lua
        */
        ''
          -- Enable lsp signature viewer
          require("lsp_signature").setup()
        '';
    };
  };
}
