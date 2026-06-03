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
  programs.yazi = {
    enable = true;
    shellWrapperName = "y";
  };

  xdg.configFile = mkOutOfStoreConfigTree {
    sourceDir = "${hostConfig.repoRoot}/assets/config/yazi";
    targetPrefix = "yazi";
  };
}
