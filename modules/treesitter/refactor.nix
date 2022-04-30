{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.treesitter;
  refcfg = cfg.refactor;
  writeIf = cond: msg:
    if cond
    then msg
    else "";
  luaBool = b:
    if b
    then "true"
    else "false";
in {
  options.vim.treesitter.refactor = {
    enable = mkOption {
      type = types.bool;
      description = "Enable nvim-treesitter-refactor";
    };

    highlightDefinitions = {
      enable = mkOption {
        type = types.bool;
        description = "Highlights definition and usages of the current symbol under the cursor";
      };

      clearOnCursorMove = mkOption {
        type = types.bool;
        description = "Set to false if you have an `updatetime` of ~100";
      };
    };

    smartRename = {
      enable = mkOption {
        type = types.bool;
        description = "Renames the symbol under the cursor within the current scope (and current file)";
      };

      keymap = mkOption {
        type = types.str;
        description = "Smart rename key";
      };
    };

    highlightScope = mkOption {
      type = types.bool;
      description = "Highlights the block from the current scope where the cursor is";
    };

    navigation = {
      enable = mkOption {
        type = types.bool;
        description = "Provides \"go to definition\" for the symbol under the cursor, and lists the definitions from the current file";
      };

      gotoDefinition = mkOption {
        type = types.str;
        description = "Keymap for go to definition";
      };

      listDefinitions = mkOption {
        type = types.str;
        description = "Keymap for list definitons";
      };

      listDefinitionsToc = mkOption {
        type = types.str;
        description = "Keymap for list definitions toc";
      };

      gotoNextUsage = mkOption {
        type = types.str;
        description = "Keymap for go to next usage";
      };

      gotoPreviousUsage = mkOption {
        type = types.str;
        description = "Keymap for go to previous usage";
      };

      lspFallback = mkOption {
        type = types.bool;
        description = "Fallback to the lsp if tree-sitter can't find the symbol";
      };
    };
  };

  config =
    mkIf (cfg.enable && refcfg.enable)
    {
      vim.startPlugins = with pkgs.neovimPlugins; [nvim-treesitter-refactor];

      vim.treesitter.setup = ''
        refactor = {
          highlight_definitions = {
            enable = ${luaBool refcfg.highlightDefinitions.enable},
            clear_on_cursor_move = ${luaBool refcfg.highlightDefinitions.clearOnCursorMove},
          },
          smart_rename = {
            enable = ${luaBool refcfg.smartRename.enable},
            keymaps = {
              smart_rename = "${refcfg.smartRename.keymap}",
            },
          },
          highlight_current_scope = {
            enable = ${luaBool refcfg.highlightScope},
          },
          navigation = {
            enable = ${luaBool refcfg.navigation.enable},
            keymaps = {
              ${
          if refcfg.navigation.lspFallback
          then "goto_definition_lsp_fallback"
          else "goto_definition"
        } = "${refcfg.navigation.gotoDefinition}",
              list_definitions = "${refcfg.navigation.listDefinitions}",
              list_definitions_toc = "${refcfg.navigation.listDefinitionsToc}",
              goto_next_usage = "${refcfg.navigation.gotoNextUsage}",
              goto_previous_usage = "${refcfg.navigation.gotoPreviousUsage}",
            },
          },
        }
      '';
    };
}
