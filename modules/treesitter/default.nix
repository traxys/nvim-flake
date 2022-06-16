{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.treesitter;
  writeIf = cond: msg:
    if cond
    then msg
    else "";
  luaList = l: concatStringsSep "," (map (s: ''"${s}"'') l);
  luaBool = b:
    if b
    then "true"
    else "false";
in {
  imports = [./config.nix ./refactor.nix];

  options.vim.treesitter = {
    enable = mkOption {
      type = types.bool;
      description = "enable nvim-treesitter";
    };

    completion = mkOption {
      type = types.bool;
      description = "enable completions using tree-sitter (requires enabling completions)";
    };

    indent = mkOption {
      type = types.bool;
      description = "Indentation based on treesitter for the = operator. NOTE: This is an experimental feature";
    };

    ensureInstalled = mkOption {
      type = types.listOf types.str;
      description = "Languages to be installed";
    };

    highlightDisabled = mkOption {
      type = types.listOf types.str;
      description = "Languages to skip highlighting";
    };

    setup = mkOption {
      type = types.commas;
      description = "content of treesitter setup";
      default = "";
    };
    context = {
      enable = mkOption {
        type = types.bool;
        description = "Enable tree-sitter context";
      };
    };

    extraParsers = mkOption {
      type = types.listOf (types.submodule {
        options = {
          name = mkOption {
            type = types.str;
            description = "Name of the parser";
          };
          url = mkOption {
            type = types.str;
            description = "local path of git repo";
          };
          files = mkOption {
            type = types.listOf types.str;
            description = "Additionnal files";
          };
          filetype = mkOption {
            type = types.nullOr types.str;
            description = "Filetype";
            default = null;
          };
        };
      });
      description = "Additionnal parsers to include";
      default = [];
    };
  };

  config = mkIf cfg.enable {
    vim.startPlugins = with pkgs.neovimPlugins; [
      nvim-treesitter
      (
        if cfg.context.enable
        then nvim-treesitter-context
        else null
      )
    ];

    vim.treesitter.setup = ''
      indent = {
        enable = ${luaBool cfg.indent},
      },
      ensure_installed = {${luaList cfg.ensureInstalled}},
      highlight = {
        enable = true,
        disable = {${luaList cfg.highlightDisabled}},
      }
    '';

    vim.luaConfigRC = let
      configureParser = {
        name,
        url,
        files,
        filetype,
      }: ''
        parser_config.${name} = {
        	install_info = {
        		url = "${url}",
        		files = {${luaList files}},
        	},
        }
        ${writeIf (filetype != null) ''filetype = "${filetype}"''}
      '';
      extraParsers = concatStringsSep "\n" (map configureParser cfg.extraParsers);
    in ''
      local parser_config = require "nvim-treesitter.parsers".get_parser_configs()

      ${extraParsers}

      require("nvim-treesitter.configs").setup({
        ${cfg.setup}
      })

	  ${writeIf cfg.context.enable ''
		require'treesitter-context'.setup{
		}
	  ''}
    '';
  };
}
