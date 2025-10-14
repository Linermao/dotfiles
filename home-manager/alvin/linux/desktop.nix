{ inputs, pkgs, ... }:

{
  # ---- quickshell ----
  programs.quickshell.enable = true;

  # ---- caelestia ----
  home.packages = with pkgs; [
    inputs.caelestia-shell.packages.${pkgs.system}.caelestia-shell
    inputs.caelestia-shell.inputs.caelestia-cli.packages.${system}.caelestia-cli
  ];
  home.file = {
    ".config/caelestia" = {
      source = ./../configs/.config/caelestia;
      recursive = true;
      force = true;
    };
  };
  home.file = {
    ".config/swappy" = {
      source = ./../configs/.config/swappy;
      recursive = true;
      force = true;
    };
  };

  # ---- hyprland ----
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
    extraConfig = " "; # clear warnings
  };
  home.file = {
    ".config/hypr" = {
      source = ./../configs/.config/hypr;
      recursive = true;
      force = true;
    };
  };
  # variables
  home.sessionVariables = {
    NIXOS_OZONE_WL = 1;
    __GL_GSYNC_ALLOWED = 0;
    __GL_VRR_ALLOWED = 0;
    _JAVA_AWT_WM_NONEREPARENTING = 1;
    DISABLE_QT5_COMPAT = 0;
    GDK_BACKEND = "wayland";
    ANKI_WAYLAND = 1;
    DIRENV_LOG_FORMAT = "";
    WLR_DRM_NO_ATOMIC = 1;
    MOZ_ENABLE_WAYLAND = 1;
    WLR_BACKEND = "vulkan";
    WLR_RENDERER = "vulkan";
    WLR_NO_HARDWARE_CURSORS = 1;
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_TYPE = "wayland";
    XDG_SESSION_DESKTOP = "Hyprland";
    SDL_VIDEODRIVER = "wayland";
    CLUTTER_BACKEND = "wayland";
  };
}