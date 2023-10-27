{lib, ...}:
with lib;
with lib.andromeda; let
  mkEnable = desc: mkBoolOpt false "Turn on ${desc} for enabled languages by default";

  imports = lib.nvim.module.getModuleDirs "modules/languages";
in {
  inherit imports;

  options.vim.languages = {
    enableLSP = mkEnable "LSP";
    enableFormat = mkEnable "formatting";
    enableDebugger = mkEnable "debuggers";
    enableTreesitter = mkEnable "treesitter";
    enableExtraDiagnostics = mkEnable "extra diagnostics";
  };
}
