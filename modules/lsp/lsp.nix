{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.lsp;

  serverOptions = with types; {
    options = {
      enable = mkOption {
        type = bool;
        description = "Enable this server";
        default = false;
      };
      cmd = mkOption {
        type = nullOr (listOf str);
        description = "Command for the lsp server";
        default = null;
      };
      handlers = mkOption {
        type = nullOr str;
        description = "Custom handler";
        default = null;
      };
      initOptions = mkOption {
        type = nullOr str;
        description = "Init options";
        default = null;
      };
      settings = mkOption {
        type = commas;
        description = "Configuration for the LSP server";
        default = "";
      };
      capabilities = mkOption {
        type = nullOr str;
        description = "Overrite global capabilities";
        default = null;
      };
    };
  };
in {
  options.vim.lsp = {
    enable = mkOption {
      type = types.bool;
      description = "Enable native LSP support";
    };

    capabilities = mkOption {
      type = types.lines;
      description = "LSP capabilities: A function that takes `capabilities` and returns that variable";
    };
    luaLocals = mkOption {
      type = types.lines;
      description = "Lua statements that have access to capabilities & on_attach and are accessible in the servers";
    };
    onAttach = mkOption {
      type = types.lines;
      description = "On attach function (takes arguments client,buffer)";
    };
    servers = mkOption {
      type = types.attrsOf (types.submodule serverOptions);
      description = "Server configurations";
    };
    lightbulb = mkOption {
      type = types.bool;
      description = "Enable nvim-lightbulb: show a lightbulb when a code action is availaible";
    };

    lspLoading = {
      enable = mkOption {
        type = types.bool;
        description = "Show lsp loading information as virtual text";
      };
    };

    diagnosticsPopup = mkOption {
      type = types.bool;
      description = "Enable a diagnostics popup";
    };

    signatures = {
      enable = mkOption {
        type = types.bool;
        description = "Enable signature popus [lsp_signature]";
      };
    };

    format = {
      enable = mkOption {
        type = types.bool;
        description = "Enable formatting options";
      };

      command = mkOption {
        type = types.str;
        description = "Command to trigger formatting";
      };

      disabledClients = mkOption {
        type = types.listOf types.str;
        description = "Disable formatting for certain clients";
      };
    };

    null-ls = {
      enable = mkOption {
        type = types.bool;
        description = "Enable null-ls";
      };

      sources = mkOption {
        type = types.listOf types.str;
        description = "Enabled sources";
      };
    };

    afterLSP = mkOption {
      type = types.lines;
      description = "After LSP lua lines";
    };

    lang = {
      c = {
        enable = mkOption {
          type = types.bool;
          description = "Enable clangd";
        };
      };

      nix = {
        enable = mkOption {
          type = types.bool;
          description = "Enable rnix-lsp";
        };
      };

      bash = {
        enable = mkOption {
          type = types.bool;
          description = "Enable bash-language-server";
        };
      };

      rust = {
        enable = mkOption {
          type = types.bool;
          description = "Enable rust-analyzer";
        };

        crates = {
          enable = mkOption {
            type = types.bool;
            description = "Enable crates support";
          };

          completion = mkOption {
            type = types.bool;
            description = "Enable completion in nvim-cmp";
          };
        };

        settings = {
          cargo = {
            allFeatures = mkOption {
              type = types.bool;
              description = "Enable all cargo features";
            };
          };
          checkOnSave = {
            command = mkOption {
              type = types.str;
              description = "cargo command to execute on save";
            };
          };
        };
      };
    };
  };

  config = let
    writeIf = cond: msg:
      if cond
      then msg
      else "";
    luaList = l: concatStringsSep "," (map (s: ''"${s}"'') l);
    makeServer = name: options: "${writeIf options.enable ''
        require("lspconfig")["${name}"].setup({
          ${writeIf (options.cmd != null) ''
        cmd = {${luaList options.cmd}},
      ''}
          ${writeIf (options.handlers != null) ''
        handlers = ${options.handlers},
      ''}
          ${writeIf (options.initOptions != null) ''
        init_options = ${options.initOptions},
      ''}
          ${writeIf (options.settings != null) ''
        settings = {${options.settings}},
      ''}
          capabilities = ${
        if options.capabilities != null
        then options.capabilities
        else "capabilities"
      },
      on_attach = on_attach,
        });
    ''}";
    makeServers = servers: map (server: makeServer server (getAttr server servers)) (attrNames servers);
  in
    mkIf cfg.enable {
      vim.startPlugins = with pkgs.neovimPlugins; [
        nvim-lspconfig
		inc-rename
        (
          if cfg.signatures.enable
          then lsp_signature
          else null
        )
        (
          if cfg.null-ls.enable
          then null-ls
          else null
        )
        (
          if cfg.lightbulb
          then nvim-lightbulb
          else null
        )
		(
		  if cfg.lspLoading.enable
		  then fidget
		  else null
		)
      ];

      vim.configRC = ''
        ${writeIf cfg.lightbulb "autocmd CursorHold,CursorHoldI * lua require'nvim-lightbulb'.update_lightbulb()"}
        ${writeIf cfg.diagnosticsPopup "autocmd CursorHold * lua vim.diagnostic.open_float()"}
      '';

      vim.luaConfigRC = let
        nullLsSources = sources: concatStringsSep "," (map (source: "null_ls.${source}") sources);
        disabledClientsCheck =
          if cfg.format.disabledClients == []
          then "true"
          else concatStringsSep " and " (map (client: ''client.name ~= "${client}"'') cfg.format.disabledClients);
      in ''
	  	 require("inc_rename").setup()
        ${writeIf cfg.format.enable ''
          local lsp_formatting = function(bufnr)
          	vim.lsp.buf.format({
          		filter = function(client)
          			return ${disabledClientsCheck}
          		end,
          		bufnr = bufnr,
          	})
          end

          local lsp_formatting_cmd = function()
          	lsp_formatting(nil)
          end

          vim.api.nvim_create_user_command('${cfg.format.command}', lsp_formatting_cmd, {})
        ''}

                       ${writeIf cfg.signatures.enable "require'lsp_signature'.setup()"}

                       local on_attach = function(client,buffer)
                          ${cfg.onAttach}
                       end

                       ${writeIf cfg.null-ls.enable ''
          local null_ls = require("null-ls")
          local sources = {
            ${nullLsSources cfg.null-ls.sources}
          }
          null_ls.setup({
            sources = sources,
            on_attach = on_attach,
          })
        ''}

                       local capabilities = (function(capabilities)
                           ${cfg.capabilities}
                         return capabilities
                       end)(vim.lsp.protocol.make_client_capabilities())

                       ${cfg.luaLocals}

                       ${concatStringsSep "\n" (makeServers cfg.servers)}

					   ${writeIf cfg.lspLoading.enable ''require"fidget".setup{}''}

             		  ${cfg.afterLSP}
      '';
    };
}
