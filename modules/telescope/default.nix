{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.vim.telescope;
in
{
  options.vim.telescope.enable = mkOption {
    type = types.bool;
    description = "Enable telescope.nvim";
	default = false;
  };

  config = mkIf cfg.enable {
    vim.plenary = true;
    vim.startPlugins = with pkgs.neovimPlugins; [ telescope ];
  };
}
