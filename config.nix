{pkgs, ...}: {
  config = {
    colorschemes.tokyonight = {
      style = "night";
      enable = true;
    };

    options = {
      termguicolors = true;
      number = true;
      tabstop = 4;
      shiftwidth = 4;
      scrolloff = 7;
      signcolumn = "yes";
      cmdheight = 2;
      completopt = "menu,menuone,noselect";
      updatetime = 300;
      colorcolumn = "100";
      spell = true;
    };

    commands = {
      "SpellFr" = "setlocal spelllang=fr";
    };

    plugins = {
      osc52.enable = true;
      null-ls = {
        enable = true;
        sourcesItems = [
          {
            __raw = "require('null-ls').builtins.code_actions.gitsigns";
          }
        ];
      };
      gitsigns.enable = true;
    };

    extraPlugins = with pkgs.vimPlugins; [plenary-nvim];
  };
}
