{
  pkgs,
  lib,
  config,
  helpers,
  ...
}:
with lib; {
  options.plugins.nvim-lightbulb = {
    enable = mkEnableOption "Enable nvim-lightbulb, showing available code actions";

    package = mkOption {
      type = types.package;
      default = pkgs.vimPlugins.nvim-lightbulb;
      description = "Plugin to use for nvim-lightbulb";
    };

    ignore = mkOption {
      type = types.nullOr (types.listOf types.str);
      default = null;
      description = ''
        LSP client names to ignore

        default: `[]`
      '';
    };

    sign = {
      enabled = mkOption {
        type = types.nullOr types.bool;
        default = null;
        description = ''
          default: `true`
        '';
      };
      priority = mkOption {
        type = types.nullOr types.int;
        default = null;
        description = ''
          default: `10`
        '';
      };
    };

    float = {
      enabled = mkOption {
        type = types.nullOr types.bool;
        default = null;
        description = ''
          default: `false`
        '';
      };

      text = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = ''
          default: `"💡"`
        '';
      };

      winOpts = mkOption {
        type = types.nullOr (types.attrsOf types.anything);
        default = null;
        description = ''
          Options for the floating window (see |vim.lsp.util.open_floating_preview| for more information)

          default: `{}`
        '';
      };
    };

    virtualText = {
      enabled = mkOption {
        type = types.nullOr types.bool;
        default = null;
        description = ''
          default: `false`
        '';
      };

      text = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = ''
          default: `"💡"`
        '';
      };

      hlMode = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = ''
          highlight mode to use for virtual text (replace, combine, blend), see
          :help nvim_buf_set_extmark() for reference

          default: `"replace"`
        '';
      };
    };

    statusText = {
      enabled = mkOption {
        type = types.nullOr types.bool;
        default = null;
        description = ''
          default: `false`
        '';
      };

      text = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = ''
          Text to provide when code actions are available

          default: `"💡"`
        '';
      };

      textUnavailable = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = ''
          Text to provide when no actions are available

          default: `""`
        '';
      };
    };

    autocmd = {
      enabled = mkOption {
        type = types.nullOr types.bool;
        default = null;
        description = ''
          default: `false`
        '';
      };

      pattern = mkOption {
        type = types.nullOr (types.listOf types.str);
        default = null;
        description = ''
          default: `["*"]`
        '';
      };

      events = mkOption {
        type = types.nullOr (types.listOf types.str);
        default = null;
        description = ''
          default: `["CursorHold" "CursorHoldI"]`
        '';
      };
    };
  };

  config = let
    cfg = config.plugins.nvim-lightbulb;
    setupOptions = {
      inherit (cfg) ignore sign autocmd;
      float = {
        inherit (cfg.float) enabled text;
        win_opts = cfg.float.winOpts;
      };
      virtual_text = {
        inherit (cfg.virtualText) enabled text;
        hl_mode = cfg.virtualText.hlMode;
      };
      status_text = {
        inherit (cfg.statusText) enabled text;
        text_unavailable = cfg.statusText.textUnavailable;
      };
    };
  in
    mkIf cfg.enable {
      extraPlugins = [cfg.package];
      extraConfigLua = ''
        require("nvim-lightbulb").setup(${helpers.toLuaObject setupOptions})
      '';
    };
}
