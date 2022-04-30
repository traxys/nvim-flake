{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.filetype;
  luaAttrArgs = attr: map (key: ''["${key}"] = "${getAttr key attr}"'') (attrNames attr);
  luaAttr = attr: "{${concatStringsSep "," (luaAttrArgs attr)}}";
in {
  options.vim.filetype = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable filetype.nvim";
    };

    extensions = mkOption {
      type = types.attrsOf types.str;
      description = "Set filenames of name *.{key} to filetype {value}";
    };

    literal = mkOption {
      type = types.attrsOf types.str;
      description = "Set filenames of name {key} to filetype {value}";
    };
  };

  config = mkIf cfg.enable {
    vim.filetype.extensions = mkDefault {};
    vim.filetype.literal = mkDefault {};

    vim.startPlugins = with pkgs.neovimPlugins; [filetype-nvim];

    vim.luaConfigRC = ''
      require("filetype").setup({
        overrides = {
          extensions = ${luaAttr cfg.extensions},
          literal = ${luaAttr cfg.literal},
        }
      })
    '';
  };
}
