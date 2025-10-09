{ pkgs, ... }:

{
  systemd.user.targets.hyprland-session.Unit.Wants = [
    "xdg-desktop-autostart.target"
  ];

  wayland.windowManager.hyprland = {
    enable = true;

    xwayland = {
      enable = true;
      # hidpi = true;
    };
    # enableNvidiaPatches = false;
    systemd.enable = true;
    extraConfig = ""; # clear warnings
  };

  # User-specific configuration files
  home.file = {
    ".config/hypr" = {
      source = ../../../configs/.config/hypr;
      recursive = true;
      force = true;
    };
  };
}