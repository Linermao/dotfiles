{
  config,
  hostConfig,
  lib,
  pkgs,
  root,
  ...
}:

let
  mkOutOfStoreConfigTree = import (root + "/modules/nixos/home/lib/mkOutOfStoreConfigTree.nix") {
    inherit config lib;
  };
in
{
  home.packages = [ pkgs.neovim ];

  xdg.configFile = mkOutOfStoreConfigTree {
    sourceDir = "${hostConfig.repoRoot}/assets/config/nvim";
    targetPrefix = "nvim";
    exclude = [
      ".gitignore"
      "README.md"
    ];
  };
}
