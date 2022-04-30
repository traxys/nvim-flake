{
  config,
  lib,
  pkgs,
  ...
}:
with lib; {
  config.vim.completion = {
    enable = mkDefault false;
    sources = mkDefault null;

    icons = {
      enable = mkDefault false;
      withText = mkDefault true;
      maxWidth = mkDefault null;
    };
  };
}
