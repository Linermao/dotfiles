{ pkgs, ... }:

{
  systemd.user.targets.hyprland-session.Unit.Wants = [
    "xdg-desktop-autostart.target"
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    package = null;
    portalPackage = null;

    xwayland = {
      enable = true;
      # hidpi = true;
    };
    # enableNvidiaPatches = false;
    systemd.enable = true;
  };

  home.file = {
    ".config/hypr" = {
      source = ../../configs/.config/hypr;
      recursive = true;
      force = true;
    };
  };
}