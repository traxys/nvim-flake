{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim;
  writeIf = cond: msg:
    if cond
    then msg
    else "";
  writeIfNotNull = value: func:
    if value != null
    then func value
    else "";
  comma = s: concatStringsSep "," s;
  lines = s: concatStringsSep "\n" s;
  commands = cmds:
    lines (map (cmd: "command ${cmd} ${getAttr cmd cmds}") (attrNames cmds));
in {
  options.vim = {
    runtimeDir = mkOption {
      type = types.nullOr types.path;
      description = "Add the directory to runtimepath";
      default = null;
    };

    number = mkOption {
      type = types.bool;
      description = "Print the line number in front of each line";
    };

    tabstop = mkOption {
      type = types.int;
      description = "Number of spaces that a <Tab> in the file counts for";
    };

    shiftwidth = mkOption {
      type = types.int;
      description = "Number of spaces to use for each step of (auto)indent";
    };

    scrolloff = mkOption {
      type = types.int;
      description = "Minimal number of screen lines to keep above and below the cursor";
    };

    signcolumn = mkOption {
      type = types.enum ["auto" "no" "yes" "number"];
      description = "When and how to draw the signcolumn";
    };

    colorcolumn = mkOption {
      type = types.str;
      description = "Color column";
    };

    cmdheight = mkOption {
      type = types.int;
      description = "Number of screen lines to use for the command-line";
    };

    completeopt = mkOption {
      type = types.listOf (types.enum ["menu" "menuone" "longest" "preview" "noinsert" "noselect"]);
      description = "A comma separated list of options for Insert mode completion";
    };

    omnifunc = mkOption {
      type = types.nullOr types.str;
      description = "This option specifies a function to be used for Insert mode omnicompletion with CTRL-X CTRL-O";
    };

    updatetime = mkOption {
      type = types.int;
      description = "If this many milliseconds nothing is typed the swap file will be written to disk. Also used for the CursorHold autocommand event";
    };

    commands = mkOption {
      type = types.attrsOf types.str;
      description = "Extra commands that will be created";
    };

    termguicolors = mkOption {
      type = types.bool;
      description = "Enables 24-bit RGB color in the TUI";
    };

    plenary = mkOption {
      type = types.bool;
      description = "Enable plenary";
    };

    matchup = {
      enable = mkOption {
        type = types.bool;
        description = "Enable vim-matchup";
      };
    };

    editorconfig = {
      enable = mkOption {
        type = types.bool;
        description = "Enable editorconfig-vim";
      };
    };

    headerguard = {
      enable = mkOption {
        type = types.bool;
        description = "Enable headerguard generation";
      };
    };

    kommentary = {
      enable = mkOption {
        type = types.bool;
        description = "Enable kommentary";
      };

      langs = mkOption {
        type = types.attrsOf (types.submodule {
          options = {
            prefer = mkOption {
              type = types.nullOr (types.enum ["single_line" "multi_line"]);
              default = null;
              description = "Prefer multiline or single line (or no preference if null)";
            };
          };
        });
        description = "Language specific configuration ('default' applies to all)";
      };
    };
  };

  config = {
    vim.number = mkDefault false;
    vim.tabstop = mkDefault 8;
    vim.shiftwidth = mkDefault 8;
    vim.scrolloff = mkDefault 0;
    vim.signcolumn = mkDefault "auto";
    vim.cmdheight = mkDefault 1;
    vim.colorcolumn = mkDefault "";
    vim.completeopt = mkDefault ["menu" "preview"];
    vim.omnifunc = mkDefault null;
    vim.updatetime = mkDefault 4000;
    vim.commands = mkDefault {};
    vim.termguicolors = mkDefault false;
    vim.kommentary = {
      enable = mkDefault false;
      langs = mkDefault {};
    };
    vim.matchup.enable = mkDefault false;
    vim.editorconfig.enable = mkDefault false;
    vim.headerguard.enable = mkDefault false;

    vim.startPlugins = with pkgs.neovimPlugins; [
      (
        if cfg.plenary
        then plenary
        else null
      )
      (
        if cfg.matchup.enable
        then vim-matchup
        else null
      )
      (
        if cfg.kommentary.enable
        then kommentary
        else null
      )
      (
        if cfg.editorconfig.enable
        then editorconfig
        else null
      )
      (
        if cfg.headerguard.enable
        then headerguard
        else null
      )
    ];

    vim.luaConfigRC = let
      kommentaryLangConfig = config: ''        {
              ${
          writeIf (config.prefer != null)
          "${
            if config == "single_line"
            then "prefer_single_line_comments"
            else "prefer_multi_line_comments"
          } = true,"
        }
            }'';
      kommentaryConfigs = langs:
        concatStringsSep "\n" (map
          (lang: ''
            require('kommentary.config').configure_language("${lang}", ${kommentaryLangConfig (getAttr lang langs)})
          '')
          (attrNames langs));
    in
      mkIf cfg.kommentary.enable (kommentaryConfigs cfg.kommentary.langs);

    vim.configRC = ''
       	${writeIf (cfg.runtimeDir != null) ''
        let &runtimepath.=',${cfg.runtimeDir}'
      ''}
            ${writeIf cfg.number ''
        set number
      ''}
            ${writeIf cfg.termguicolors ''
        set termguicolors
      ''}
            set tabstop=${toString cfg.tabstop}
            set shiftwidth=${toString cfg.shiftwidth}
            set scrolloff=${toString cfg.scrolloff}
            set signcolumn=${cfg.signcolumn}
            set cmdheight=${toString cfg.cmdheight}
            set completeopt=${comma cfg.completeopt}
      set colorcolumn=${cfg.colorcolumn}
            ${writeIfNotNull cfg.omnifunc (omni: ''
        set omnifunc="${omni}"
      '')}
            set updatetime=${toString cfg.updatetime}
            ${commands cfg.commands}
    '';
  };
}
