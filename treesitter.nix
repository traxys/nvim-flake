{
  vim.treesitter = {
    enable = true;
    indent = true;
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
    ];

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
