{
  config,
  pkgs,
  lib,
  naersk-lib,
  stylua,
  ...
}: {
  home.packages = with pkgs; [
    neovimTraxys
    rust-analyzer
    clang-tools
    nodePackages.bash-language-server
    rnix-lsp
    alejandra
    (naersk-lib.buildPackage {
      pname = "stylua";
      root = stylua;
    })
    shellcheck
    ripgrep
  ];

  home.sessionVariables.EDITOR = "nvim";
}
