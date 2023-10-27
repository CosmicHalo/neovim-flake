core-inputs: let
  inherit
    (core-inputs.nixpkgs.lib)
    fix
    filterAttrs
    mergeAttrs
    fold
    recursiveUpdate
    callPackageWith
    foldlAttrs
    ;

  merge-shallow = fold mergeAttrs {};
  merge-deep = fold recursiveUpdate {};
  without-self = attrs: builtins.removeAttrs attrs ["self"];

  # Transform an attribute set of inputs into an attribute set where
  # the values are the inputs' `lib` attribute. Entries without a `lib`
  # attribute are removed.
  get-libs = attrs: let
    libs =
      foldlAttrs (acc: name: v:
        acc
        // (
          if builtins.isAttrs (v.lib or null)
          then {${name} = v.lib;}
          else {}
        ))
      {}
      attrs;
  in
    libs;

  core-inputs-libs = get-libs (without-self core-inputs);

  # This root is different to accomodate the creation
  # of a fake user-lib in order to run documentation on this flake.
  andromeda-lib-root = "${core-inputs.src}/andromeda-lib";
  andromeda-lib-dirs = let
    files = builtins.readDir andromeda-lib-root;
    dirs = filterAttrs (_name: kind: kind == "directory") files;
    names = builtins.attrNames dirs;
  in
    names;

  andromeda-lib = fix (
    andromeda-lib: let
      libs =
        builtins.map
        (dir: import "${andromeda-lib-root}/${dir}" {inherit andromeda-lib core-inputs;})
        andromeda-lib-dirs;
    in
      merge-deep libs
  );

  andromeda-top-level-lib = filterAttrs (_name: value: !builtins.isAttrs value) andromeda-lib;

  base-lib = merge-shallow [
    core-inputs.nixpkgs.lib
    core-inputs-libs
    andromeda-top-level-lib
    {andromeda = andromeda-lib;}
  ];

  /*
   ***********
  * USER LIB *
  ***********
  */
  user-lib-root = "${core-inputs.src}/lib";
  user-lib-modules = andromeda-lib.fs.get-default-nix-files-recursive user-lib-root;

  user-lib = fix (
    user-lib: let
      attrs = {
        inputs = core-inputs;
        lib = merge-shallow [base-lib {internal = user-lib;}];
      };
      libs =
        builtins.map
        (path: callPackageWith attrs path {})
        user-lib-modules;
    in
      merge-deep libs
  );

  lib = merge-deep [
    base-lib
    user-lib
  ];
in
  lib
