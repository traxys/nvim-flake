{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.statusline;
  highlightModule = with types; {
    options = {
      fg = mkOption {
        type = str;
        description = "Foreground color";
      };
      bg = mkOption {
        type = str;
        description = "Background color";
      };
      style = mkOption {
        type = nullOr (enum [
          "bold"
          "underline"
          "undercurl"
          "strikethrough"
          "reverse"
          "italic"
          "standout"
        ]);
        description = "Style for the color";
        default = null;
      };
    };
  };

  componentModule = with types; {
    options = {
      name = mkOption {
        type = str;
        description = "Name of this component";
      };

      provider = mkOption {
        type = str;
        description = "Provider for this component";
      };

      highlight = mkOption {
        type = submodule highlightModule;
        description = "Highlight for this component";
      };

      separator = mkOption {
        type = nullOr str;
        description = "Separator for this component";
        default = null;
      };
      separatorHighlight = mkOption {
        type = nullOr (submodule highlightModule);
        description = "Highlight for the separator";
        default = null;
      };

      icon = mkOption {
        type = nullOr str;
        description = "Icon for the component";
        default = null;
      };

      condition = mkOption {
        type = nullOr str;
        description = "Condition to activate this component";
        default = null;
      };
    };
  };
in {
  options.vim.statusline = {
    enable = mkOption {
      type = types.bool;
      description = "Enable statusline";
    };

    lspIntegration = mkOption {
      type = types.bool;
      description = "Enable statusline lsp integration";
    };

    helpers = mkOption {
      type = types.lines;
      description = "Helpers for components";
    };

    sections = {
      left = mkOption {
        type = types.listOf (types.submodule componentModule);
        description = "Left side of the status bar";
      };

      right = mkOption {
        type = types.listOf (types.submodule componentModule);
        description = "Right side of the status bar";
      };
    };
  };

  config = mkIf cfg.enable {
    vim.startPlugins = with pkgs.neovimPlugins; [
      galaxyline
    ];

    vim.luaConfigRC = let
      writeIf = cond: msg:
        if cond
        then msg
        else "";
      genHighlight = hi: "{${hi.fg}, ${hi.bg} ${writeIf (hi.style != null) '', "${hi.style}"''}}";
      genComponent = component: ''
          { ["${component.name}"] = {
            provider = ${component.provider},
            highlight = ${genHighlight component.highlight},
            ${writeIf (component.separator != null) "separator = ${component.separator},"}
            ${writeIf (component.separatorHighlight != null) "separator_highlight = ${genHighlight component.separatorHighlight},"}
        ${writeIf (component.condition != null) "condition = ${component.condition},"}
        ${writeIf (component.icon != null) "icon = ${component.icon},"}
          }}
      '';
      genSection = section: "{${concatStringsSep "," (map genComponent section)}}";
    in ''
      local gl = require("galaxyline")

      ${cfg.helpers}

      gl.section.left = ${genSection cfg.sections.left}

      gl.section.right = ${genSection cfg.sections.right}
    '';
  };
}
