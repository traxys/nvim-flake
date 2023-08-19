{
  config,
  pkgs,
  helpers,
  lib,
  ...
}:
with lib; {
  options.plugins.efmls-configs = {
    enable = mkEnableOption "efmls-configs, premade configurations for efm-langserver";

    package = helpers.mkPackageOption "efmls-configs-nvim" pkgs.vimPlugins.efmls-configs-nvim;

    extraInitOptions = mkOption {
      type = types.attrsOf types.anything;
      default = {};
      description = "Additional options to pass to efmls-configs-nvim.init";
    };

    /*
    Users can set the options as follows:

    {
      c = {
        linter = "cppcheck";
        formatter = ["clang-format" "uncrustify"];
      };
      go = {
        linter = ["djlint" "golangci_lint"];
      };
    }
    */
    setup = let
      tools = trivial.importJSON ./efmls-configs-tools.json;
      inherit (tools) linters formatters;
      languageTools = lang: tools:
        builtins.attrNames (attrsets.filterAttrs (_: lists.any (e: e == lang)) tools);

      miscLinters = languageTools "misc" linters;
      miscFormatters = languageTools "misc" formatters;

      searchLanguages = tools: (lists.unique (builtins.concatLists (builtins.attrValues tools)));
      languages =
        lists.filter
        (v: v != "misc") (lists.unique ((searchLanguages linters) ++ (searchLanguages formatters)));

      mkChooseOption = kind: possible: let
        toolType = with types; either (enum possible) helpers.rawType;
      in
        mkOption {
          type = with types; either toolType (listOf toolType);
          default = [];
          description = "${kind} tools for ${lang}";
        };
    in
      (builtins.listToAttrs (builtins.map (lang: let
          langTools = languageTools lang;
        in {
          name = lang;
          value = {
            linter = mkChooseOption "linter" ((langTools linters) ++ miscLinters);
            formatter = mkChooseOption "formatter" ((langTools formatters) ++ miscFormatters);
          };
        })
        languages))
      // {
        all = {
          linter = mkChooseOption "linter" miscLinters;
          formatter = mkChooseOption "formatter" miscFormatters;
        };
      };
  };

  config = let
    cfg = config.plugins.efmls-configs;

    # Mapping of tool name to the nixpkgs package (if any)
    toolPkgs = {
      inherit
        (pkgs)
        ameba
        astyle
        bashate
        black
        cbfmt
        clazy
        cppcheck
        cpplint
        dmd
        dprint
        fish
        flawfinder
        gcc
        golines
        golint
        hadolint
        joker
        languagetool
        nixfmt
        php
        prettierd
        proselint
        pylint
        rubocop
        rustfmt
        shellcheck
        shfmt
        smlfmt
        statix
        stylua
        uncrustify
        vale
        yamllint
        yapf
        ;
      inherit (pkgs.python3.pkgs) autopep8 flake8 vulture;
      inherit (pkgs.nodePackages) eslint eslint_d prettier alex stylelint textlint write-good;
      inherit (pkgs.phpPackages) phpcbf phan phpcs phpstan psalm;
      inherit (pkgs.luaPackages) luacheck;
      ansible_lint = pkgs.ansible-lint;
      clang_format = pkgs.clang-tools;
      clang_tidy = pkgs.clang-tools;
      clj_kondo = pkgs.clj-kondo;
      dartfmt = pkgs.dart;
      dotnet_format = pkgs.dotnet-runtime;
      fish_indent = pkgs.fish;
      gofmt = pkgs.go;
      goimports = pkgs.go-tools;
      golangci_lint = pkgs.golangci-lint;
      go_revive = pkgs.revive;
      lua_format = pkgs.luaformatter;
      mcs = pkgs.mono;
      php_cs_fixer = pkgs.phpPackages.php-cs-fixer;
      slither = pkgs.slither-analyzer;
      staticcheck = pkgs.go-tools;
      terraform_fmt = pkgs.terraform;
      vint = pkgs.vim-vint;
    };

    toolAsList = tools:
      if builtins.isList tools
      then tools
      else [tools];

    # Tools that have been selected by the user
    tools = lists.unique (builtins.filter builtins.isString (
      builtins.concatLists (
        builtins.map (lang: (toolAsList lang.linter) ++ (toolAsList lang.formatter))
        (builtins.attrValues cfg.setup)
      )
    ));

    pkgsToInstall =
      builtins.map (v: toolPkgs.${v})
      (builtins.filter (v: builtins.hasAttr v toolPkgs) tools);

    initOptions =
      {
        on_attach.__raw = "__lspOnAttach";
        capabilities.__raw = "__lspCapabilities";
      }
      // cfg.extraInitOptions;

    mkToolOption = kind: opt:
      builtins.map
      (tool:
        if builtins.isString tool
        then helpers.mkRaw "require 'efmls-configs.${kind}.${tool}'"
        else tool)
      (toolAsList opt);

    setupOptions =
      (builtins.mapAttrs (_: {
          linter,
          formatter,
        }: {
          linter = mkToolOption "linters" linter;
          formatter = mkToolOption "formatters" formatter;
        })
        (attrsets.filterAttrs (v: _: v != "all") cfg.setup))
      // {
        "=" = {
          linter = mkToolOption "linters" cfg.setup.all.linter;
          formatter = mkToolOption "formatters" cfg.setup.all.formatter;
        };
      };
  in
    mkIf cfg.enable {
      extraPlugins = [cfg.package];

      plugins.lsp.postConfig = ''
        local efmls = require 'efmls-configs'
        efmls.init(${helpers.toLuaObject initOptions})
        efmls.setup(${helpers.toLuaObject setupOptions})
      '';

      extraPackages = [pkgs.efm-langserver] ++ pkgsToInstall;
    };
}
