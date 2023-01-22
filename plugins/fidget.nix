{
  lib,
  helpers,
  config,
  pkgs,
  ...
}:
with lib; let
  borderOpt = let
    bordersTy =
      types.enum ["double" "rounded" "single" "shadow" "none"];
  in
    helpers.defaultNullOpts.mkNullable (types.either bordersTy (types.listOf bordersTy))
    ''"none"'';
in {
  options.plugins.fidget = {
    enable = mkEnableOption "fidget.nvim, a standalone UI for nvim-lsp progress";

    package = mkOption {
      type = types.package;
      default = pkgs.vimPlugins.fidget-nvim;
      description = "Plugin to use for fidget.nvim";
    };

    text = {
      spinner = let
        spinnerList = [
          "dots"
          "dots_negative"
          "dots_snake"
          "dots_footsteps"
          "dots_hop"
          "line"
          "pipe"
          "dots_ellipsis"
          "dots_scrolling"
          "star"
          "flip"
          "hamburger"
          "grow_vertical"
          "grow_horizontal"
          "noise"
          "dots_bounce"
          "triangle"
          "arc"
          "circle"
          "square_corners"
          "circle_quarters"
          "circle_halves"
          "dots_toggle"
          "box_toggle"
          "arrow"
          "zip"
          "bouncing_bar"
          "bouncing_ball"
          "clock"
          "earth"
          "moon"
          "dots_pulse"
          "meter"
        ];
      in
        helpers.defaultNullOpts.mkNullable
        (types.either (types.enum spinnerList) (types.listOf types.str)) ''"pipe"'' ''
          Animation shown in fidget title when its tasks are ongoing. Can either be the name of
          one of the predefined fidget-spinners, or an array of strings representing each frame
          of the animation.
        '';
      done = helpers.defaultNullOpts.mkStr "✔" ''
        Text shown in fidget title when all its tasks are completed, i.e., it has no more tasks.
      '';
      commenced = helpers.defaultNullOpts.mkStr "Started" ''
        Message shown when a task starts.
      '';
      completed = helpers.defaultNullOpts.mkStr "Completed" ''
        Message shown when a task completes.
      '';
    };

    align = {
      bottom = helpers.defaultNullOpts.mkBool true ''
        Whether to align fidgets along the bottom edge of each buffer.
      '';
      right = helpers.defaultNullOpts.mkBool true ''
        Whether to align fidgets along the right edge of each buffer. Setting this to false is not
        recommended, since that will lead to the fidget text being regularly overlaid on top of
        buffer text (which is supported but unsightly).
      '';
    };

    window = {
      relative = helpers.defaultNullOpts.mkNullable (types.enum ["win" "editor"]) ''"win"'' ''
        Whether to position the window relative to the current window, or the editor.
      '';
      blend = helpers.defaultNullOpts.mkInt 100 ''
        The value to use for &winblend for the window, to adjust transparency.
      '';
      zindex = helpers.defaultNullOpts.mkNullable types.int "null" ''
        The value to use for zindex (see :h nvim_win_open) for the window.
      '';
      border = borderOpt ''
        The value to use for the window border (see :h nvim_win_open), to adjust the Fidget window
        border style.
      '';
    };

    timer = {
      spinnerRate = helpers.defaultNullOpts.mkInt 125 ''
        Duration of each frame of the spinner animation, in ms. Set to 0 to only use the first frame
        of the spinner animation.
      '';
      fidgetDecay = helpers.defaultNullOpts.mkInt 2000 ''
        How long to continue showing a fidget after all its tasks are completed, in ms. Set to 0 to
        clear each fidget as soon as all its tasks are completed; set to any negative number to keep
        it around indefinitely (not recommended).
      '';
      taskDecay = helpers.defaultNullOpts.mkInt 1000 ''
        How long to continue showing a task after it is complete, in ms. Set to 0 to clear each
        task as soon as it is completed; set to any negative number to keep it around until its
        fidget is cleared.
      '';
    };

    fmt = {
      leftpad = helpers.defaultNullOpts.mkBool true ''
        Whether to right-justify the text in a fidget box by left-padding it with spaces.
        Recommended when align.right is true.
      '';
      stackUpwards = helpers.defaultNullOpts.mkBool true ''
        Whether the list of tasks should grow upward in a fidget box. With this set to true, fidget
        titles tend to jump around less.
      '';
      maxWidth = helpers.defaultNullOpts.mkInt 0 ''
        Maximum width of the fidget box; longer lines are truncated. If this option is set to 0,
        then the width of the fidget box will be limited only by that of the focused window/editor
        (depending on window.relative).
      '';
      fidget =
        helpers.defaultNullOpts.mkNullable types.str ''
          function(fidget_name, spinner)
            return string.format("%s %s", spinner, fidget_name)
          end,
        '' ''
          Function used to format the title of a fidget. Given two arguments: the name of the
          fidget, and the current frame of the spinner. Returns the formatted fidget title.
        '';
      task =
        helpers.defaultNullOpts.mkNullable types.str ''
          function(task_name, message, percentage)
            return string.format(
              "%s%s [%s]",
              message,
              percentage and string.format(" (%s%%)", percentage) or "",
              task_name
            )
          end,
        '' ''
          Function used to format the status of each task. Given three arguments: the name of the
          task, its message, and its progress as a percentage. Returns the formatted task status. If
          this value is false, don't show tasks at all.
        '';
    };

    sources =
      helpers.defaultNullOpts.mkNullable (types.attrsOf (types.submodule {
        options = {
          ignore = helpers.defaultNullOpts.mkBool false ''
            Disable fidgets from this source.
          '';
        };
      })) "{}" ''
        Options for fidget source.
      '';

    debug = {
      logging = helpers.defaultNullOpts.mkBool false ''
        Whether to enable logging, for debugging. The log is written to
        ~/.local/share/fidget.nvim.log.
      '';

      strict = helpers.defaultNullOpts.mkBool false ''
        Whether this plugin should follow a strict interpretation of the LSP protocol, e.g.,
        notifications missing the kind field.

        Setting this to false (the default) will likely lead to more sensible behavior with
        non-conforming language servers, but may mask server misbehavior.
      '';
    };
  };

  config = let
    cfg = config.plugins.fidget;
    setupOptions = {
      text = {
        spinner = cfg.text.spinner;
        done = cfg.text.done;
        commenced = cfg.text.commenced;
        completed = cfg.text.completed;
      };
      align = {
        bottom = cfg.align.bottom;
        right = cfg.align.right;
      };
      window = {
        relative = cfg.window.relative;
        blend = cfg.window.blend;
        zindex = cfg.window.zindex;
        border = cfg.window.border;
      };
      timer = {
        spinner_rate = cfg.timer.spinnerRate;
        fidget_decay = cfg.timer.fidgetDecay;
        task_decay = cfg.timer.taskDecay;
      };
      fmt = {
        leftpad = cfg.fmt.leftpad;
        stack_upwards = cfg.fmt.stackUpwards;
        max_width = cfg.fmt.maxWidth;
        fidget =
          if cfg.fmt.fidget != null
          then {__raw = cfg.fmt.fidget;}
          else null;
        task =
          if cfg.fmt.task != null
          then {__raw = cfg.fmt.task;}
          else null;
      };
      sources =
        if cfg.sources != null
        then
          lib.attrsets.mapAttrs (source: srcOptions: {
            ignore = srcOptions.ignore;
          })
          cfg.sources
        else null;

      debug = {
        logging = cfg.debug.logging;
        strict = cfg.debug.strict;
      };
    };
  in
    mkIf cfg.enable {
      extraPlugins = [cfg.package];
      extraConfigLua = ''
        require("fidget").setup(${helpers.toLuaObject setupOptions})
      '';
    };
}
