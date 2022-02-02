{ config, lib, pkgs, ... }:

with lib;
with builtins;
let
  cfg = config.vim.git;
in
{
  options.vim.git = {
    signs = {
      enable = mkOption {
        type = types.bool;
        description = "Enable Gitsigns";
      };
    };
  };

  config = {
    vim.startPlugins = with pkgs.neovimPlugins;
      if (cfg.signs.enable) then [ gitsigns ] else [ ];

    vim.luaConfigRC = mkIf (cfg.signs.enable) ''
      require("gitsigns").setup()
    '';
  };
}
