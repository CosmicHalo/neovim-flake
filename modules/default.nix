{
  pkgs,
  check ? true,
  lib ? pkgs.lib,
  modules ? [],
  extraSpecialArgs ? {},
  extendedLib ? (import ../lib/stdlib-extended.nix lib),
}: let
  nvimModules = import ./modules.nix {
    inherit check pkgs;
    lib = extendedLib;
  };

  module = extendedLib.evalModules {
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
