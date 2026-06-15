{
  inputs,
  config,
  hostConfig,
  pkgs,
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
  # use dms
  imports = [
    inputs.dms.homeModules.dank-material-shell
  ];

  programs.dank-material-shell = {
    enable = true;

    systemd = {
      enable = true;
      restartIfChanged = true;
    };

    enableSystemMonitoring = false;
    enableVPN = true;
    enableDynamicTheming = true;
    enableAudioWavelength = true;
    enableCalendarEvents = false;
    enableClipboardPaste = false;
  };

  systemd.user.services.dms.Service.Environment = [
    # Quickshell currently crashes in the fcitx Qt6 input context on Qt 6.11.
    "QT_IM_MODULE=compose"
  ];

  home.sessionVariables = {
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
  };

  home.packages = with pkgs; [
    qt6.qtdeclarative
  ];

  xdg.configFile = mkOutOfStoreConfigTree {
    sourceDir = root + "/assets/config/niri";
    targetPrefix = "niri";
  };
}
