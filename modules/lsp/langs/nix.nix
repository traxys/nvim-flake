{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.lsp.lang;
in {
  config.vim.lsp.servers.rnix = mkIf cfg.nix.enable {
    enable = true;
  };
}
