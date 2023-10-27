{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with lib.andromeda;
with builtins; let
  cfg = config.vim.filetree.nvimTreeLua;
in {
  imports = [
    (mkRemovedOptionModule ["vim" "filetree" "nvimTreeLua" "openOnSetup"] ''
      `open_on_setup*` options have been removed from nvim-tree-lua.
      see https://github.com/nvim-tree/nvim-tree.lua/issues/1669
    '')
  ];
  options.vim.filetree.nvimTreeLua = with types; {
    enable = mkEnableOption "NvimTreeLua";

    treeWidth =
      mkIntOpt 25
      "Width of the tree in charecters";

    treeSide =
      mkEnumOpt ["left" "right"] "left"
      "Side the tree will appear on left or right";

    hideFiles =
      mkOpt (listOf str) [".git" "node_modules" ".cache"]
      "Files to hide in the file view by default.";

    hideDotFiles = mkBoolOpt false "Hide dotfiles";
    ignoreFileTypes = mkOpt (listOf str) [] "Ignore file types";
    hideIgnoredGitFiles = mkBoolOpt false "Hide files ignored by git";

    resizeOnFileOpen = mkBoolOpt false "Resizes the tree when opening a file";
    closeOnFileOpen = mkBoolOpt false "Closes the tree when a file is opened";
    closeOnLastWindow = mkBoolOpt true "Close when tree is last window open";
    openTreeOnNewTab = mkBoolOpt false "Opens the tree view when opening a new tab";
    systemOpenCmd =
      mkStrOpt "${pkgs.xdg-utils}/bin/xdg-open"
      "The command used to open a file with the associated default program";

    indentMarkers = mkBoolOpt true "Show indent markers";
    lspDiagnostics = mkBoolOpt true "Shows lsp diagnostics in the tree";
    trailingSlash = mkBoolOpt true "Add a trailing slash to all folders";
    disableNetRW = mkBoolOpt false "Disables netrw and replaces it with tree";
    followBufferFile = mkBoolOpt true "Follow file that is in current buffer on tree";
    groupEmptyFolders = mkBoolOpt true "Compact empty folders trees into a single item";
    hijackNetRW = mkBoolOpt true "Prevents netrw from automatically opening when opening directories";
  };

  config = mkIf cfg.enable {
    vim.startPlugins = ["nvim-tree-lua"];

    vim.nnoremap = {
      "<C-n>" = ":NvimTreeToggle<CR>";
      "<leader>tr" = ":NvimTreeRefresh<CR>";
      "<leader>tg" = ":NvimTreeFindFile<CR>";
      "<leader>tf" = ":NvimTreeFocus<CR>";
    };

    vim.luaConfigRC.nvimtreelua =
      nvim.dag.entryAnywhere
      /*
      lua
      */
      ''
        require'nvim-tree'.setup({
          disable_netrw = ${boolToString cfg.disableNetRW},
          hijack_netrw = ${boolToString cfg.hijackNetRW},
          system_open = {
            cmd = ${"'" + cfg.systemOpenCmd + "'"},
          },
          diagnostics = {
            enable = ${boolToString cfg.lspDiagnostics},
          },
          view  = {
            width = ${toString cfg.treeWidth},
            side = ${"'" + cfg.treeSide + "'"},
          },
          tab = {
            sync = {
              open = ${boolToString cfg.openTreeOnNewTab}
            },
          },
          renderer = {
            indent_markers = {
              enable = ${boolToString cfg.indentMarkers},
            },
            add_trailing = ${boolToString cfg.trailingSlash},
            group_empty = ${boolToString cfg.groupEmptyFolders},
          },
          actions = {
            open_file = {
              quit_on_open = ${boolToString cfg.closeOnFileOpen},
              resize_window = ${boolToString cfg.resizeOnFileOpen},
            },
          },
          git = {
            enable = true,
            ignore = ${boolToString cfg.hideIgnoredGitFiles},
          },
          filters = {
            dotfiles = ${boolToString cfg.hideDotFiles},
            custom = {
              ${builtins.concatStringsSep "\n" (builtins.map (s: "\"" + s + "\",") cfg.hideFiles)}
            },
          },
        })
      '';
  };
}
