{pkgs, ...}: {
  config = {
    colorschemes.tokyonight = {
      style = "night";
      enable = true;
    };

    options = {
      termguicolors = true;
      number = true;
      tabstop = 4;
      shiftwidth = 4;
      scrolloff = 7;
      signcolumn = "yes";
      cmdheight = 2;
      completopt = "menu,menuone,noselect";
      updatetime = 300;
      colorcolumn = "100";
      spell = true;
    };

    commands = {
      "SpellFr" = "setlocal spelllang=fr";
    };

    plugins = {
      osc52.enable = true;
      null-ls = {
        enable = true;
        sources = {
          code_actions = {
            gitsigns.enable = true;
          };
        };
      };
      gitsigns.enable = true;
      gitmessenger.enable = true;

      firenvim.enable = true;

      nvim-cmp = {
        enable = true;

        snippet = {
          expand = ''
            function(args)
              vim.fn["vsnip#anonymous"](args.body)
            end
          '';
        };

        mapping = {
          "<CR>" = "cmp.mapping.confirm({select = true })";
          "<C-d>" = "cmp.mapping.scroll_docs(-4)";
          "<C-f>" = "cmp.mapping.scroll_docs(4)";
          "<C-Space>" = "cmp.mapping.complete()";
          "<Tab>" = ''cmp.mapping(cmp.mapping.select_next_item(), {"i", "s"})'';
          "<Down>" = "cmp.mapping(cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }), {'i'})";
          "<Up>" = "cmp.mapping(cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }), {'i'})";
        };

        sources = [
          {name = "path";}
          {name = "buffer";}
          {name = "vsnip";}
          {name = "nvim_lsp";}
          {name = "calc";}
        ];
      };

      telescope = {
        enable = true;
        enabledExtensions = ["ui-select"];
        extensionConfig = {
          ui-select = {
            __raw = ''
                require("telescope.themes").get_dropdown {
                -- even more opts
              }
            '';
          };
        };
      };

      treesitter = {
        enable = true;
        indent = true;
      };

      treesitter-refactor = {
        enable = true;
        highlightDefinitions = {
          enable = true;
          clearOnCursorMove = true;
        };
        smartRename = {
          enable = true;
        };
        navigation = {
          enable = true;
        };
      };

      treesitter-context = {
        enable = true;
      };

      vim-matchup = {
        treesitterIntegration = {
          enable = true;
          includeMatchWords = true;
        };
        enable = true;
      };
      editorconfig.enable = true;
      headerguard.enable = true;
    };

    extraPlugins = with pkgs.vimPlugins; [
      telescope-ui-select-nvim
      vim-vsnip
      markdown-preview-nvim
    ];
  };
}
