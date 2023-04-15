# My personal neovim configuration

This is a neovim configuration using [Nixvim](https://github.com/pta2002/nixvim).

Most of the options are defined in [config.nix](./config.nix).

It has a few specificities to help managing a configuration through nixvim:

- Extra modules & plugins not packaged in nixvim in [modules](./modules) and [plugins](./plugins).
- Git version of all plugins

  This is done through the sources of the `flake.nix`. All plugins are prefixed with `plugin:`.
  Those plugins are overridden from `nixpkgs` with their source.
  There are also sources prefixed by `new-plugin:` that are automatically added to `pkgs.vimPlugins`.
  
## Update

The inputs are automatically updated using Github Actions, and checking that the neovim launches without any errors/warnings.
