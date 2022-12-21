{
  lib,
  config,
  ...
}:
with lib; {
  options = {
    lua_keymaps = let
      keymapModule = with types; {
        options = {
          rhs = mkOption {
            type = str;
          };
          desc = mkOption {
            type = nullOr str;
            default = null;
          };
          lua = mkOption {
            type = bool;
            default = false;
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
            remap = mkOption {
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

  config.extraConfigLua = let
    filterOpts = opts: attrNames (filterAttrs (name: present: present) opts);
    optsArg = opts: concatStringsSep "," (map (opt: "${opt} = true") (filterOpts opts));
    formatDesc = desc:
      if desc != null
      then ",desc = \"${desc}\""
      else "";
    optsTable = desc: opts: "{${optsArg opts} ${formatDesc desc}}";
    makeRhs = mapping:
      if mapping.lua
      then mapping.rhs
      else ''"${mapping.rhs}"'';
    makeMapping = lhs: mode: mapping: ''vim.keymap.set("${mode}","${lhs}",${makeRhs mapping},${optsTable mapping.desc mapping.opts})'';
    makeModeMapping = mode: mappings: map (lhs: makeMapping lhs mode (getAttr lhs mappings)) (attrNames mappings);
    makeMappings = mappings: concatLists (map (mode: makeModeMapping mode (getAttr mode mappings)) (attrNames mappings));
  in
    concatStringsSep "\n" (makeMappings config.lua_keymaps);
}
