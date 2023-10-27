{lib, ...}: {
  loadModules = pkgs: check: let
    mods = lib.andromeda.fs.get-directories (lib.andromeda.fs.get-file "modules");

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
