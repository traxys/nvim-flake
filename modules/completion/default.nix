{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.completion;
  mkSources = sources:
    listToAttrs (map
      (source: {
        name = source;
        value = {
          enable = mkOption {
            type = types.bool;
            description = "Enable source ${source}";
            default = false;
          };
        };
      })
      sources);
  mkSourceModule = sources: {
    options = mkSources sources;
  };

  sourceModule = mkSourceModule (map (source: source.name) sourceDefs);

  sources = builtins.filter (s: (match "cmp-source-.*" s) != null) (attrNames pkgs.neovimPlugins);
  sourceName = source:
    substring
    (stringLength "cmp-source-")
    (stringLength source)
    source;

  sourceDefs =
    map (source: {
      name = sourceName source;
      pkg = getAttr source pkgs.neovimPlugins;
    })
    sources;

  enabledSources =
    if cfg.sources == null
    then []
    else filter (source: (getAttr source cfg.sources).enable) (attrNames cfg.sources);

  sourcePkgs = listToAttrs (map (source: {
      name = source.name;
      value = source.pkg;
    })
    sourceDefs);

  enabledSourcesPkgs = map (source: getAttr source sourcePkgs) enabledSources;

  hasLspSource =
    if cfg.sources == null
    then false
    else any (s: s == "nvim_lsp") enabledSources;
in {
  imports = [./config.nix];

  options.vim.completion = {
    enable = mkOption {
      type = types.bool;
      description = "Enable nvim-cmp";
    };
    sources = mkOption {
      type = types.nullOr (types.submodule sourceModule);
      description = "Source definitions";
    };

    icons = {
      enable = mkOption {
        type = types.bool;
        description = "Enable icons in completion menu";
      };

      withText = mkOption {
        type = types.bool;
        description = "Show text with icons";
      };

      maxWidth = mkOption {
        type = types.nullOr types.int;
        description = "Max width of menu item";
      };
    };

    mapping = mkOption {
      type = types.attrsOf types.str;
      description = "Nvim cmp mappings (can use cmp.[...])";
    };
  };

  config = mkIf cfg.enable {
    vim.startPlugins = with pkgs.neovimPlugins;
      [
        nvim-cmp
        vim-vsnip
        (
          if cfg.icons.enable
          then lspkind
          else null
        )
      ]
      ++ enabledSourcesPkgs;

    vim.lsp.capabilities = mkIf (config.vim.lsp.enable && hasLspSource) ''
      capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)
    '';

    vim.completion.sources.treesitter.enable = mkIf config.vim.treesitter.completion true;

    vim.luaConfigRC = let
      sourceCfg = source: ''{ name = "${source}"}'';
      sourcesCfg = sources: concatStringsSep "," (map sourceCfg sources);

      createMapping = key: cmd: ''["${key}"] = ${cmd}'';
      mappingCfg = mappings:
        concatStringsSep "," (
          map (name: createMapping name (getAttr name mappings)) (attrNames mappings)
        );

      luaBool = b:
        if b
        then "true"
        else "false";
      writeIf = cond: msg:
        if cond
        then msg
        else "";
    in ''
      local cmp = require("cmp")

      ${writeIf cfg.icons.enable "local lspkind = require('lspkind')"}

      cmp.setup({
        ${writeIf cfg.icons.enable ''
        formatting = {
          format = lspkind.cmp_format({
               with_text = ${luaBool cfg.icons.withText},
              ${writeIf (cfg.icons.maxWidth != null) "maxwidth = ${toString cfg.icons.maxWidth},"}

              before = function (entry, vim_item)
                return vim_item
              end
          })
        },
      ''}
        snippet = {
          expand = function(args)
            vim.fn["vsnip#anonymous"](args.body)
          end,
        },
        mapping = {
           ${mappingCfg cfg.mapping}
        },
        sources = {
          ${sourcesCfg enabledSources}
        }
      })
    '';
  };
}
