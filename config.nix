{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [./treesitter.nix ./statusline.nix];

  vim.runtimeDir = ./nvim;

  vim.termguicolors = true;
  vim.number = true;
  vim.tabstop = 4;
  vim.shiftwidth = 4;
  vim.scrolloff = 7;
  vim.signcolumn = "yes";
  vim.cmdheight = 2;
  vim.completeopt = ["menu" "menuone" "noselect"];
  vim.updatetime = 300;
  vim.colorcolumn = "100";
  vim.commands = {
    "SpellFr" = "setlocal spell spelllang=fr";
  };

  vim.theme.enable = true;

  vim.git = {
    signs.enable = true;
    messenger.enable = true;
  };

  vim.completion = {
    enable = true;

    mapping = {
      "<C-d>" = "cmp.mapping.scroll_docs(-4)";
      "<C-f>" = "cmp.mapping.scroll_docs(4)";
      "<C-Space>" = "cmp.mapping.complete()";
      "<C-e>" = "cmp.mapping.close()";
      "<Tab>" = ''cmp.mapping(cmp.mapping.select_next_item(), { "i", "s" })'';
      "<CR>" = "cmp.mapping.confirm({ select = true })";
      "<Down>" = "cmp.mapping(cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }), {'i'})";
      "<Up>" = "cmp.mapping(cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }), {'i'})";
    };

    icons = {
      enable = true;
    };

    sources = {
      nvim_lsp = {
        enable = true;
      };
      buffer = {
        enable = true;
      };
      path = {
        enable = true;
      };
      latex_symbols = {
        enable = true;
      };
      calc = {
        enable = true;
      };
      vsnip = {
        enable = true;
      };
    };
  };

  vim.filetype = {
    enable = true;

    literal = {
      Jenkinsfile = "groovy";
    };
    extensions = {
      nix = "nix";
      rsh = "rsh";
    };
  };

  vim.telescope.enable = true;
  vim.matchup.enable = true;
  vim.editorconfig.enable = true;
  vim.headerguard.enable = true;

  vim.kommentary = {
    enable = true;

    langs = {
      c = {
        prefer = "multi_line";
      };
    };
  };

  vim.visuals = {
    nvimWebDevicons = {
      enable = true;
      default = true;
    };

    plantumlSyntax = {
      enable = true;
    };

    indentline = {
      enable = true;
      showContext = true;
      showContextStart = true;
    };
  };

  vim.filetree = {
    enable = true;
    autoClose = true;
    diagnostics = {
      enable = true;
      showOnDirs = true;
    };
  };

  vim.keymaps = let
    nrsilent = rhs: {
      rhs = rhs;
      opts = {
        noremap = true;
        silent = true;
      };
    };
  in {
    n = {
      "ft" = nrsilent "<cmd>NvimTreeToggle<CR>";

      "bp" = nrsilent "<cmd>Telescope buffers<CR>";
      "ca" = nrsilent "<cmd>lua vim.lsp.buf.code_action()<CR>";
      "gr" = nrsilent "<cmd>Telescope lsp_references<CR>";
      "gW" = nrsilent "<cmd>Telescope lsp_workspace_symbols<CR>";
      "gF" = nrsilent "<cmd>Telescope lsp_document_symbols<CR>";
      "ge" = nrsilent "<cmd>Telescope diagnostics bufnr=0<CR>";
      "gE" = nrsilent "<cmd>Telescope diagnostics<CR>";
      "mn" = nrsilent "<cmd>Telescope man_pages sections=1,3,5<CR>";
      "fg" = nrsilent "<cmd>Telescope git_files<CR>";
      "<C-s>" = nrsilent "<cmd>Telescope spell_suggest<CR>";
      "mk" = nrsilent "<cmd>Telescope keymaps<CR>";

      "K" = nrsilent "<cmd>lua vim.lsp.buf.hover()<CR>";
      "ff" = nrsilent "<cmd>${config.vim.lsp.format.command}<CR>";

	  "<leader>r" = nrsilent ":IncRename ";
    };

    v = {
      "<space>f" = nrsilent "<cmd>lua vim.lsp.buf.range_formatting()<CR>";
    };
  };

  vim.lsp = {
    enable = true;

    lightbulb = true;
    diagnosticsPopup = true;

    signatures = {
      enable = true;
    };

    format = {
      enable = true;
      disabledClients = ["rnix"];
    };

    lspLoading = {
      enable = true;
    };

    null-ls = {
      enable = true;

      sources = [
        "builtins.formatting.alejandra"
		"builtins.formatting.black"
        "builtins.formatting.stylua"
        "builtins.formatting.trim_whitespace"
        "builtins.diagnostics.shellcheck"
        "builtins.diagnostics.cppcheck"
      ];
    };

    lang = {
      c = {
        enable = true;
      };

      nix = {
        enable = true;
      };

      bash = {
        enable = true;
      };

      rust = {
        enable = true;
        crates = {
          enable = true;
          completion = true;
        };

        settings = {
          cargo = {
            allFeatures = true;
          };
          checkOnSave = {
            command = "clippy";
          };
        };
      };
    };
  };
}
