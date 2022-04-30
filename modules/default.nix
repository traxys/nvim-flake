{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./core
    ./basic
    ./git
    ./theme
    ./treesitter
    ./visuals
    ./filetree
    ./filetype
    ./lsp
    ./statusline
    ./telescope
    ./completion
  ];
}
