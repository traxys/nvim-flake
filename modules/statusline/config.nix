{
  config,
  lib,
  pkgs,
  ...
}:
with lib; {
  config.vim.statusline = {
    enable = mkDefault false;
    lspIntegration = mkDefault false;
    helpers = mkDefault "";

    sections = {
      left = mkDefault [];
      right = mkDefault [];
    };
  };
}
