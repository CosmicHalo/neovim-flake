{lib}:
with lib; let
  diagnosticSubmodule = _: {
    options = {
      type = mkOption {
        type = attrNames diagnostics;
        description = "Type of diagnostic to enable";
      };
      package = mkOption {
        type = types.package;
        description = "Diagnostics package";
      };
    };
  };
in {
  mkDiagnosticsOption = {
    langDesc,
    diagnostics,
    defaultDiagnostics,
  }:
    mkOption {
      default = defaultDiagnostics;
      description = "List of ${langDesc} diagnostics to enable";
      type = with types; listOf (either (enum (attrNames diagnostics)) (submodule diagnosticSubmodule));
    };

  mkGrammarOption = pkgs: grammar:
    mkPackageOption pkgs ["${grammar} treesitter"] {
      default = ["vimPlugins" "nvim-treesitter" "builtGrammars" grammar];
    };

  mkCommandOption = pkgs: {
    package,
    description,
  }:
    mkPackageOption pkgs [description] {
      nullable = true;
      default = package;
      extraDescription = "Providing null will use command in $PATH.";
    };
}
