{
  lib,
  config,
  ...
}:
with lib;
with builtins;
with lib.andromeda; let
  cfg = config.vim.statusline.lualine;

  supported_themes = import ./supported_lualine_themes.nix;
  themeSupported = elem config.vim.theme.name supported_themes;
  themes =
    [
      "auto"
      "16color"
      "gruvbox"
      "ayu_dark"
      "ayu_light"
      "ayu_mirage"
      "codedark"
      "dracula"
      "everforest"
      "gruvbox"
      "gruvbox_light"
      "gruvbox_material"
      "horizon"
      "iceberg_dark"
      "iceberg_light"
      "jellybeans"
      "material"
      "modus_vivendi"
      "molokai"
      "nightfly"
      "nord"
      "oceanicnext"
      "onelight"
      "palenight"
      "papercolor_dark"
      "papercolor_light"
      "powerline"
      "seoul256"
      "solarized_dark"
      "tomorrow"
      "wombat"
    ]
    ++ optional themeSupported config.vim.theme.name;
in {
  options.vim.statusline.lualine = with types; {
    enable = mkEnableOption "lualine";
    icons = mkBoolOpt true "Enable icons for lualine";

    theme =
      (mkOpt (enum themes) "auto" null)
      // {defaultText = ''`config.vim.theme.name` if theme supports lualine else "auto"'';};

    sectionSeparator = {
      left = mkOpt str "" "Section separator for left side";
      right = mkOpt str "" "Section separator for right side";
    };

    componentSeparator = {
      left = mkOpt str "⏽" "Component separator for left side";
      right = mkOpt str "⏽" "Component separator for right side";
    };

    activeSection = {
      a =
        mkOpt str "{'mode'}"
        "active config for: | (A) | B | C       X | Y | Z |";

      b = mkOpt str ''
        {
          {
            "branch",
            separator = '',
          },
          "diff",
        }
      '' "active config for: | A | (B) | C       X | Y | Z |";

      c = mkOpt str "{'filename'}" "active config for: | A | B | (C)       X | Y | Z |";

      x = mkOpt str ''
        {
          {
            "diagnostics",
            sources = {'nvim_lsp'},
            separator = '',
            symbols = {error = '', warn = '', info = '', hint = ''},
          },
          {
            "filetype",
          },
          "fileformat",
          "encoding",
        }
      '' "active config for: | A | B | C       (X) | Y | Z |";

      y = mkOpt str "{'progress'}" "active config for: | A | B | C       X | (Y) | Z |";
      z = mkOpt str "{'location'}" "active config for: | A | B | C       X | Y | (Z) |";
    };

    inactiveSection = {
      a = mkOpt str "{}" "inactive config for: | (A) | B | C       X | Y | Z |";
      b = mkOpt str "{}" "inactive config for: | A | (B) | C       X | Y | Z |";
      c = mkOpt str "{'filename'}" "inactive config for: | A | B | (C)       X | Y | Z |";
      x = mkOpt str "{'location'}" "inactive config for: | A | B | C       (X) | Y | Z |";
      y = mkOpt str "{}" "inactive config for: | A | B | C       X | (Y) | Z |";
      z = mkOpt str "{}" "inactive config for: | A | B | C       X | Y | (Z) |";
    };
  };

  config = mkIf cfg.enable {
    #assertions = [
    #  ({
    #    assertion = if cfg.icons then (config.vim.visuals.enable && config.vim.visuals.nvimWebDevicons.enable) else true;
    #    message = "Must enable config.vim.visual.nvimWebDevicons if using config.vim.visuals.lualine.icons";
    #  })
    #];

    vim.startPlugins = ["lualine"];
    vim.luaConfigRC.lualine =
      nvim.dag.entryAnywhere
      /*
      lua
      */
      ''
        require'lualine'.setup {
          options = {
            icons_enabled = ${boolToString cfg.icons},
            theme = "${cfg.theme}",
            component_separators = {
              left = "${cfg.componentSeparator.left}",
              right = "${cfg.componentSeparator.right}"
            },
            section_separators = {
              left = "${cfg.sectionSeparator.left}",
              right = "${cfg.sectionSeparator.right}"
            },
            disabled_filetypes = {},
          },
          sections = {
            lualine_a = ${cfg.activeSection.a},
            lualine_b = ${cfg.activeSection.b},
            lualine_c = ${cfg.activeSection.c},
            lualine_x = ${cfg.activeSection.x},
            lualine_y = ${cfg.activeSection.y},
            lualine_z = ${cfg.activeSection.z},
          },
          inactive_sections = {
            lualine_a = ${cfg.inactiveSection.a},
            lualine_b = ${cfg.inactiveSection.b},
            lualine_c = ${cfg.inactiveSection.c},
            lualine_x = ${cfg.inactiveSection.x},
            lualine_y = ${cfg.inactiveSection.y},
            lualine_z = ${cfg.inactiveSection.z},
          },
          tabline = {},
          extensions = {${optionalString config.vim.filetree.nvimTreeLua.enable "'nvim-tree'"}},
        }
      '';
  };
}
