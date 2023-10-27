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
    lspkind = {
      enable =
        mkEnableOption
        "vscode-like pictograms for lsp [lspkind]";
      mode =
        mkEnumOpt ["text" "text_symbol" "symbol_text" "symbol"] "symbol_text"
        "Defines how annotations are shown";
    };
  };

  config = mkIf (cfg.enable && cfg.lspkind.enable) {
    vim = {
      startPlugins = ["lspkind"];
      luaConfigRC.lspkind =
        nvim.dag.entryAnywhere
        /*
        lua
        */
        ''
          local lspkind = require'lspkind'
          local lspkind_opts = {
            mode = '${cfg.lspkind.mode}'
          }
        '';
    };
  };
}
