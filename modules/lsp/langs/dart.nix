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
  config.vim.lsp.servers.dartls = mkIf cfg.dart.enable {
    enable = true;
  };
}
