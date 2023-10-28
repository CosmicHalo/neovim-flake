{
  lib,
  config,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.lsp;
in {
  options.vim.lsp = {
    trouble = {
      enable = mkEnableOption "trouble diagnostics viewer";
    };
  };

  config = mkIf (cfg.enable && cfg.trouble.enable) {
    vim = {
      startPlugins = ["trouble"];

      nnoremap = {
        "<leader>xx" = "<cmd>TroubleToggle<CR>";
        "<leader>lwd" = "<cmd>TroubleToggle workspace_diagnostics<CR>";
        "<leader>ld" = "<cmd>TroubleToggle document_diagnostics<CR>";
        "<leader>lr" = "<cmd>TroubleToggle lsp_references<CR>";
        "<leader>xq" = "<cmd>TroubleToggle quickfix<CR>";
        "<leader>xl" = "<cmd>TroubleToggle loclist<CR>";
      };

      luaConfigRC.trouble =
        nvim.dag.entryAnywhere
        /*
        lua
        */
        ''
          -- Enable trouble diagnostics viewer
          require("trouble").setup {}
        '';
    };
  };
}
