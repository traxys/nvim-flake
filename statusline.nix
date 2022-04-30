let
  quote = s: ''"${s}"'';

  rawColors = {
    bg = "#282c34";
    yellow = "#fabd2f";
    cyan = "#008080";
    darkblue = "#081633";
    green = "#afd700";
    orange = "#FF8800";
    purple = "#5d4d7a";
    magenta = "#d16d9e";
    grey = "#c0c0c0";
    blue = "#0087d7";
    red = "#ec5f67";
    violet = "#6860e7";
  };
  colors = builtins.mapAttrs (name: s: quote s) rawColors;

  constantProvider = cst: ''
    function()
      return ${cst}
    end
  '';
  eitherProvider = cond: tr: fl: ''
    function()
      if ${cond} then
        return ${tr}
      end
      return ${fl}
    end
  '';
in {
  vim.statusline = {
    enable = true;

    lspIntegration = true;

    helpers = ''
      local fileinfo = require("galaxyline.providers.fileinfo")

      ${builtins.readFile ./statusline.lua}
    '';

    sections = {
      left = [
        {
          name = "FirstElement";
          provider = constantProvider (quote "▋");
          highlight = {
            fg = colors.blue;
            bg = colors.yellow;
          };
        }

        {
          name = "ViMode";
          provider = "mode_provider";
          separator = quote "";
          separatorHighlight = {
            fg = colors.yellow;
            bg = eitherProvider "not buffer_not_empty()" colors.purple colors.darkblue;
          };
          highlight = {
            fg = colors.violet;
            bg = colors.yellow;
            style = "bold";
          };
        }

        {
          name = "FileIcon";
          provider = quote "FileIcon";
          condition = "buffer_not_empty";
          highlight = {
            fg = "fileinfo.get_file_icon_color";
            bg = colors.darkblue;
          };
        }

        {
          name = "FileName";
          provider = quote "FileName";
          condition = "buffer_not_empty";
          separator = quote "";
          separatorHighlight = {
            fg = colors.purple;
            bg = colors.darkblue;
          };
          highlight = {
            fg = colors.magenta;
            bg = colors.darkblue;
          };
        }

        {
          name = "GitIcon";
          provider = constantProvider (quote "  ");
          condition = "buffer_not_empty";
          highlight = {
            fg = colors.orange;
            bg = colors.purple;
          };
        }

        {
          name = "GitBranch";
          provider = quote "GitBranch";
          condition = "buffer_not_empty";
          highlight = {
            fg = colors.grey;
            bg = colors.purple;
          };
        }

        {
          name = "GitModified";
          provider = "is_file_diff";
          highlight = {
            fg = colors.green;
            bg = colors.purple;
          };
        }

        {
          name = "LeftEnd";
          provider = constantProvider (quote "");
          highlight = {
            fg = colors.purple;
            bg = colors.purple;
          };
          separator = quote "";
          separatorHighlight = {
            fg = colors.purple;
            bg = colors.bg;
          };
        }
      ];

      right = [
        {
          name = "LspText";
          provider = constantProvider (quote "");
          separator = quote "";
          separatorHighlight = {
            fg = colors.darkblue;
            bg = colors.bg;
          };
          highlight = {
            fg = colors.grey;
            bg = colors.darkblue;
          };
        }

        {
          name = "LspError";
          provider = "lsp_diag_error";
          condition = "has_lsp";
          icon = quote " ";
          highlight = {
            fg = colors.grey;
            bg = colors.darkblue;
          };
        }

        {
          name = "LspWarning";
          provider = "lsp_diag_warn";
          condition = "has_lsp";
          icon = quote " ";
          highlight = {
            fg = colors.grey;
            bg = colors.darkblue;
          };
        }

        {
          name = "LspInfo";
          provider = "lsp_diag_info";
          condition = "has_lsp";
          icon = quote " ";
          highlight = {
            fg = colors.grey;
            bg = colors.darkblue;
          };
        }

        {
          name = "LspCurrentFunc";
          provider = "lsp_current_func";
          condition = "has_lsp";
          icon = quote "𝒇";
          highlight = {
            fg = colors.grey;
            bg = colors.darkblue;
          };
        }

        {
          name = "FileFormat";
          provider = quote "FileFormat";
          separator = quote "";
          separatorHighlight = {
            fg = colors.darkblue;
            bg = colors.purple;
          };
          highlight = {
            fg = colors.grey;
            bg = colors.purple;
          };
        }

        {
          name = "LineInfo";
          provider = quote "LineColumn";
          separator = quote " | ";
          separatorHighlight = {
            fg = colors.darkblue;
            bg = colors.purple;
          };
          highlight = {
            fg = colors.grey;
            bg = colors.purple;
          };
        }

        {
          name = "PerCent";
          provider = quote "LinePercent";
          separator = quote "";
          separatorHighlight = {
            fg = colors.darkblue;
            bg = colors.purple;
          };
          highlight = {
            fg = colors.grey;
            bg = colors.darkblue;
          };
        }

        {
          name = "ScrollBar";
          provider = quote "ScrollBar";
          highlight = {
            fg = colors.yellow;
            bg = colors.purple;
          };
        }
      ];
    };
  };
}
