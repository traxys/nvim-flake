{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils = {
      #inputs.nixpkgs.follows = "nixpkgs";
      url = "github:numtide/flake-utils";
    };
    neovim-flake.url = "github:neovim/neovim?dir=contrib";
    neovim-flake.inputs.nixpkgs.follows = "nixpkgs";

    # Inputs used by the home-manager module
    stylua = {
      url = "github:johnnymorganz/stylua";
      flake = false;
    };
    naersk.url = "github:nix-community/naersk";

    # Theme
    "plugin:vim-moonfly-colors" = {
      url = "github:bluz71/vim-moonfly-colors";
      flake = false;
    };

    # Git
    "plugin:gitsigns" = {
      url = "github:lewis6991/gitsigns.nvim";
      flake = false;
    };
    "plugin:git-messenger" = {
      url = "github:rhysd/git-messenger.vim";
      flake = false;
    };

    # Lsp
    "plugin:null-ls" = {
      url = "github:jose-elias-alvarez/null-ls.nvim";
      flake = false;
    };
    "plugin:nvim-lspconfig" = {
      url = "github:neovim/nvim-lspconfig";
      flake = false;
    };
    "plugin:nvim-lightbulb" = {
      url = "github:kosayoda/nvim-lightbulb";
      flake = false;
    };
    "plugin:lsp_signature" = {
      url = "github:ray-x/lsp_signature.nvim";
      flake = false;
    };
    "plugin:clangd_extensions" = {
      url = "github:p00f/clangd_extensions.nvim";
      flake = false;
    };
    "plugin:rust-tools" = {
      url = "github:simrat39/rust-tools.nvim";
      flake = false;
    };
    "plugin:fidget" = {
      url = "github:j-hui/fidget.nvim";
      flake = false;
    };
    "plugin:inc-rename" = {
      url = "github:smjonas/inc-rename.nvim";
      flake = false;
    };

    # Completion
    "plugin:nvim-cmp" = {
      url = "github:hrsh7th/nvim-cmp";
      flake = false;
    };
    "plugin:lspkind" = {
      url = "github:onsails/lspkind-nvim";
      flake = false;
    };
    "plugin:cmp-source-nvim_lsp" = {
      url = "github:hrsh7th/cmp-nvim-lsp";
      flake = false;
    };
    "plugin:cmp-source-buffer" = {
      url = "github:hrsh7th/cmp-buffer";
      flake = false;
    };
    "plugin:cmp-source-path" = {
      url = "github:hrsh7th/cmp-path";
      flake = false;
    };
    "plugin:cmp-source-latex_symbols" = {
      url = "github:kdheepak/cmp-latex-symbols";
      flake = false;
    };
    "plugin:cmp-source-calc" = {
      url = "github:hrsh7th/cmp-calc";
      flake = false;
    };
    "plugin:cmp-source-vsnip" = {
      url = "github:hrsh7th/cmp-vsnip";
      flake = false;
    };
    "plugin:cmp-source-crates" = {
      url = "github:saecki/crates.nvim";
      flake = false;
    };
    "plugin:cmp-source-treesitter" = {
      url = "github:ray-x/cmp-treesitter";
      flake = false;
    };

    # Treesitter
    "plugin:nvim-treesitter" = {
      url = "github:nvim-treesitter/nvim-treesitter";
      flake = false;
    };
    "plugin:nvim-treesitter-refactor" = {
      url = "github:nvim-treesitter/nvim-treesitter-refactor";
      flake = false;
    };
	"plugin:nvim-treesitter-context" = {
	  url = "github:nvim-treesitter/nvim-treesitter-context";
	  flake = false;
	};

    # Filetree
    "plugin:nvim-tree-lua" = {
      url = "github:kyazdani42/nvim-tree.lua";
      flake = false;
    };

    # Statusline
    "plugin:galaxyline" = {
      url = "github:NTBBloodbath/galaxyline.nvim";
      flake = false;
    };

    # Visuals
    "plugin:nvim-web-devicons" = {
      url = "github:kyazdani42/nvim-web-devicons";
      flake = false;
    };
    "plugin:indent-blankline" = {
      url = "github:lukas-reineke/indent-blankline.nvim";
      flake = false;
    };

    # Telescope
    "plugin:telescope" = {
      url = "github:nvim-telescope/telescope.nvim";
      flake = false;
    };
    "plugin:telescope-ui-select" = {
      url = "github:nvim-telescope/telescope-ui-select.nvim";
      flake = false;
    };

    # Misc
    "plugin:filetype-nvim" = {
      url = "github:nathom/filetype.nvim";
      flake = false;
    };
    "plugin:plenary" = {
      url = "github:nvim-lua/plenary.nvim";
      flake = false;
    };
    "plugin:vim-matchup" = {
      url = "github:andymass/vim-matchup";
      flake = false;
    };
    "plugin:kommentary" = {
      url = "github:b3nj5m1n/kommentary";
      flake = false;
    };
    "plugin:editorconfig" = {
      url = "github:editorconfig/editorconfig-vim";
      flake = false;
    };
    "plugin:vim-vsnip" = {
      url = "github:hrsh7th/vim-vsnip";
      flake = false;
    };

    # Language Specific Misc
    "plugin:plantuml-syntax" = {
      url = "github:aklt/plantuml-syntax";
      flake = false;
    };
    "plugin:headerguard" = {
      url = "github:drmikehenry/vim-headerguard";
      flake = false;
    };
    "plugin:crates" = {
      url = "github:saecki/crates.nvim";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    ...
  } @ inputs:
    flake-utils.lib.eachDefaultSystem
    (
      system: let
        pluginOverlay = lib.buildPluginOverlay;

        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            pluginOverlay
            (final: prev: {
              neovim-unwrapped = inputs.neovim-flake.packages.${prev.system}.neovim;
            })
          ];
        };

        lib = import ./lib {inherit pkgs inputs;};
        neovimBuilder = lib.neovimBuilder;
      in rec {
        defaultApp = packages.neovimTraxys;
        defaultPackage = packages.neovimTraxys;

        home-managerModule = {
          config,
          lib,
          pkgs,
          ...
        }:
          import ./home-manager.nix {
            inherit config lib pkgs;
            stylua = inputs.stylua;
            naersk-lib = inputs.naersk.lib."${system}";
          };

        overlay = self: super: {
          inherit neovimBuilder;
          neovimTraxys = packages.neovimTraxys;
          neovimPlugins = pkgs.neovimPlugins;
        };

        packages.neovimTraxys = neovimBuilder {
          config = import ./config.nix;
          debug = false;
        };
      }
    );
}
