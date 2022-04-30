{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim;
  wrapLuaConfig = luaConfig: ''
    lua << EOF
    ${luaConfig}
    EOF
  '';

  mkMappingOption = it:
    mkOption ({
        default = {};
        type = with types; attrsOf (nullOr str);
      }
      // it);
in {
  options.vim = {
    viAlias = mkOption {
      description = "Enable vi alias";
      type = types.bool;
      default = true;
    };

    vimAlias = mkOption {
      description = "Enable vim alias";
      type = types.bool;
      default = true;
    };

    configRC = mkOption {
      description = "vimrc contents";
      type = types.lines;
      default = "";
    };

    startLuaConfigRC = mkOption {
      description = "start of vim lua config";
      type = types.lines;
      default = "";
    };

    luaConfigRC = mkOption {
      description = "vim lua config";
      type = types.lines;
      default = "";
    };

    startPlugins = mkOption {
      description = "List of plugins to startup";
      default = [];
      type = with types; listOf (nullOr package);
    };

    optPlugins = mkOption {
      description = "List of plugins to optionally load";
      default = [];
      type = with types; listOf package;
    };

    keymaps = let
      keymapModule = with types; {
        options = {
          rhs = mkOption {
            type = str;
          };
          desc = mkOption {
            type = nullOr str;
            default = null;
          };
          opts = {
            nowait = mkOption {
              type = bool;
              default = false;
            };
            silent = mkOption {
              type = bool;
              default = false;
            };
            script = mkOption {
              type = bool;
              default = false;
            };
            expr = mkOption {
              type = bool;
              default = false;
            };
            unique = mkOption {
              type = bool;
              default = false;
            };
            noremap = mkOption {
              type = bool;
              default = false;
            };
          };
        };
      };
    in
      mkOption {
        description = "Keymaps";
        default = [];
        type = with types;
          submodule {
            options = let
              modeOption = mode:
                mkOption {
                  type = attrsOf (submodule keymapModule);
                  description = "Keymaps for mode ${mode}";
                  default = {};
                };
            in {
              n = modeOption "normal";
              v = modeOption "visual";
            };
          };
      };
  };

  config = let
    filterOpts = opts: attrNames (filterAttrs (name: present: present) opts);
    optsArg = opts: concatStringsSep "," (map (opt: "${opt} = true") (filterOpts opts));
    formatDesc = desc:
      if desc != null
      then ",desc = \"${desc}\""
      else "";
    optsTable = desc: opts: "{${optsArg opts} ${formatDesc desc}}";
    makeMapping = lhs: mode: mapping: ''vim.api.nvim_set_keymap("${mode}","${lhs}","${mapping.rhs}",${optsTable mapping.desc mapping.opts})'';
    makeModeMapping = mode: mappings: map (lhs: makeMapping lhs mode (getAttr lhs mappings)) (attrNames mappings);
    makeMappings = mappings: concatLists (map (mode: makeModeMapping mode (getAttr mode mappings)) (attrNames mappings));
  in {
    vim.configRC = ''
      " Lua config from vim.luaConfigRC
      ${wrapLuaConfig
        (concatStringsSep "\n" [cfg.startLuaConfigRC cfg.luaConfigRC (concatStringsSep "\n" (makeMappings cfg.keymaps))])}
    '';
  };
}
