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
  config.vim.lsp.servers.bashls = mkIf cfg.bash.enable {
    enable = true;
  };
}
