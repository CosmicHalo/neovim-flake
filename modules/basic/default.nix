{
  lib,
  config,
  ...
}:
with lib;
with builtins;
with lib.andromeda; let
  cfg = config.vim;
in {
  options.vim = with types; {
    tabWidth = mkOpt int 4 "Set the width of tabs";
    autoIndent = mkBoolOpt true "Enable auto indent";
    wordWrap = mkBoolOpt true "Enable word wrapping.";
    cmdHeight = mkOpt int 1 "Height of the command pane";
    showSignColumn = mkBoolOpt true "Show the sign column";
    colorTerm = mkBoolOpt true "Set terminal up for 256 colours";
    splitRight = mkBoolOpt true "New splits will open to the right";
    syntaxHighlighting = mkBoolOpt true "Enable syntax highlighting";
    mapLeaderSpace = mkBoolOpt true "Map the space key to leader key";
    splitBelow = mkBoolOpt true "New splits will open below instead of on top";
    disableArrows = mkBoolOpt false "Set to prevent arrow keys from moving cursor";
    preventJunkFiles = mkBoolOpt false "Prevent swapfile, backupfile from being created";
    updateTime = mkOpt int 300 "The number of milliseconds till Cursor Hold event is fired";
    hideSearchHighlight = mkBoolOpt false "Hide search highlight so it doesn't stay highlighted";
    mapTimeout = mkOpt int 500 "Timeout in ms that neovim will wait for mapped action to complete";
    scrollOffset = mkOpt int 0 "Start scrolling this number of lines from the top or bottom of the page.";
    bell = mkOpt (enum ["none" "visual" "on"]) "none" "Set how bells are handled. Options: on, visual or none";

    useSystemClipboard =
      mkBoolOpt true
      "Make use of the clipboard for default yank and paste operations. Don't use * and +";

    mouseSupport =
      mkOpt (enum ["a" "n" "v" "i" "c"]) "a"
      "Set modes for mouse support. a - all, n - normal, v - visual, i - insert, c - command";

    lineNumberMode =
      mkOpt (enum ["relative" "number" "relNumber" "none"]) "number"
      "How line numbers are displayed. none, relative, number, relNumber";
  };

  config = {
    vim = {
      startPlugins = ["plenary-nvim" "lazy-nvim"];

      nmap = mkIf cfg.disableArrows {
        "<up>" = "<nop>";
        "<down>" = "<nop>";
        "<left>" = "<nop>";
        "<right>" = "<nop>";
      };

      imap = mkIf cfg.disableArrows {
        "<up>" = "<nop>";
        "<down>" = "<nop>";
        "<left>" = "<nop>";
        "<right>" = "<nop>";
      };

      nnoremap = mkIf cfg.mapLeaderSpace {"<space>" = "<nop>";};

      configRC.basic = nvim.dag.entryAfter ["globalsScript"] ''
        " Settings that are set for everything
        set encoding=utf-8
        set mouse=${cfg.mouseSupport}
        set tabstop=${toString cfg.tabWidth}
        set shiftwidth=${toString cfg.tabWidth}
        set softtabstop=${toString cfg.tabWidth}
        set expandtab
        set cmdheight=${toString cfg.cmdHeight}
        set updatetime=${toString cfg.updateTime}
        set shortmess+=c
        set tm=${toString cfg.mapTimeout}
        set hidden
        set scrolloff=${toString cfg.scrollOffset}
        ${optionalString cfg.splitBelow ''
          set splitbelow
        ''}
        ${optionalString cfg.splitRight ''
          set splitright
        ''}
        ${optionalString cfg.showSignColumn ''
          set signcolumn=yes
        ''}
        ${optionalString cfg.autoIndent ''
          set autoindent
        ''}

        ${optionalString cfg.preventJunkFiles ''
          set noswapfile
          set nobackup
          set nowritebackup
        ''}
        ${optionalString (cfg.bell == "none") ''
          set noerrorbells
          set novisualbell
        ''}
        ${optionalString (cfg.bell == "on") ''
          set novisualbell
        ''}
        ${optionalString (cfg.bell == "visual") ''
          set noerrorbells
        ''}
        ${optionalString (cfg.lineNumberMode == "relative") ''
          set relativenumber
        ''}
        ${optionalString (cfg.lineNumberMode == "number") ''
          set number
        ''}
        ${optionalString (cfg.lineNumberMode == "relNumber") ''
          set number relativenumber
        ''}
        ${optionalString cfg.useSystemClipboard ''
          set clipboard+=unnamedplus
        ''}
        ${optionalString cfg.mapLeaderSpace ''
          let mapleader=" "
          let maplocalleader=" "
        ''}
        ${optionalString cfg.syntaxHighlighting ''
          syntax on
        ''}
        ${optionalString (!cfg.wordWrap) ''
          set nowrap
        ''}
        ${optionalString cfg.hideSearchHighlight ''
          set nohlsearch
          set incsearch
        ''}
        ${optionalString cfg.colorTerm ''
          set termguicolors
          set t_Co=256
        ''}
      '';
    };
  };
}
