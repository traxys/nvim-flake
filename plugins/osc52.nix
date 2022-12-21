{
  pkgs,
  lib,
  config,
  helpers,
  ...
}:
with lib; {
  options = {
    plugins.osc52 = {
      enable = mkEnableOption "Enable OSC52 support";
      maxLength = mkOption {
        type = types.nullOr types.int;
        default = null;
        description = "Maximum length of selection";
      };
      silent = mkEnableOption "Disable message on successful copy";
      trim = mkEnableOption "Trim text before copy";
    };
  };

  config = let
    cfg = config.plugins.osc52;
    setupOptions = with cfg; {
      inherit silent trim;
      max_length = maxLength;
    };
  in
    mkIf cfg.enable {
      extraConfigLua = ''
        require('osc52').setup(${helpers.toLuaObject setupOptions})
      '';

      extraPlugins = with pkgs.vimPlugins; [
        nvim-osc52
      ];
    };
}
