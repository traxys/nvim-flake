{
  pkgs,
  config,
  helpers,
  lib,
  ...
}: {
  config = {
    colorschemes.tokyonight = {
      style = "night";
      enable = true;
    };

    globals = {
      neo_tree_remove_legacy_commands = 1;
      mapleader = " ";
    };

    options = {
      termguicolors = true;
      number = true;
      tabstop = 4;
      shiftwidth = 4;
      scrolloff = 7;
      signcolumn = "yes";
      cmdheight = 2;
      cot = ["menu" "menuone" "noselect"];
      updatetime = 100;
      colorcolumn = "100";
      spell = true;
      listchars = "tab:>-,lead:·,nbsp:␣,trail:•";
      fsync = true;

      timeout = true;
      timeoutlen = 300;
    };

    commands = {
      "SpellFr" = "setlocal spelllang=fr";
    };

    filetype = {
      filename = {
        Jenkinsfile = "groovy";
      };
      extension = {
        lalrpop = "lalrpop";
      };
    };

    keymaps = let
      modeKeys = mode:
        lib.attrsets.mapAttrsToList (key: action: {
          inherit key action mode;
        });
      nm = modeKeys ["n"];
      vs = modeKeys ["v"];
    in
      helpers.keymaps.mkKeymaps {options.silent = true;} (nm {
        "ft" = "<cmd>Neotree<CR>";
        "fG" = "<cmd>Neotree git_status<CR>";
        "fR" = "<cmd>Neotree remote<CR>";
        "fc" = "<cmd>Neotree close<CR>";
        "bp" = "<cmd>Telescope buffers<CR>";

        "<C-s>" = "<cmd>Telescope spell_suggest<CR>";
        "mk" = "<cmd>Telescope keymaps<CR>";
        "fg" = "<cmd>Telescope git_files<CR>";

        "gr" = "<cmd>Telescope lsp_references<CR>";
        "gI" = "<cmd>Telescope lsp_implementations<CR>";
        "gW" = "<cmd>Telescope lsp_workspace_symbols<CR>";
        "gF" = "<cmd>Telescope lsp_document_symbols<CR>";
        "ge" = "<cmd>Telescope diagnostics bufnr=0<CR>";
        "gE" = "<cmd>Telescope diagnostics<CR>";

        "<leader>zn" = "<Cmd>ZkNew { title = vim.fn.input('Title: ') }<CR>";
        "<leader>zo" = "<Cmd>ZkNotes { sort = { 'modified' } }<CR>";
        "<leader>zt" = "<Cmd>ZkTags<CR>";
        "<leader>zf" = "<Cmd>ZkNotes { sort = { 'modified' }, match = { vim.fn.input('Search: ') } }<CR>";
      })
      ++ (vs {
        "<leader>zf" = "'<,'>ZkMatch<CR>";
      })
      ++ [
        {
          key = "<leader>rn";
          mode = ["n"];
          action = ''
            function()
            	return ":IncRename " .. vim.fn.expand("<cword>")
            end
          '';
          lua = true;
          options.expr = true;
        }
      ];

    plugins.nvim-osc52 = {
      enable = true;
      package = pkgs.vimPlugins.nvim-osc52;
      keymaps.enable = true;
    };

    plugins.efmls-configs = {
      enable = true;

      toolPackages.mdformat = with pkgs.python3.pkgs;
        mdformat.withPlugins [
          mdformat-gfm
          mdformat-frontmatter
          mdformat-footnote
          mdformat-tables
          mdit-py-plugins
        ];

      setup = {
        sh = {
          #linter = "shellcheck";
          formatter = "shfmt";
        };
        bash = {
          #linter = "shellcheck";
          formatter = "shfmt";
        };
        c = {
          linter = "cppcheck";
        };
        markdown = {
          formatter = ["cbfmt" "mdformat"];
        };
        python = {
          formatter = "black";
        };
        nix = {
          linter = "statix";
        };
        lua = {
          formatter = "stylua";
        };
        html = {
          formatter = ["prettier" (helpers.mkRaw "djlint_fmt")];
        };
        htmldjango = {
          formatter = [(helpers.mkRaw "djlint_fmt")];
          linter = "djlint";
        };
        json = {
          formatter = "prettier";
        };
        css = {
          formatter = "prettier";
        };
        ts = {
          formatter = "prettier";
        };
        gitcommit = {
          linter = "gitlint";
        };
      };
    };
    # plugins.null-ls = {
    #   enable = true;
    #   sources = {
    #     diagnostics = {
    #       gitlint.enable = true;
    #     };
    #     code_actions = {
    #       shellcheck.enable = true;
    #       #gitsigns.enable = true;
    #     };
    #     formatting = {
    #       alejandra.enable = true;
    #     };
    #   };
    # };
    plugins.gitsigns.enable = true;
    plugins.gitmessenger.enable = true;

    plugins.firenvim.enable = false;

    plugins.luasnip = {
      enable = true;
    };

    extraConfigLuaPre = ''
      local has_words_before = function()
        unpack = unpack or table.unpack
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
      end
      local luasnip = require("luasnip")

      local efm_fs = require('efmls-configs.fs')
      local djlint_fmt = {
        formatCommand = string.format('%s --reformat ''${INPUT} -', efm_fs.executable('djlint')),
        formatStdin = true,
      }
    '';

    plugins.nvim-cmp = {
      enable = true;

      snippet.expand = "luasnip";

      mapping = {
        "<CR>" = "cmp.mapping.confirm({select = true })";
        "<C-d>" = "cmp.mapping.scroll_docs(-4)";
        "<C-f>" = "cmp.mapping.scroll_docs(4)";
        "<C-Space>" = "cmp.mapping.complete()";
        "<Tab>" = ''
          cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            -- You could replace the expand_or_jumpable() calls with expand_or_locally_jumpable()
            -- they way you will only jump inside the snippet region
            elseif luasnip.expand_or_locally_jumpable() then
              luasnip.expand_or_jump()
            elseif has_words_before() then
              cmp.complete()
            else
              fallback()
            end
          end, { "i", "s" })
        '';
        "<S-Tab>" = ''
          cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" })
        '';
        "<Down>" = "cmp.mapping(cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }), {'i'})";
        "<Up>" = "cmp.mapping(cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }), {'i'})";
      };

      sources = [
        {name = "luasnip";}
        {name = "nvim_lsp";}
        {name = "path";}
        {name = "buffer";}
        {name = "calc";}
        {name = "zsh";}
      ];
    };

    plugins.telescope = {
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
      extraOptions = {
        defaults.layout_strategy = "vertical";
      };
    };

    extraFiles."queries/rust/injections.scm" = ''
      ;; extends

      (
        (macro_invocation
          macro: ((scoped_identifier) @_sql_def)
          (token_tree (string_literal) @sql))

        (#eq? @_sql_def "sqlx::query")
      )
    '';

    plugins.treesitter = {
      enable = true;
      indent = true;

      nixvimInjections = true;

      grammarPackages = with config.plugins.treesitter.package.passthru.builtGrammars; [
        arduino
        bash
        c
        cpp
        cuda
        dart
        devicetree
        diff
        dockerfile
        gitattributes
        gitcommit
        gitignore
        git_rebase
        groovy
        html
        ini
        json
        lalrpop
        latex
        lua
        make
        markdown
        markdown_inline
        meson
        ninja
        nix
        python
        regex
        rst
        rust
        slint
        sql
        tlaplus
        toml
        vim
        vimdoc
        yaml
      ];
    };

    plugins.treesitter-refactor = {
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

    plugins.treesitter-context = {
      enable = true;
    };

    plugins.vim-matchup = {
      treesitterIntegration = {
        enable = true;
        includeMatchWords = true;
      };
      enable = true;
    };
    plugins.headerguard.enable = true;

    plugins.comment-nvim = {
      enable = true;
    };

    plugins.neo-tree = {
      enable = true;
    };

    plugins.plantuml-syntax.enable = true;

    plugins.indent-blankline = {
      enable = true;

      scope = {
        enabled = true;

        showStart = true;
      };
    };

    plugins.lsp = {
      enable = true;

      enabledServers = [
        {
          name = "lemminx";
          extraOptions = {
            cmd = ["${pkgs.lemminx-bin}/bin/lemminx-bin"];
          };
        }
        # {
        #   name = "groovyls";
        #   extraOptions = {
        #     cmd = ["${pkgs.groovy-language-server}/bin/groovy-language-server"];
        #   };
        # }
      ];

      keymaps = {
        silent = true;

        lspBuf = {
          "gd" = "definition";
          "gD" = "declaration";
          "ca" = "code_action";
          "ff" = "format";
          "K" = "hover";
        };
      };

      servers = {
        nil_ls = {
          enable = true;
          settings = {
            formatting.command = ["${pkgs.alejandra}/bin/alejandra" "--quiet"];
          };
        };
        bashls.enable = true;
        dartls.enable = true;
        clangd.enable = true;
        typst-lsp.enable = true;
        tsserver.enable = true;
        efm.extraOptions = {
          init_options = {
            documentFormatting = true;
          };
        };
        taplo.enable = true;
      };
    };

    plugins.typst-vim.enable = true;

    plugins.rust-tools = {
      enable = true;
      inlayHints = {
        maxLenAlign = true;
      };

      server = {
        cargo.features = "all";
        checkOnSave = true;
        check.command = "clippy";
        rustc.source = "discover";
      };
    };

    plugins.lspkind = {
      enable = true;
      cmp = {
        enable = true;
      };
    };

    plugins.nvim-lightbulb = {
      enable = true;
      autocmd.enabled = true;
    };

    plugins.lsp_signature = {
      #enable = true;
    };

    plugins.inc-rename = {
      enable = true;
    };

    plugins.clangd-extensions = {
      enable = true;
      enableOffsetEncodingWorkaround = true;

      ast = {
        roleIcons = {
          type = "";
          declaration = "";
          expression = "";
          specifier = "";
          statement = "";
          templateArgument = "";
        };
        kindIcons = {
          compound = "";
          recovery = "";
          translationUnit = "";
          packExpansion = "";
          templateTypeParm = "";
          templateTemplateParm = "";
          templateParamObject = "";
        };
      };
    };

    # fidget = {
    #   enable = true;
    #
    #   sources.null-ls.ignore = true;
    # };

    plugins.lualine = {
      enable = true;
    };

    plugins.trouble = {
      enable = true;
    };

    plugins.noice = {
      enable = true;

      messages = {
        view = "mini";
        viewError = "mini";
        viewWarn = "mini";
      };

      lsp.override = {
        "vim.lsp.util.convert_input_to_markdown_lines" = true;
        "vim.lsp.util.stylize_markdown" = true;
        "cmp.entry.get_documentation" = true;
      };
      presets = {
        bottom_search = true;
        command_palette = true;
        long_message_to_split = true;
        inc_rename = true;
        lsp_doc_border = false;
      };
    };

    plugins.netman = {
      enable = false;
      package = pkgs.vimPlugins.netman-nvim;
      neoTreeIntegration = true;
    };

    plugins.openscad = {
      enable = true;
      loadSnippets = true;
      keymaps.enable = true;
    };

    extraConfigLuaPost = ''
      require("luasnip.loaders.from_snipmate").lazy_load()

      -- local null_ls = require("null-ls")
      -- local helpers = require("null-ls.helpers")
      --
      -- local sca2d = {
      --   method = null_ls.methods.DIAGNOSTICS,
      --   filetypes = { "openscad" },
      --   generator = null_ls.generator({
      --     command = "sca2d",
      --     args = { "$FILENAME" },
      --     from_stderr = false,
      --     to_stdin = true,
      --     format = "line",
      --     check_exit_code = function(code)
      --       return code <= 1
      --     end,
      --     on_output = helpers.diagnostics.from_pattern(
      --       [[[^:]+:(%d+):(%d+): (%w)%d+: (.*)]], {"row", "col", "severity", "message"}, {
      --         severities = {
      --           F = helpers.diagnostics.severities["error"],
      --           E = helpers.diagnostics.severities["error"],
      --           W = helpers.diagnostics.severities["warning"],
      --           D = helpers.diagnostics.severities["warning"],
      --           I = helpers.diagnostics.severities["info"],
      --         },
      --     }),
      --   }),
      -- }

      -- null_ls.register(sca2d)
    '';

    plugins.zk = {
      enable = true;
      picker = "telescope";
    };

    plugins.which-key.enable = true;

    plugins.leap.enable = true;

    files."ftplugin/nix.lua" = {
      options = {
        tabstop = 2;
        shiftwidth = 2;
        expandtab = true;
      };
    };

    files."ftplugin/markdown.lua" = {
      extraConfigLua = ''
        if require("zk.util").notebook_root(vim.fn.expand('%:p')) ~= nil then
          local function map(...) vim.api.nvim_buf_set_keymap(0, ...) end
          local opts = { noremap=true, silent=false }

          -- Open the link under the caret.
          map("n", "<CR>", "<Cmd>lua vim.lsp.buf.definition()<CR>", opts)

          -- Create a new note after asking for its title.
          -- This overrides the global `<leader>zn` mapping to create the note in the same directory as the current buffer.
          map("n", "<leader>zn", "<Cmd>ZkNew { dir = vim.fn.expand('%:p:h'), title = vim.fn.input('Title: ') }<CR>", opts)
          -- Create a new note in the same directory as the current buffer, using the current selection for title.
          map("v", "<leader>znt", ":'<,'>ZkNewFromTitleSelection { dir = vim.fn.expand('%:p:h') }<CR>", opts)
          -- Create a new note in the same directory as the current buffer, using the current selection for note content and asking for its title.
          map("v", "<leader>znc", ":'<,'>ZkNewFromContentSelection { dir = vim.fn.expand('%:p:h'), title = vim.fn.input('Title: ') }<CR>", opts)

          -- Open notes linking to the current buffer.
          map("n", "<leader>zb", "<Cmd>ZkBacklinks<CR>", opts)
          -- Alternative for backlinks using pure LSP and showing the source context.
          --map('n', '<leader>zb', '<Cmd>lua vim.lsp.buf.references()<CR>', opts)
          -- Open notes linked by the current buffer.
          map("n", "<leader>zl", "<Cmd>ZkLinks<CR>", opts)

          -- Preview a linked note.
          map("n", "K", "<Cmd>lua vim.lsp.buf.hover()<CR>", opts)
          -- Open the code actions for a visual selection.
          map("v", "<leader>za", ":'<,'>lua vim.lsp.buf.range_code_action()<CR>", opts)
        end
      '';
    };

    extraPackages = with pkgs; [
      /*
      sca2d
      */
      djlint
    ];

    extraPlugins = with pkgs.vimPlugins; [
      telescope-ui-select-nvim
      vim-snippets
      markdown-preview-nvim
    ];
  };
}
