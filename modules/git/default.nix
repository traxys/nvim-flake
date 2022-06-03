{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.git;
in {
  options.vim.git = {
    signs = {
      enable = mkOption {
        type = types.bool;
		default = false;
        description = "Enable Gitsigns";
      };
    };
    messenger = {
      enable = mkOption {
        type = types.bool;
		default = false;
        description = "Enable git messenge";
      };
    };
  };

  config = {
    vim.startPlugins = with pkgs.neovimPlugins; [
      (
        if (cfg.signs.enable)
        then gitsigns
        else null
      )
      (
        if (cfg.messenger.enable)
        then git-messenger
        else null
      )
    ];

    vim.luaConfigRC = mkIf (cfg.signs.enable) ''
      require("gitsigns").setup()
    '';
  };
}
