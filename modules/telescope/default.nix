{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.vim.telescope;
in {
  options.vim.telescope.enable = mkOption {
    type = types.bool;
    description = "Enable telescope.nvim";
    default = false;
  };

  config = mkIf cfg.enable {
    vim.plenary = true;
    vim.startPlugins = with pkgs.neovimPlugins; [
      telescope
      telescope-ui-select
    ];

    vim.luaConfigRC = ''
      require("telescope").setup {
        extensions = {
          ["ui-select"] = {
            require("telescope.themes").get_dropdown {
              -- even more opts
            }
          }
        }
      }
      -- To get fzf loaded and working with telescope, you need to call
      -- load_extension, somewhere after setup function:
      require("telescope").load_extension("ui-select")
    '';
  };
}
