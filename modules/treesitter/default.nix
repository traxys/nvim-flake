{ config, lib, pkgs, ... }:

with lib;
with builtins;

let
  cfg = config.vim.treesitter;
  writeIf = cond: msg: if cond then msg else "";
  luaList = l: concatStringsSep "," (map (s: ''"${s}"'') l);
  luaBool = b: if b then "true" else "false";
in
{
  imports = [ ./config.nix ./refactor.nix ];

  options.vim.treesitter = {
    enable = mkOption {
      type = types.bool;
      description = "enable nvim-treesitter";
    };

    indent = mkOption {
      type = types.bool;
      description = "Indentation based on treesitter for the = operator. NOTE: This is an experimental feature";
    };

    ensureInstalled = mkOption {
      type = types.listOf types.str;
      description = "Languages to be installed";
    };

    highlightDisabled = mkOption {
      type = types.listOf types.str;
      description = "Languages to skip highlighting";
    };

    setup = mkOption {
      type = types.commas;
      description = "content of treesitter setup";
      default = "";
    };
  };

  config = mkIf cfg.enable {
    vim.startPlugins = with pkgs.neovimPlugins; [ nvim-treesitter ];

    vim.treesitter.setup = ''
      indent = {
        enable = ${luaBool cfg.indent},
      },
      ensure_installed = {${luaList cfg.ensureInstalled}},
      highlight = {
        enable = true,
        disable = {${luaList cfg.highlightDisabled}},
      }
    '';

    vim.luaConfigRC = ''
      require("nvim-treesitter.configs").setup({
        ${cfg.setup}
      })
    '';
  };
}
