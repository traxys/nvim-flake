{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.lsp.lang;
  writeIf = cond: msg:
    if cond
    then msg
    else "";
  luaBool = b:
    if b
    then "true"
    else "false";
in {
  config.vim = mkIf cfg.rust.enable {
    plenary = mkIf cfg.rust.crates.enable true;

    startPlugins = with pkgs.neovimPlugins; [
      (
        if cfg.rust.crates.enable
        then crates
        else null
      )
      rust-tools
    ];

    completion.sources.crates.enable = mkIf (cfg.rust.crates.enable && cfg.rust.crates.completion) true;

    lsp.afterLSP = ''
          ${writeIf cfg.rust.crates.enable ''require('crates').setup()''}

          require('rust-tools').setup {
          	server = {
      capabilities = capabilities,
      on_attach = on_attach,
         		settings = {
         			["rust-analyzer"] = {
         				cargo = {
         					allFeatures = ${luaBool cfg.rust.settings.cargo.allFeatures},
         				},
         				checkOnSave = {
         					command = "${cfg.rust.settings.checkOnSave.command}",
         				},
         			},
         		}
         	},
          }
    '';
  };
}
