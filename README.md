# Neovim config using Nix flakes

This configuration is heavily inspired by [jordanisaacs/neovim-flake](https://github.com/jordanisaacs/neovim-flake)

## Installation

In order to test the configuration, you can clone this repository and execute the follwing command:
```
nix run .# -- /some/file
```

## Adding plugins

If you want to add a plugin you can just add an input in the inputs with the name `plugin:<some name>`. You can then add `pkgs.neovimPlugins.<some name>` to `vim.startPlugins = [ ... ]`.

If you want to add an nvim-cmp-source you will need to add a plugin of the form `plugin:cmp-source-<cmp source name>`. The plugin can be added in the same way, and you can enable the `<cmp source name>` in the `vim.completion.sources` option.

## Configuration

Everything that can be configured is in the `./config.nix` and it's imports
