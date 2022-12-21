{
  description = "A very basic flake";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";

    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixvim = {
      #url = "github:pta2002/nixvim";
      url = "/home/traxys/Documents/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    neovim-flake = {
      url = "github:neovim/neovim?dir=contrib";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    nixvim,
    flake-utils,
    neovim-flake,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      configuration = {
        imports = [
          ./config.nix
        ];
        package = neovim-flake.packages."${system}".neovim;
      };

      pkgs = import nixpkgs {
        inherit system;
      };

      nixvim' = nixvim.legacyPackages."${system}";
      nvim = nixvim'.makeNixvim {inherit configuration pkgs;};
    in {
      packages = {
        inherit nvim;
        default = nvim;
      };
    });
}
