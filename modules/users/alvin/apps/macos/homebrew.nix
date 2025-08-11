{ ... }:

{
  # because of the homebrew module is not in the home-manager inputs
  # so this file is managed by nix-darwin directly

  homebrew = {
    enable = true;
    brews = [
      "git"
      "mas" # Mac App Store CLI
    ];
    casks = [
    ];
    masApps = {
      "WeChat" = 836500024;
      # "shadowrocket"  = 932747118;
    };
    onActivation.cleanup = "zap";
    onActivation.autoUpdate = true;
    onActivation.upgrade = true;
  };
}