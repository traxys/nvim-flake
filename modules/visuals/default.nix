{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.visuals;
  writeIf = cond: msg:
    if cond
    then msg
    else "";
  luaBool = b:
    if b
    then "true"
    else "false";
in {
  options.vim.visuals = {
    nvimWebDevicons = {
      enable = mkOption {
        type = types.bool;
        description = "Enable icons [nvim-web-devicons]";
      };

      default = mkOption {
        type = types.bool;
        description = "Enable default icons globally";
      };
    };

    indentline = {
      enable = mkOption {
        type = types.bool;
        description = "Enable indentline";
      };
      showContext = mkOption {
        type = types.bool;
        description = "Show current context";
      };
      showContextStart = mkOption {
        type = types.bool;
        description = "Show start of current context";
      };
    };

    plantumlSyntax = {
      enable = mkOption {
        type = types.bool;
        description = "Enable plantuml syntax";
      };
    };
  };

  config = {
    vim.visuals.nvimWebDevicons.enable = mkDefault false;
    vim.visuals.nvimWebDevicons.default = mkDefault false;
    vim.visuals.indentline = {
      enable = mkDefault false;
      showContext = mkDefault false;
      showContextStart = mkDefault false;
    };
    vim.visuals.plantumlSyntax.enable = mkDefault false;

    vim.startPlugins = with pkgs.neovimPlugins; [
      (
        if cfg.nvimWebDevicons.enable
        then nvim-web-devicons
        else null
      )
      (
        if cfg.indentline.enable
        then indent-blankline
        else null
      )
      (
        if cfg.plantumlSyntax.enable
        then plantuml-syntax
        else null
      )
    ];

    /*
      vim.g.indentLine_concealcursor = "inc"
     vim.g.indentLine_conceallevel = 2
     vim.g.indentLine_fileTypeExclude = { "markdown", "json" }
     */
    vim.luaConfigRC = ''
      ${writeIf cfg.indentline.enable ''
        require("indent_blankline").setup {
        	show_current_context = ${luaBool cfg.indentline.showContext},
        	show_current_context_start = ${luaBool cfg.indentline.showContextStart},
         }
      ''}
      ${writeIf cfg.nvimWebDevicons.enable ''
        require("nvim-web-devicons").setup({ default = ${luaBool cfg.nvimWebDevicons.default} })
      ''}
    '';
  };
}
