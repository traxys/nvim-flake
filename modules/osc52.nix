{
  config,
  lib,
  helpers,
  ...
}:
with lib; {
  options = {
    plugins.osc52 = {
      copy = mkOption {
        type = types.str;
        description = "Copy into the system clipboard using OSC52";
        default = "<leader>y";
      };

      copy_line = mkOption {
        type = types.str;
        description = "Copy line into the system clipboard using OSC52";
        default = "<leader>yy";
      };

      copy_visual = mkOption {
        type = types.str;
        description = "Copy visual selection into the system clipboard using OSC52";
        default = "<leader>y";
      };
    };
  };
  config = let
    cfg = config.plugins.osc52;
  in
    mkIf cfg.enable {
      maps = {
        normal = {
          "${cfg.copy}" = {
            action = "require('osc52').copy_operator";
            expr = true;
            lua = true;
          };
          "${cfg.copy_line}" = {
            action = "${cfg.copy}_";
            remap = true;
          };
        };
        visual = {
          "${cfg.copy_visual}" = {
            action = "require('osc52').copy_visual";
            lua = true;
          };
        };
      };
    };
}
