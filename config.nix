{...}: {
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

    plugins = {
      osc52.enable = true;
    };
  };
}
