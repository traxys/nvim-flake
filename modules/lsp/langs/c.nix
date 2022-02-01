{ config, lib, pkgs, ... }:

with lib;
with builtins;

let
  cfg = config.vim.lsp.lang;
in
{
  config.vim.lsp = mkIf cfg.c.enable {
    luaLocals = ''
      function table.shallow_copy(t)
        local t2 = {}
        for k,v in pairs(t) do
          t2[k] = v
        end
        return t2
      end

      local clangd_caps = table.shallow_copy(capabilities)
      clangd_caps.offsetEncoding = { "utf-16" }
      	'';

    servers.clangd = {
      enable = true;
      initOptions = mkDefault "{clangdFileStatus = true}";
      capabilities = mkDefault "clangd_caps";
    };
  };
}
