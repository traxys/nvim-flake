{
  lib,
  pkgs,
  config,
  ...
}:
with lib; {
  options.plugins.indent-blankline = {
    enable = mkEnableOption "Enable indent-blankline.nvim";

    char = mkOption {
      type = types.str;
      default = "│";
      description = ''
        Specifies the character to be used as indent line. Not used if charList is not empty.

        When set explicitly to empty string (""), no indentation character is displayed at all,
        even when 'charList' is not empty. This can be useful in combination with
        spaceCharHighlightList to only rely on different highlighting of different indentation
        levels without needing to show a special character.
      '';
    };

    charBlankline = mkOption {
      type = types.str;
      default = "";
      description = ''
        Specifies the character to be used as indent line for blanklines. Not used if
        charListBlankline is not empty.
      '';
    };

    charList = mkOption {
      type = types.listOf types.str;
      default = [];
      description = ''
        Specifies a list of characters to be used as indent line for
        each indentation level.
        Ignored if the value is an empty list.
      '';
    };

    charListBlankline = mkOption {
      type = types.listOf types.str;
      default = [];
      description = ''
        Specifies a list of characters to be used as indent line for
        each indentation level on blanklines.
        Ignored if the value is an empty list.
      '';
    };

    charHighlightList = mkOption {
      type = types.listOf types.str;
      default = [];
      description = ''
        Specifies the list of character highlights for each indentation level.
        Ignored if the value is an empty list.
      '';
    };

    spaceCharBlankline = mkOption {
      type = types.str;
      default = " ";
      description = ''
        Specifies the character to be used as the space value in between indent
        lines when the line is blank.
      '';
    };

    spaceCharHighlightList = mkOption {
      type = types.listOf types.str;
      default = [];
      description = ''
        Specifies the list of space character highlights for each indentation
        level.
        Ignored if the value is an empty list.
      '';
    };

    spaceCharBlanklineHighlightList = mkOption {
      type = types.listOf types.str;
      default = [];
      description = ''
        Specifies the list of space character highlights for each indentation
        level when the line is empty.
        Ignored if the value is an empty list.
      '';
    };

    useTreesitter = mkEnableOption "Use treesitter to calculate indentation when possible.";

    indentLevel = mkOption {
      type = types.int;
      default = 10;
      description = "Specifies the maximum indent level to display.";
    };

    maxIndentIncrease = mkOption {
      type = types.int;
      default = config.plugins.indent-blankline.indentLevel;
      description = ''
        The maximum indent level increase from line to line.
        Set this option to 1 to make aligned trailing multiline comments not
        create indentation.
      '';
    };

    showFirstIndentLevel = mkOption {
      type = types.bool;
      default = true;
      description = "Displays indentation in the first column.";
    };

    showTrailingBlanklineIndent = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Displays a trailing indentation guide on blank lines, to match the
        indentation of surrounding code.
        Turn this off if you want to use background highlighting instead of chars.
      '';
    };

    showEndOfLine = mkEnableOption ''
      Displays the end of line character set by |listchars| instead of the
      indent guide on line returns.
    '';

    showFoldtext = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Displays the full fold text instead of the indent guide on folded lines.

        Note: there is no autocommand to subscribe to changes in folding. This
              might lead to unexpected results. A possible solution for this is to
              remap folding bindings to also call |IndentBlanklineRefresh|
      '';
    };

    disableWithNolist = mkEnableOption ''
      When true, automatically turns this plugin off when |nolist| is set.
      When false, setting |nolist| will keep displaying indentation guides but
      removes whitespace characters set by |listchars|.
    '';

    filetype = mkOption {
      type = types.listOf types.str;
      default = [];
      description = ''
        Specifies a list of |filetype| values for which this plugin is enabled.
        All |filetypes| are enabled if the value is an empty list.
      '';
    };

    filetypeExclude = mkOption {
      type = types.listOf types.str;
      default = ["lspinfo" "packer" "checkhealth" "help" "man" ""];
      description = ''
        Specifies a list of |filetype| values for which this plugin is not enabled.
        Ignored if the value is an empty list.
      '';
    };

    buftypeExclude = mkOption {
      type = types.listOf types.str;
      default = ["terminal" "nofile" "quickfix" "prompt"];
      description = ''
        Specifies a list of |buftype| values for which this plugin is not enabled.
        Ignored if the value is an empty list.
      '';
    };

    bufnameExclude = mkOption {
      type = types.listOf types.str;
      default = [];
      description = ''
        Specifies a list of buffer names (file name with full path) for which
        this plugin is not enabled.
        A name can be regular expression as well.
      '';
    };

    strictTabs = mkEnableOption ''
      When on, if there is a single tab in a line, only tabs are used to
      calculate the indentation level.
      When off, both spaces and tabs are used to calculate the indentation
      level.
      Only makes a difference if a line has a mix of tabs and spaces for
      indentation.
    '';

    showCurrentContext = mkEnableOption ''
      When on, use treesitter to determine the current context. Then show the
      indent character in a different highlight.

      Note: Requires https://github.com/nvim-treesitter/nvim-treesitter to be
            installed

      Note: With this option enabled, the plugin refreshes on |CursorMoved|,
            which might be slower
    '';

    showCurrentContextStart = mkEnableOption ''
      Applies the |hl-IndentBlanklineContextStart| highlight group to the first
      line of the current context.
      By default this will underline.

      Note: Requires https://github.com/nvim-treesitter/nvim-treesitter to be
            installed

      Note: You need to have set |gui-colors| and it depends on your terminal
            emulator if this works as expected.
            If you are using kitty and tmux, take a look at this article to
            make it work
            http://evantravers.com/articles/2021/02/05/curly-underlines-in-kitty-tmux-neovim/
    '';

    showCurrentContextStartOnCurrentLine = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Shows showCurrentContextStart even when the cursor is on the same line
      '';
    };

    contextChar = mkOption {
      type = types.str;
      default = config.plugins.indent-blankline.char;
      description = ''
        Specifies the character to be used for the current context indent line.
        Not used if contextCharList is not empty.

        Useful to have a greater distinction between the current context indent
        line and others.

        Also useful in combination with char set to empty string
        (""), as this allows only the current context indent line to be shown.
      '';
    };

    contextCharBlankline = mkOption {
      type = types.str;
      default = "";
      description = ''
        Equivalent of charBlankline for contextChar.
      '';
    };

    contextCharList = mkOption {
      type = types.listOf types.str;
      default = [];
      description = ''
        Equivalent of charList for contextChar.
      '';
    };

    contextCharListBlankline = mkOption {
      type = types.listOf types.str;
      default = [];
      description = ''
        Equivalent of charListBlankline for contextChar.
      '';
    };

    contextHighlightList = mkOption {
      type = types.listOf types.str;
      default = [];
      description = ''
        Specifies the list of character highlights for the current context at
        each indentation level.
        Ignored if the value is an empty list.
      '';
    };

    charPriority = mkOption {
      type = types.int;
      default = 1;
      description = "Specifies the |extmarks| priority for chars.";
    };

    contextStartPriority = mkOption {
      type = types.int;
      default = 10000;
      description = "Specifies the |extmarks| priority for the context start.";
    };

    contextPatterns = mkOption {
      type = types.listOf types.str;
      default = [
        "class"
        "^func"
        "method"
        "^if"
        "while"
        "for"
        "with"
        "try"
        "except"
        "arguments"
        "argument_list"
        "object"
        "dictionary"
        "element"
        "table"
        "tuple"
        "do_block"
      ];
      description = ''
        Specifies a list of lua patterns that are used to match against the
        treesitter |tsnode:type()| at the cursor position to find the current
        context.

        To learn more about how lua pattern work, see here:
        https://www.lua.org/manual/5.1/manual.html#5.4.1

      '';
    };

    useTreesitterScope = mkEnableOption ''
      Instead of using contextPatters use the current scope defined by nvim-treesitter as the
      context
    '';

    contextPatternHighlight = mkOption {
      type = types.attrsOf types.str;
      default = {};
      description = ''
        Specifies a map of patterns set in contextPatterns to highlight groups.
        When the current matching context pattern is in the map, the context
        will be highlighted with the corresponding highlight group.
      '';
    };

    viewportBuffer = mkOption {
      type = types.int;
      default = 10;
      description = ''
        Sets the buffer of extra lines before and after the current viewport that
        are considered when generating indentation and the context.
      '';
    };

    disableWarningMessage = mkEnableOption "Turns deprecation warning messages off.";
  };

  config = let
    cfg = config.plugins.indent-blankline;
  in
    mkIf cfg.enable {
      extraPlugins = with pkgs.vimPlugins; [indent-blankline-nvim];

      globals = {
        indent_blankline_char = cfg.char;
        indent_blankline_char_blankline = cfg.charBlankline;
        indent_blankline_char_list = cfg.charList;
        indent_blankline_char_list_blankline = cfg.charListBlankline;
        indent_blankline_char_highlight_list = cfg.charHighlightList;
        indent_blankline_space_char_blankline = cfg.spaceCharBlankline;
        indent_blankline_space_char_highlight_list = cfg.spaceCharHighlightList;
        indent_blankline_space_char_blankline_highlight_list = cfg.spaceCharBlanklineHighlightList;
        indent_blankline_use_treesitter = cfg.useTreesitter;
        indent_blankline_indent_level = cfg.indentLevel;
        indent_blankline_max_indent_increase = cfg.maxIndentIncrease;
        indent_blankline_show_first_indent_level = cfg.showFirstIndentLevel;
        indent_blankline_show_trailing_blankline_indent = cfg.showTrailingBlanklineIndent;
        indent_blankline_show_end_of_line = cfg.showEndOfLine;
        indent_blankline_show_foldtext = cfg.showFoldtext;
        indent_blankline_disable_with_nolist = cfg.disableWithNolist;
        indent_blankline_filetype = cfg.filetype;
        indent_blankline_filetype_exclude = cfg.filetypeExclude;
        indent_blankline_buftype_exclude = cfg.buftypeExclude;
        indent_blankline_bufname_exclude = cfg.bufnameExclude;
        indent_blankline_strict_tabs = cfg.strictTabs;
        indent_blankline_show_current_context = cfg.showCurrentContext;
        indent_blankline_show_current_context_start = cfg.showCurrentContextStart;
        indent_blankline_show_current_context_start_on_current_line = cfg.showCurrentContextStartOnCurrentLine;
        indent_blankline_context_char = cfg.contextChar;
        indent_blankline_context_char_blankline = cfg.contextCharBlankline;
        indent_blankline_context_char_list = cfg.contextCharList;
        indent_blankline_context_char_list_blankline = cfg.contextCharListBlankline;
        indent_blankline_context_highlight_list = cfg.contextHighlightList;
        indent_blankline_char_priority = cfg.charPriority;
        indent_blankline_context_start_priority = cfg.contextStartPriority;
        indent_blankline_context_patterns = cfg.contextPatterns;
        indent_blankline_use_treesitter_scope = cfg.useTreesitterScope;
        indent_blankline_context_pattern_highlight = cfg.contextPatternHighlight;
        indent_blankline_viewport_buffer = cfg.viewportBuffer;
        indent_blankline_disable_warning_message = cfg.disableWarningMessage;
      };
    };
}
