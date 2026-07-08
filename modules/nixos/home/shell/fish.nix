{
  config,
  hostConfig,
  lib,
  root,
  ...
}:

let
  mkOutOfStoreConfigTree = import (root + "/modules/nixos/home/lib/mkOutOfStoreConfigTree.nix") {
    inherit config lib;
  };
in
{
  programs.fish.enable = true;

  xdg.configFile = mkOutOfStoreConfigTree {
    sourceDir = hostConfig.repoRoot + "/assets/config/fish/linux";
    targetPrefix = "fish/conf.d";
  };
}
