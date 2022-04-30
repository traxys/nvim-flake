{
  config,
  lib,
  pgks,
  ...
}:
with lib;
with builtins; {
  imports = [./c.nix ./rust.nix ./nix.nix ./bash.nix];
}
