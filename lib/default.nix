{lib}: {
  nvim = {
    build = import ./build {inherit lib;};
    dag = import ./dag {inherit lib;};
    languages = import ./languages {inherit lib;};
    lua = import ./lua {inherit lib;};
    options = import ./options {inherit lib;};
    plugins = import ./plugins {inherit lib;};
    types = import ./types {inherit lib;};
  };
}
