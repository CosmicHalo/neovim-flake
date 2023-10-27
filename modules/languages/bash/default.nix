{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with lib.andromeda;
with builtins; let
  cfg = config.vim.languages.bash;

  ################
  # Servers
  ################
  defaultServer = "bashls";
  servers = {
    bashls = {
      package = ["nodePackages" "bash-language-server"];
      lspConfig =
        /*
        lua
        */
        ''
          lspconfig.bashls.setup{
            capabilities = capabilities;
            on_attach = default_on_attach;
            cmd = {"${nvim.languages.commandOptToCmd cfg.lsp.package "bash-language-server"}", "start"};
          }
        '';
    };
  };

  ################
  # Default formatters
  ################

  defaultFormat = "shfmt";
  formats = {
    shfmt = {
      package = ["shfmt"];
      nullConfig =
        /*
        lua
        */
        ''
          table.insert(
            ls_sources,
            null_ls.builtins.formatting.shfmt.with({
              command = "${nvim.languages.commandOptToCmd cfg.format.package "shfmt"}",
            })
          )
        '';
    };
  };

  ################
  # Diagnostic sources
  ################
  defaultDiagnostics = ["shellcheck"];
  diagnostics = {
    shellcheck = {
      package = pkgs.shellcheck;
      nullConfig = pkg:
      /*
      lua
      */
      ''
        table.insert(
          ls_sources,
          null_ls.builtins.diagnostics.shellcheck.with({
            command = "${pkg}/bin/shellcheck",
          })
        )
      '';
    };
  };
in {
  options.vim.languages.bash = {
    enable = mkEnableOption "Bash language support";

    treesitter = {
      enable = mkBoolOpt config.vim.languages.enableTreesitter "Bash treesitter";
      package = nvim.options.mkGrammarOption pkgs "bash";
    };

    lsp = {
      enable = mkBoolOpt config.vim.languages.enableLSP "Enable Bash LSP support";

      server =
        mkEnumOpt (attrNames servers) defaultServer
        "Bash LSP server to use";

      package = lib.nvim.options.mkCommandOption pkgs {
        description = "Bash LSP server";
        inherit (servers.${cfg.lsp.server}) package;
      };
    };

    format = {
      enable = mkBoolOpt config.vim.languages.enableFormat "Enable Bash formatting";

      type =
        mkEnumOpt (attrNames formats) defaultFormat
        "Bash formatter to use";

      package = lib.nvim.options.mkCommandOption pkgs {
        description = "Bash formatter package.";
        inherit (formats.${cfg.format.type}) package;
      };
    };

    extraDiagnostics = {
      enable = mkBoolOpt config.vim.languages.enableExtraDiagnostics "Enable extra Bash diagnostics";

      types = lib.nvim.options.mkDiagnosticsOption {
        langDesc = "Bash";
        inherit diagnostics;
        inherit defaultDiagnostics;
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [cfg.treesitter.package];
    })

    (mkIf cfg.lsp.enable {
      vim.lsp.lspconfig.enable = true;
      vim.lsp.lspconfig.sources.bash-lsp = servers.${cfg.lsp.server}.lspConfig;
    })

    # (mkIf cfg.format.enable {
    #   vim.lsp.null-ls.enable = true;
    #   vim.lsp.null-ls.sources.bash-format = formats.${cfg.format.type}.nullConfig;
    # })

    # (mkIf cfg.extraDiagnostics.enable {
    #   vim.lsp.null-ls.enable = true;
    #   vim.lsp.null-ls.sources = lib.nvim.languages.diagnosticsToLua {
    #     lang = "bash";
    #     config = cfg.extraDiagnostics.types;
    #     inherit diagnostics;
    #   };
    # })
  ]);
}
