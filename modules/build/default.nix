top @ {
  lib,
  pkgs,
  config,
  currentModules,
  ...
}:
with lib;
with builtins;
with lib.andromeda; let
  cfgVim = config.vim;
  cfgBuilt = config.built;
  cfgBuild = config.build;

  inputsSubmodule = _: {
    options.src = mkNullOpt types.package "The plugin source";
  };

  mkInternalOpt = type: default: description: example:
    (mkOptWithExample type default description example)
    // {internal = true;};

  mkReadonlyOpt = type: description:
    mkOption {
      inherit description type;
      readOnly = true;
    };
in {
  options = with types; {
    assertions = mkInternalOpt (listOf unspecified) [] "Assertions to check during evaluation" [
      {
        assertion = false;
        message = "you can't enable this for that reason";
      }
    ];

    warnings = mkInternalOpt (listOf str) [] ''
      This option allows modules to show warnings to users during
      the evaluation of the system configuration.
    '' ["The `foo' service is deprecated and will go away soon!"];

    build = {
      viAlias = mkBoolOpt true "Enable vi alias";
      vimAlias = mkBoolOpt true "Enable vim alias";

      package =
        mkOpt package pkgs.neovim-unwrapped
        "Neovim to use for neovim-flake";

      rawPlugins =
        mkOpt (attrsOf (submodule inputsSubmodule)) {}
        "Plugins that are just the source, usually from a flake input";
    };

    built = {
      configRC = mkReadonlyOpt lines "The final built config";
      optPlugins = mkReadonlyOpt (listOf package) "The final built opt plugins";
      startPlugins = mkReadonlyOpt (listOf package) "The final built start plugins";
      package = mkReadonlyOpt package "The final wrapped and configured neovim package";
    };
  };

  config = let
    buildPlug = name:
      pkgs.vimUtils.buildVimPlugin rec {
        pname = name;
        version = "master";
        src = assert asserts.assertMsg (name != "nvim-treesitter") "Use buildTreesitterPlug for building nvim-treesitter.";
          cfgBuild.rawPlugins.${pname}.src;
      };

    # User provided grammars & override the bundled grammars with nvim-treesitter compatible ones
    # Override rather than overriding `treesitter-parsers` and rebuilding neovim-unwrapped
    # https://github.com/NixOS/nixpkgs/pull/227159
    treeSitterPlug = pkgs.vimPlugins.nvim-treesitter.withPlugins (p:
      config.vim.treesitter.grammars
      ++ [
        p.c
        p.lua
        p.vim
        p.vimdoc
        p.query
      ]);

    buildConfigPlugins = plugins:
      map
      (plug: (
        if isString plug
        then
          (
            if (plug == "nvim-treesitter")
            then treeSitterPlug
            else buildPlug plug
          )
        else plug
      ))
      (filter
        (f: f != null)
        plugins);

    normalizedPlugins =
      cfgBuilt.startPlugins
      ++ (map
        (plugin: {
          inherit plugin;
          optional = true;
        })
        cfgBuilt.optPlugins);

    neovimConfig = pkgs.neovimUtils.makeNeovimConfig {
      inherit (cfgBuild) viAlias vimAlias;
      plugins = normalizedPlugins;
      customRC = cfgBuilt.configRC;
    };

    failedAssertions = map (x: x.message) (filter (x: !x.assertion) config.assertions);

    baseSystemAssertWarn =
      if failedAssertions != []
      then throw "\nFailed assertions:\n${concatStringsSep "\n" (map (x: "- ${x}") failedAssertions)}"
      else lib.showWarnings config.warnings;
  in {
    built = baseSystemAssertWarn {
      configRC = let
        mkSection = r: ''
          " SECTION: ${r.name}
          ${r.data}
        '';
        mapResult = r: (concatStringsSep "\n" (map mkSection r));
        vimConfig = nvim.dag.resolveDag {
          name = "vim config script";
          dag = cfgVim.configRC;
          inherit mapResult;
        };
      in
        vimConfig;

      startPlugins = buildConfigPlugins cfgVim.startPlugins;
      optPlugins = buildConfigPlugins cfgVim.optPlugins;

      package =
        (pkgs.wrapNeovimUnstable cfgBuild.package (neovimConfig
          // {
            wrapRc = true;
          }))
        .overrideAttrs (oldAttrs: {
          passthru =
            oldAttrs.passthru
            // {
              extendConfiguration = {
                lib ? top.lib,
                modules ? [],
                extraSpecialArgs ? {},
                pkgs ? config._module.args.pkgs,
                check ? config._module.args.check,
              }:
                import ../../modules {
                  inherit pkgs lib;
                  modules = currentModules ++ modules;
                  extraSpecialArgs = config._module.specialArgs // extraSpecialArgs;
                };
            };
          meta =
            oldAttrs.meta
            // {
              module = {
                inherit config options;
              };
            };
        });
    };
  };
}
