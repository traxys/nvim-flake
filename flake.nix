{
  description = "A very basic flake";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    neovim-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    "plugin:null-ls" = {
      url = "github:jose-elias-alvarez/null-ls.nvim";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils }@inputs:
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          pluginOverlay = lib.buildPluginOverlay;

          pkgs = import nixpkgs {
            inherit system;
            overlays = [
              pluginOverlay
              inputs.neovim-overlay.overlay
            ];
          };

          lib = import ./lib { inherit pkgs inputs; };
          neovimBuilder = lib.neovimBuilder;
        in
        rec {
          apps = {
            nvim = {
              type = "app";
              program = "${defaultPackage}/bin/nvim";
            };
          };

          defaultApp = apps.neovim;
          defaultPackage = packages.neovimTraxys;

          overlay = (self: super: {
            inherit neovimBuilder;
            neovimTraxys = packages.neovimTraxys;
            neovimPlugins = pkgs.neovimPlugins;
          });

          packages.neovimTraxys = neovimBuilder { };
        }
      );
}
