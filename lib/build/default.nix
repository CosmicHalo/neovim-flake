{
  lib,
  inputs,
  ...
}: let
  rawPlugins = lib.plugins.pluginsFromInputs inputs;
in {
  build = rec {
    nvimBin = pkg: "${pkg}/bin/nvim";

    buildPkg = pkgs: modules: (neovimConfiguration {inherit pkgs modules;});

    neovimConfiguration = {modules ? [], ...} @ args:
      import ./modules
      (args
        // {
          # inherit extendedLib;
          modules = [{config.build.rawPlugins = rawPlugins;}] ++ modules;
        });
  };
}
