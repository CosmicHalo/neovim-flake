{
  lib,
  pkgs,
  modules ? [],
  extraSpecialArgs ? {},
}: let
  nvimModules = lib.nvim.module.loadModules pkgs;

  module = lib.evalModules {
    modules = modules ++ nvimModules;
    specialArgs =
      {
        modulesPath = builtins.toString ./.;
        currentModules = modules;
      }
      // extraSpecialArgs;
  };
in
  module.config.built.package
