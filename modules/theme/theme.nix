{
  lib,
  config,
  ...
}:
with lib;
with lib.attrsets;
with lib.andromeda;
with builtins; let
  cfg = config.vim.theme;
in {
  options.vim.theme = with types; {
    enable = mkEnableOption "themes";

    name =
      mkOpt (enum (attrNames cfg.supportedThemes)) "onedark"
      "Supported themes can be found in `supportedThemes.nix`";

    style =
      mkOpt (enum cfg.supportedThemes.${cfg.name}.styles)
      cfg.supportedThemes.${cfg.name}.defaultStyle "Specific style for theme if it supports it";

    extraConfig =
      mkOpt lines ""
      "Additional lua configuration to add before setup";
  };

  config = mkIf cfg.enable {
    vim = {
      startPlugins = [cfg.name];

      luaConfigRC = {
        theme = cfg.supportedThemes.${cfg.name}.setup;
        themeSetup = nvim.dag.entryBefore ["theme"] cfg.extraConfig;
      };
    };
  };
}
