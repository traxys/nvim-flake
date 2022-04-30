{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.filetree;
  luaBool = b:
    if b
    then "true"
    else "false";
in {
  options.vim.filetree = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable nvim-tree.lua";
    };
    autoClose = mkOption {
      type = types.bool;
      description = "force closing neovim when the tree is the last window in the view";
    };

    diagnostics = {
      enable = mkOption {
        type = types.bool;
        description = "show lsp diagnostics in the signcolumn";
      };

      showOnDirs = mkOption {
        type = types.bool;
        description = "if the node with diagnostic is not visible, then show diagnostic in the parent directory";
      };
    };
  };

  config = mkIf cfg.enable {
    vim.filetree.autoClose = mkDefault false;
    vim.filetree.diagnostics.enable = mkDefault false;
    vim.filetree.diagnostics.showOnDirs = mkDefault false;

    vim.startPlugins = with pkgs.neovimPlugins; [nvim-tree-lua];

    vim.configRC = mkIf cfg.autoClose ''
      autocmd BufEnter * ++nested if winnr('$') == 1 && bufname() == 'NvimTree_' . tabpagenr() | quit | endif
    '';

    vim.luaConfigRC = ''
        require("nvim-tree").setup({
          diagnostics = {
              enable = ${luaBool cfg.diagnostics.enable},
              show_on_dirs = ${luaBool cfg.diagnostics.showOnDirs},
          },
      })
    '';
  };
}
