{
  core-inputs,
  andromeda-lib,
  ...
}: let
  inherit (builtins) readDir pathExists;
  inherit (core-inputs.nixpkgs.lib) filterAttrs mapAttrsToList;
in {
  fs = rec {
    ## Matchers for file kinds. These are often used with `readDir`.
    is-file-kind = kind: kind == "regular";
    is-symlink-kind = kind: kind == "symlink";
    is-directory-kind = kind: kind == "directory";
    is-unknown-kind = kind: kind == "unknown";

    ## Get a file path relative to the this flake.
    get-file = path: "${core-inputs.src}/${path}";

    ## Safely read from a directory if it exists.
    safe-read-directory = path:
      if pathExists path
      then readDir path
      else {};

    ## Get directories at a given path.
    get-directories = path: let
      entries = safe-read-directory path;
      filtered-entries = filterAttrs (_name: is-directory-kind) entries;
    in
      mapAttrsToList (name: _kind: "${path}/${name}") filtered-entries;

    ## Get files at a given path.
    get-files = path: let
      entries = safe-read-directory path;
      filtered-entries = filterAttrs (_name: is-file-kind) entries;
    in
      mapAttrsToList (name: _kind: "${path}/${name}") filtered-entries;

    ## Get files at a given path, traversing any directories within.
    get-files-recursive = path: let
      entries = safe-read-directory path;
      filtered-entries =
        filterAttrs
        (_name: kind: (is-file-kind kind) || (is-directory-kind kind))
        entries;
      map-file = name: kind: let
        path' = "${path}/${name}";
      in
        if is-directory-kind kind
        then get-files-recursive path'
        else path';
      files =
        andromeda-lib.attrs.map-concat-attrs-to-list
        map-file
        filtered-entries;
    in
      files;

    ## Get nix files at a given path.
    get-nix-files = path:
      builtins.filter
      (andromeda-lib.path.has-file-extension "nix")
      (get-files path);

    ## Get nix files at a given path, traversing any directories within.
    get-nix-files-recursive = path:
      builtins.filter
      (andromeda-lib.path.has-file-extension "nix")
      (get-files-recursive path);

    ## Get nix files at a given path named "default.nix".
    get-default-nix-files = path:
      builtins.filter
      (name: builtins.baseNameOf name == "default.nix")
      (get-files path);

    ## Get nix files at a given path named "default.nix", traversing any directories within.
    get-default-nix-files-recursive = path:
      builtins.filter
      (name: builtins.baseNameOf name == "default.nix")
      (get-files-recursive path);

    ## Get nix files at a given path not named "default.nix".
    get-non-default-nix-files = path:
      builtins.filter
      (
        name:
          (andromeda-lib.path.has-file-extension "nix" name)
          && (builtins.baseNameOf name != "default.nix")
      )
      (get-files path);

    ## Get nix files at a given path not named "default.nix", traversing any directories within.
    get-non-default-nix-files-recursive = path:
      builtins.filter
      (
        name:
          (andromeda-lib.path.has-file-extension "nix" name)
          && (builtins.baseNameOf name != "default.nix")
      )
      (get-files-recursive path);
  };
}
