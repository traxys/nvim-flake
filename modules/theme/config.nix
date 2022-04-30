{
  pkgs,
  config,
  lib,
  ...
}:
with lib; {
  config = {
    vim.theme = {
      enable = mkDefault false;
      name = mkDefault "moonfly";
    };
  };
}
