{
  pkgs,
  config,
  helpers,
  ...
}: {
  config = {
    colorschemes.tokyonight = {
      style = "night";
      enable = true;
    };

    globals = {
      neo_tree_remove_legacy_commands = 1;
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

    maps.normal = helpers.mkModeMaps {silent = true;} {
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

      "<leader>rn" = {
        action = ''
          function()
          	return ":IncRename " .. vim.fn.expand("<cword>")
          end
        '';
        lua = true;
        expr = true;
      };
    };

    plugins.nvim-osc52 = {
      enable = true;
      package = pkgs.vimPlugins.nvim-osc52;
      keymaps.enable = true;
    };
    plugins.null-ls = {
      enable = true;
      sources = {
        diagnostics = {
          shellcheck.enable = true;
          cppcheck.enable = true;
          gitlint.enable = true;
        };
        code_actions = {
          shellcheck.enable = true;
          #gitsigns.enable = true;
        };
        formatting = {
          alejandra.enable = true;
          black.enable = true;
          stylua.enable = true;
          cbfmt.enable = true;
          shfmt.enable = true;
          taplo.enable = true;
          prettier.enable = true;
        };
      };
    };
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
            elseif luasnip.expand_or_jumpable() then
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
    };

    plugins.treesitter = {
      enable = true;
      indent = true;

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
        help
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

      useTreesitter = true;

      showCurrentContext = true;
      showCurrentContextStart = true;
    };

    plugins.lsp = {
      enable = true;

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
            formatting.command = ["alejandra" "--quiet"];
          };
        };
        bashls.enable = true;
        dartls.enable = true;
      };
    };

    plugins.rust-tools = {
      enable = true;
      inlayHints = {
        maxLenAlign = true;
      };

      server = {
        cargo.features = "all";
        checkOnSave = true;
        check.command = "clippy";
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

      extensions.ast = {
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
      enable = true;
      package = pkgs.vimPlugins.netman-nvim;
      neoTreeIntegration = true;
    };

    extraConfigLuaPost = ''
      require("luasnip.loaders.from_snipmate").lazy_load()
    '';

    extraPlugins = with pkgs.vimPlugins; [
      telescope-ui-select-nvim
      vim-snippets
      markdown-preview-nvim
    ];
  };
}
