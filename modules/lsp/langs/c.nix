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
  config.vim = mkIf cfg.c.enable {
    startPlugins = with pkgs.neovimPlugins; [clangd_extensions];

    lsp.afterLSP = ''
          function table.shallow_copy(t)
            local t2 = {}
            for k,v in pairs(t) do
              t2[k] = v
            end
            return t2
          end

          local clangd_caps = table.shallow_copy(capabilities)
          clangd_caps.offsetEncoding = { "utf-16" }

          require("clangd_extensions").setup {
            server = {
          		capabilities = clangd_caps,
      on_attach = on_attach,
          		init_options = {clangdFileStatus = true},
         	 },
          }
    '';
  };
}
