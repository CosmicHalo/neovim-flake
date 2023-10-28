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
  options.vim.lsp.lspconfig = with types; {
    enable = mkEnableOption "nvim-lspconfig, also enabled automatically";
    sources = mkOpt (attrsOf str) {} "nvim-lspconfig sources";
  };

  config = mkIf cfg.lspconfig.enable (mkMerge [
    {
      vim = {
        lsp.enable = true;

        startPlugins = ["nvim-lspconfig"];

        luaConfigRC.lspconfig =
          nvim.dag.entryAfter ["lsp-setup"]
          /*
          lua
          */
          ''
            local lspconfig = require('lspconfig')
          '';
      };
    }

    {
      vim.luaConfigRC = mapAttrs (_: v: (nvim.dag.entryAfter ["lspconfig"] v)) cfg.lspconfig.sources;
    }
  ]);
}
