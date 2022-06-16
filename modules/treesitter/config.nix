{
  config,
  lib,
  pkgs,
  ...
}:
with lib; {
  config = {
    vim.treesitter = {
      enable = mkDefault false;
      indent = mkDefault false;
      completion = mkDefault false;
      ensureInstalled = mkDefault [];
      highlightDisabled = mkDefault [];

	  context = {
		enable = mkDefault false;
	  };

      refactor = {
        enable = mkDefault false;

        highlightDefinitions = {
          enable = mkDefault false;
          clearOnCursorMove = mkDefault true;
        };

        smartRename = {
          enable = mkDefault false;
          keymap = mkDefault "grr";
        };

        highlightScope = mkDefault false;

        navigation = {
          enable = mkDefault false;

          gotoDefinition = mkDefault "gnd";
          listDefinitions = mkDefault "gnD";
          listDefinitionsToc = mkDefault "gO";
          gotoNextUsage = mkDefault "<a-*>";
          gotoPreviousUsage = mkDefault "<a-#>";

          lspFallback = mkDefault false;
        };
      };
    };
  };
}
