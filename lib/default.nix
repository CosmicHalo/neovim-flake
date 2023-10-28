{
  lib,
  inputs,
}: {
  nvim = {
    dag = import ./dag.nix {inherit lib;};
    languages = import ./lang.nix {inherit lib;};
    lua = import ./lua.nix;
    module = import ./module.nix {inherit lib;};
    options = import ./options/module.nix {inherit lib;};
    plugins = import ./plugins.nix {inherit lib;};
    types = import ./types/module.nix {inherit lib;};
  };
}
