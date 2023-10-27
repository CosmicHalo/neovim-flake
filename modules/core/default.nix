{
  lib,
  config,
  ...
}:
with lib;
with builtins;
with lib.andromeda; let
  cfg = config.vim;

  wrapLuaConfig = luaConfig: ''
    lua << EOF
    ${luaConfig}
    EOF
  '';

  mkMappingOption = desc: mkOpt (with types; attrsOf (nullOr str)) {} desc;
in {
  options.vim = with types; {
    configRC = mkOpt (nvim.types.dagOf lines) {} "vimrc contents";
    luaConfigRC = mkOpt (nvim.types.dagOf lines) {} "vim lua config";
    globals = mkOpt attrs {} "Set containing global variable values";

    startPlugins = nvim.options.mkPluginsOption {
      default = [];
      inherit (config.build) rawPlugins;
      description = "List of plugins to startup.";
    };

    optPlugins = nvim.options.mkPluginsOption {
      inherit (config.build) rawPlugins;
      default = [];
      description = "List of plugins to optionally load";
    };

    nnoremap = mkMappingOption "Defines 'Normal mode' mappings";
    xnoremap = mkMappingOption "Defines 'Visual mode' mappings";
    snoremap = mkMappingOption "Defines 'Select mode' mappings";
    tnoremap = mkMappingOption "Defines 'Terminal mode' mappings";
    cnoremap = mkMappingOption "Defines 'Command-line mode' mappings";
    onoremap = mkMappingOption "Defines 'Operator pending mode' mappings";
    vnoremap = mkMappingOption "Defines 'Visual and Select mode' mappings";
    inoremap = mkMappingOption "Defines 'Insert and Replace mode' mappings";

    nmap = mkMappingOption "Defines 'Normal mode' mappings";
    xmap = mkMappingOption "Defines 'Visual mode' mappings";
    smap = mkMappingOption "Defines 'Select mode' mappings";
    tmap = mkMappingOption "Defines 'Terminal mode' mappings";
    cmap = mkMappingOption "Defines 'Command-line mode' mappings";
    omap = mkMappingOption "Defines 'Operator pending mode' mappings";
    vmap = mkMappingOption "Defines 'Visual and Select mode' mappings";
    imap = mkMappingOption "Defines 'Insert and Replace mode' mappings";
  };

  config = let
    mkVimBool = val:
      if val
      then "1"
      else "0";

    valToVim = val:
      if (isInt val)
      then (builtins.toString val)
      else
        (
          if (isBool val)
          then (mkVimBool val)
          else (toJSON val)
        );

    matchCtrl = it: match "Ctrl-(.)(.*)" it;
    filterNonNull = mappings: filterAttrs (name: value: value != null) mappings;

    globalsScript =
      mapAttrsFlatten (name: value: "let g:${name}=${valToVim value}")
      (filterNonNull cfg.globals);

    mapKeyBinding = it: let
      groups = matchCtrl it;
    in
      if groups == null
      then it
      else "<C-${toUpper (head groups)}>${head (tail groups)}";

    mapVimBinding = prefix: mappings:
      mapAttrsFlatten (name: value: "${prefix} ${mapKeyBinding name} ${value}")
      (filterNonNull mappings);

    nmap = mapVimBinding "nmap" config.vim.nmap;
    imap = mapVimBinding "imap" config.vim.imap;
    vmap = mapVimBinding "vmap" config.vim.vmap;
    xmap = mapVimBinding "xmap" config.vim.xmap;
    smap = mapVimBinding "smap" config.vim.smap;
    cmap = mapVimBinding "cmap" config.vim.cmap;
    omap = mapVimBinding "omap" config.vim.omap;
    tmap = mapVimBinding "tmap" config.vim.tmap;

    nnoremap = mapVimBinding "nnoremap" config.vim.nnoremap;
    inoremap = mapVimBinding "inoremap" config.vim.inoremap;
    vnoremap = mapVimBinding "vnoremap" config.vim.vnoremap;
    xnoremap = mapVimBinding "xnoremap" config.vim.xnoremap;
    snoremap = mapVimBinding "snoremap" config.vim.snoremap;
    cnoremap = mapVimBinding "cnoremap" config.vim.cnoremap;
    onoremap = mapVimBinding "onoremap" config.vim.onoremap;
    tnoremap = mapVimBinding "tnoremap" config.vim.tnoremap;
  in {
    vim = {
      configRC = {
        globalsScript = nvim.dag.entryAnywhere (concatStringsSep "\n" globalsScript);

        luaScript = let
          mkSection = r: ''
            -- SECTION: ${r.name}
            ${r.data}
          '';

          mapResult = r: (wrapLuaConfig (concatStringsSep "\n" (map mkSection r)));
          luaConfig = nvim.dag.resolveDag {
            name = "lua config script";
            dag = cfg.luaConfigRC;
            inherit mapResult;
          };
        in
          nvim.dag.entryAfter ["globalsScript"] luaConfig;

        mappings = let
          maps = [nmap imap vmap xmap smap cmap omap tmap nnoremap inoremap vnoremap xnoremap snoremap cnoremap onoremap tnoremap];
          mapConfig = concatStringsSep "\n" (map (v: concatStringsSep "\n" v) maps);
        in
          nvim.dag.entryAfter ["globalsScript"] mapConfig;
      };
    };
  };
}
