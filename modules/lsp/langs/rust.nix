{ config, lib, pkgs, ... }:

with lib;
with builtins;

let
  cfg = config.vim.lsp.lang;
  writeIf = cond: msg: if cond then msg else "";
  luaBool = b: if b then "true" else "false";
in
{

  config.vim = mkIf cfg.rust.enable {
    plenary = mkIf cfg.rust.crates.enable true;

    startPlugins = mkIf cfg.rust.crates.enable (with pkgs.neovimPlugins; [ crates ]);

    completion.sources.crates.enable = mkIf (cfg.rust.crates.enable && cfg.rust.crates.completion) true;

    lsp = {
      servers.rust_analyzer = {
        enable = true;
        settings = ''
          ["rust-analyzer"] = {
          	cargo = {
          		allFeatures = ${luaBool cfg.rust.settings.cargo.allFeatures},
          	},
          	checkOnSave = {
          		command = "${cfg.rust.settings.checkOnSave.command}"
          	},
          }
        '';
      };
    };
  };
}
