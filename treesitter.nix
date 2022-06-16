{
  vim.treesitter = {
    enable = true;

    indent = true;
    completion = true;

    ensureInstalled = [
      "rust"
      "c"
      "cpp"
      "json"
      "lua"
      "python"
      "toml"
      "latex"
      "nix"
      "vue"
      "javascript"
      "dart"
      "make"
      "query"
      "lalrpop"
    ];

    context = {
      enable = true;
    };

    refactor = {
      enable = true;

      highlightDefinitions = {
        enable = true;
        clearOnCursorMove = true;
      };

      navigation = {
        enable = true;
        gotoDefinition = "gd";
        lspFallback = true;
      };
    };
  };
}
