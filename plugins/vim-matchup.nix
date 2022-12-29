{
  pkgs,
  config,
  lib,
  ...
}:
with lib; {
  options.plugins.vim-matchup = {
    enable = mkEnableOption "Enable vim-matchup";

    matchParen = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Control matching parentheses";
      };

      fallback = mkOption {
        type = types.bool;
        default = true;
        description = ''
          If matchParen is not enabled fallback to the standard vim matchparen.
        '';
      };

      singleton = mkOption {
        type = types.bool;
        default = false;
        description = "Whether to highlight known words even if there is no match";
      };

      offscreen = mkOption {
        type = types.nullOr (types.submodule {
          options = {
            method = mkOption {
              type = types.enum ["status" "popup" "status_manual"];
              default = "status";
              description = ''
                'status': Replace the status-line for off-screen matches.

                If a match is off of the screen, the line belonging to that match will be displayed
                syntax-highlighted in the status line along with the line number (if line numbers
                are enabled). If the match is above the screen border, an additional Δ symbol will
                be shown to indicate that the matching line is really above the cursor line.

                'popup': Show off-screen matches in a popup (vim) or floating (neovim) window.

                'status_manual': Compute the string which would be displayed in the status-line or
                popup, but do not display it. The function MatchupStatusOffscreen() can be used to
                get the text.
              '';
            };
            scrolloff = mkOption {
              type = types.bool;
              default = false;
              description = ''
                When enabled, off-screen matches will not be shown in the statusline while the
                cursor is at the screen edge (respects the value of 'scrolloff').
                This is intended to prevent flickering while scrolling with j and k.
              '';
            };
          };
        });
        default = {method = "status";};
        description = "Dictionary controlling the behavior with off-screen matches.";
      };

      stopline = mkOption {
        type = types.int;
        default = 400;
        description = ''
          The number of lines to search in either direction while highlighting matches.
          Set this conservatively since high values may cause performance issues.
        '';
      };

      timeout = mkOption {
        type = types.int;
        default = 300;
        description = "Adjust timeouts in milliseconds for matchparen highlighting";
      };

      insertTimeout = mkOption {
        type = types.int;
        default = 60;
        description = "Adjust timeouts in milliseconds for matchparen highlighting";
      };

      deffered = {
        enable = mkOption {
          type = types.bool;
          default = false;
          description = ''
            Deferred highlighting improves cursor movement performance (for example, when using hjkl)
            by delaying highlighting for a short time and waiting to see if the cursor continues
            moving
          '';
        };

        showDelay = mkOption {
          type = types.int;
          default = 50;
          description = ''
            Adjust delays in milliseconds for deferred highlighting
          '';
        };

        hideDelay = mkOption {
          type = types.int;
          default = 700;
          description = ''
            Adjust delays in milliseconds for deferred highlighting
          '';
        };
      };

      hiSurroundAlways = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Highlight surrounding delimiters always as the cursor moves
          Note: this feature requires deferred highlighting to be supported and enabled.
        '';
      };
    };

    motion = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Control motions";
      };
      overrideNPercent = mkOption {
        type = types.int;
        default = 6;
        description = ''
          In vim, {count}% goes to the {count} percentage in the file. match-up overrides this
          motion for small {count} (by default, anything less than 7). To allow {count}% for {count}
          less than 12 set overrideNPercent to 11.

          To disable this feature set it to 0.

          To always enable this feature, use any value greater than 99
        '';
      };
      cursorEnd = mkOption {
        type = types.bool;
        default = true;
        description = ''
          If enabled, cursor will land on the end of mid and close words while moving downwards
          (%/]%). While moving upwards (g%, [%) the cursor will land on the beginning.
        '';
      };
    };

    textObj = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Controls text objects";
      };

      linewiseOperators = mkOption {
        type = types.listOf types.str;
        default = ["d" "y"];
        description = "Modify the set of operators which may operate line-wise";
      };
    };

    enableSurround = mkOption {
      type = types.bool;
      default = false;
      description = "To enable the delete surrounding (ds%) and change surrounding (cs%) maps";
    };

    enableTransmute = mkOption {
      type = types.bool;
      default = false;
      description = "To enable the experimental transmute module";
    };

    delimStopline = mkOption {
      type = types.int;
      default = 1500;
      description = ''
        To configure the number of lines to search in either direction while using motions and text
        objects. Does not apply to match highlighting (see matchParenStopline instead)
      '';
    };

    delimNoSkips = mkOption {
      type = types.enum [0 1 2];
      default = 0;
      description = ''
        To disable matching within strings and comments:
        - 0: matching is enabled within strings and comments
        - 1: recognize symbols within comments
        - 2: don't recognize anything in comments
      '';
    };
  };

  config = let
    cfg = config.plugins.vim-matchup;
  in
    mkIf cfg.enable {
      extraPlugins = with pkgs.vimPlugins; [vim-matchup];
      globals = {
        matchup_surround_enabled = cfg.enableSurround;
        matchup_transmute_enabled = cfg.enableTransmute;

        matchup_delim_stopline = cfg.delimStopline;
        matchup_delim_noskips = cfg.delimNoSkips;

        matchup_matchparen_enabled = cfg.matchParen.enable;
        matchup_matchparen_fallback = cfg.matchParen.fallback;
        matchup_matchparen_offscreen = cfg.matchParen.offscreen;
        matchup_matchparen_stopline = cfg.matchParen.stopline;
        matchup_matchparen_timeout = cfg.matchParen.timeout;
        matchup_matchparen_insert_timeout = cfg.matchParen.insertTimeout;
        matchup_matchparen_deferred = cfg.matchParen.deffered.enable;
        matchup_matchparen_deferred_show_delay = cfg.matchParen.deffered.showDelay;
        matchup_matchparen_deferred_hide_delay = cfg.matchParen.deffered.hideDelay;
        matchup_matchparen_hi_surround_always = cfg.matchParen.hiSurroundAlways;

        matchup_motion_enabled = cfg.motion.enable;
        matchup_motion_override_Npercent = cfg.motion.overrideNPercent;
        matchup_motion_cursor_end = cfg.motion.cursorEnd;

        matchup_text_obj_enabled = cfg.textObj.enable;
        matchup_text_obj_linewise_operators = cfg.textObj.linewiseOperators;
      };
    };
}
