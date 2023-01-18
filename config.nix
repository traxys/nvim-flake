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

    filetype = {
      enable = true;

      literal = {
        Jenkinsfile = "groovy";
      };
      extensions = {
        nix = "nix";
        rsh = "rsh";
        lalrpop = "lalrpop";
      };
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

        "<C-s>" = nrsilent "<cmd>Telescope spell_suggest<CR>";
        "mk" = nrsilent "<cmd>Telescope keymaps<CR>";
        "fg" = nrsilent "<cmd>Telescope git_files<CR>";

        "gr" = nrsilent "<cmd>Telescope lsp_references<CR>";
        "gI" = nrsilent "<cmd>Telescope lsp_implementations<CR>";
        "gW" = nrsilent "<cmd>Telescope lsp_workspace_symbols<CR>";
        "gF" = nrsilent "<cmd>Telescope lsp_document_symbols<CR>";
        "ge" = nrsilent "<cmd>Telescope diagnostics bufnr=0<CR>";
        "gE" = nrsilent "<cmd>Telescope diagnostics<CR>";
        "ca" = nrsilent "<cmd>lua vim.lsp.buf.code_action()<CR>";
        "ff" = nrsilent "<cmd>lua vim.lsp.buf.format()<CR>";
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

      indent-blankline = {
        enable = true;

        useTreesitter = true;

        showCurrentContext = true;
        showCurrentContextStart = true;
      };

      lsp = {
        enable = true;

        servers = {
          nil_ls = {
            enable = true;
            formatting.command = ["alejandra" "--quiet"];
          };
          bashls.enable = true;
        };
      };

      rust-tools = {
        enable = true;
        inlayHints = {
          maxLenAlign = true;
        };

        server = {
          cargo.features = "all";
          checkOnSave = {
            enable = true;
            command = "clippy";
          };
        };
      };

      lspkind = {
        enable = true;
        cmp = {
          enable = true;
        };
      };
    };

    extraPlugins = with pkgs.vimPlugins; [
      telescope-ui-select-nvim
      vim-vsnip
      markdown-preview-nvim
    ];
  };
}
