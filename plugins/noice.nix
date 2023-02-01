{
  lib,
  pkgs,
  helpers,
  config,
  ...
}:
with lib; {
  options.plugins.noice = {
    enable = mkEnableOption "noice.nvim, an experimental nvim UI";

    package = helpers.mkPackageOption "noice" pkgs.vimPlugins.noice-nvim;

    lsp = {
      override = mkOption {
        type = types.attrsOf types.bool;
        default = {};
      };
    };

    presets = mkOption {
      type = types.attrsOf types.bool;
      default = {};
    };
  };

  config = let
    cfg = config.plugins.noice;
    setupOptions = {
      inherit (cfg) presets;
      lsp = {override = cfg.lsp.override;};
    };
  in
    mkIf cfg.enable {
      extraPlugins = [cfg.package];
      extraConfigLua = ''
        require("noice").setup(${helpers.toLuaObject setupOptions})
      '';
    };
}
