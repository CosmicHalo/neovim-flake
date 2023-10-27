{lib, ...}: rec {
  getModuleDirs = path: lib.andromeda.fs.get-directories (lib.andromeda.fs.get-file path);

  loadModules = pkgs: check: let
    mods = getModuleDirs "modules";

    pkgsModule = {config, ...}: {
      config = {
        _module = {
          inherit check;
          args = {
            pkgs = lib.mkDefault pkgs;
            pkgsPath = lib.mkDefault pkgs.path;
          };
        };
      };
    };
  in
    mods ++ [pkgsModule];
}
