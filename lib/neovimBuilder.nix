{
  pkgs,
  lib ? pkgs.lib,
  ...
}: {
  config,
  debug ? false,
}: let
  neovimPlugins = pkgs.neovimPlugins;
  myNeovimUnwrapped = pkgs.neovim-unwrapped.overrideAttrs (prev: {
    propagatedBuildInputs = with pkgs; [pkgs.stdenv.cc.cc.lib];
  });

  vimOptions = lib.evalModules {
    modules = [
      {imports = [../modules];}
      config
    ];

    specialArgs = {
      inherit pkgs;
    };
  };

  vim = vimOptions.config.vim;
in
  pkgs.wrapNeovim myNeovimUnwrapped {
    viAlias = vim.viAlias;
    vimAlias = vim.vimAlias;
    configure = {
      # customRC = builtins.trace vim.configRC vim.configRC;
      customRC =
        if debug
        then builtins.trace vim.configRC vim.configRC
        else vim.configRC;

      packages.myVimPackage = with neovimPlugins; {
        start = builtins.filter (f: f != null) vim.startPlugins;
        opt = vim.optPlugins;
      };
    };
  }
