{ config, lib, pgks, ... }:

with lib;

{
  config.vim.lsp = {
    enable = mkDefault false;
    capabilities = mkDefault "";
    onAttach = mkDefault "";
    servers = mkDefault { };
    lightbulb = mkDefault false;
    diagnosticsPopup = mkDefault false;
    signatures = {
      enable = mkDefault false;
    };
    null-ls = {
      enable = mkDefault false;
      sources = mkDefault [ ];
    };
    luaLocals = mkDefault "";

    lang = {
      c = {
        enable = mkDefault false;
      };
      rust = {
        enable = mkDefault false;
        crates = {
          enable = mkDefault false;
          completion = mkDefault false;
        };
        settings = {
          cargo = {
            allFeatures = mkDefault false;
          };
          checkOnSave = {
            command = mkDefault "check";
          };
        };
      };
    };
  };
}
