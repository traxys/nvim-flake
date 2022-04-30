{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with builtin; {
  imports = [
    ./config.nix
    ./lsp.nix
    ./langs
  ];
}
