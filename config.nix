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

    lua_keymaps = let
      nrsilent = rhs: {
        rhs = rhs;
        opts = {
          remap = false;
          silent = true;
        };
      };
    in {
      n = {
        "ft" = nrsilent "<cmd>NvimTreeToggle<CR>";

        "bp" = nrsilent "<cmd>Telescope buffers<CR>";
        "ca" = nrsilent "<cmd>lua vim.lsp.buf.code_action()<CR>";
        "<C-s>" = nrsilent "<cmd>Telescope spell_suggest<CR>";
        "mk" = nrsilent "<cmd>Telescope keymaps<CR>";
        "fg" = nrsilent "<cmd>Telescope git_files<CR>";

        "K" = nrsilent "<cmd>lua vim.lsp.buf.hover()<CR>";
      };
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

      comment-nvim = {
        enable = true;
      };

      nvim-tree = {
        enable = true;

        diagnostics.enable = true;
        git.enable = true;
      };

      plantuml-syntax.enable = true;
    };

    extraPlugins = with pkgs.vimPlugins; [
      telescope-ui-select-nvim
      vim-vsnip
      markdown-preview-nvim
    ];
  };
}
