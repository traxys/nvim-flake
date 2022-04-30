{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.theme;
in {
  options.vim.theme = {
    enable = mkOption {
      type = types.bool;
      description = "Enable Theme";
    };

    name = mkOption {
      type = types.enum ["moonfly"];
      description = ''Name of theme to use: "moonfly"'';
    };
  };

  config =
    mkIf cfg.enable
    (
      let
        mkVimBool = val:
          if val
          then "1"
          else "0";
      in {
        vim.configRC = ''
          colorscheme ${cfg.name}
        '';

        vim.startPlugins = with pkgs.neovimPlugins; [vim-moonfly-colors];
      }
    );
}
