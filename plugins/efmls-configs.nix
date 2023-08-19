{
  config,
  pkgs,
  helpers,
  lib,
  ...
}:
with lib; {
  options.plugins.efmls-configs = {
    enable = mkEnableOption "efmls-configs, premade configurations for efm-langserver";

    package = helpers.mkPackageOption "efmls-configs-nvim" pkgs.vimPlugins.efmls-configs-nvim;
  };

  config = let
    cfg = config.plugins.efmls-configs;
  in
    mkIf cfg.enable {
      extraPlugins = [cfg.package];

      extraPackages = [pkgs.efm-langserver];
    };
}
