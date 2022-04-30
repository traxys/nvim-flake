{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [./config.nix ./statusline.nix];
}
