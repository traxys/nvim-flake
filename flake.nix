{
  description = "A very basic flake";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";

    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixvim = {
      #url = "github:pta2002/nixvim";
      url = "/home/traxys/Documents/nixvim";
      #url = "github:traxys/nixvim?ref=gitsigns_codeactions";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    neovim-flake = {
      url = "github:neovim/neovim?dir=contrib";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    "plugin:nvim-osc52" = {
      url = "github:ojroques/nvim-osc52";
      flake = false;
    };

    "plugin:gitsigns-nvim" = {
      url = "github:lewis6991/gitsigns.nvim";
      flake = false;
    };
    "plugin:git-messenger-vim" = {
      url = "github:rhysd/git-messenger.vim";
      flake = false;
    };

    "plugin:plenary-nvim" = {
      url = "github:nvim-lua/plenary.nvim";
      flake = false;
    };

    "plugin:null-ls-nvim" = {
      url = "github:jose-elias-alvarez/null-ls.nvim";
      flake = false;
    };

    "plugin:firenvim" = {
      url = "github:glacambre/firenvim";
      flake = false;
    };

    "plugin:vim-headerguard" = {
      url = "github:drmikehenry/vim-headerguard";
      flake = false;
    };

    "nvim-treesitter" = {
      url = "github:nvim-treesitter/nvim-treesitter";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    nixvim,
    flake-utils,
    neovim-flake,
    ...
  } @ inputs:
    with builtins;
      flake-utils.lib.eachDefaultSystem (system: let
        module = {
          imports = [
            ./config.nix
            ./plugins/osc52.nix
            ./plugins/gitmessenger.nix
            ./plugins/firenvim.nix
            ./plugins/vim-matchup.nix
            ./plugins/editorconfig.nix
            ./plugins/headerguard.nix
            ./plugins/indent-blankline.nix
			./plugins/nvim-lightbulb.nix
            ./modules
          ];
          package = neovim-flake.packages."${system}".neovim.overrideAttrs (_: {
            patches = [];
          });
        };

        plugins = filter (s: (match "plugin:.*" s) != null) (attrNames inputs);
        plugName = input:
          substring
          (stringLength "plugin:")
          (stringLength input)
          input;

        buildPlug = pkgs: name:
          pkgs.vimUtils.buildVimPluginFrom2Nix {
            pname = plugName name;
            version = "master";
            src = getAttr name inputs;
          };

        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            (final: prev: let
              buildPlugPkg = buildPlug prev;
            in {
              vimPlugins =
                prev.vimPlugins
                // (listToAttrs (map (plugin: {
                    name = plugName plugin;
                    value = buildPlugPkg plugin;
                  })
                  plugins));
            })

            (
              final: prev: {
                vimPlugins =
                  prev.vimPlugins
                  // {
                    telescope-nvim = prev.vimPlugins.telescope-nvim.overrideAttrs (old: {
                      dependencies = with final; [vimPlugins.plenary-nvim];
                    });
                    nvim-treesitter = prev.vimUtils.buildVimPluginFrom2Nix {
                      inherit (prev.vimPlugins.nvim-treesitter) pname passthru;
                      version = "master";

                      src = inputs.nvim-treesitter;
                    };
                  };
              }
            )
          ];
        };

        nixvim' = nixvim.legacyPackages."${system}";
        nvim = nixvim'.makeNixvimWithModule {inherit module pkgs;};
      in {
        packages = {
          inherit nvim;
          default = nvim;
        };
      });
}
