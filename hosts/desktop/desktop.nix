{ inputs, pkgs, ... }:

{
  # ---- xserver ----
  services.xserver.enable = true;
  services.xserver.xkb.layout = "us";

  # ---- input ----
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.inputMethod = {
    type = "fcitx5";
    enable = true;
    fcitx5.addons = with pkgs; [
      fcitx5-gtk
      fcitx5-chinese-addons
      fcitx5-nord
      fcitx5-rime
    ];
  };

  # ---- sound ----
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  # ---- hyprland ----
  programs.hyprland = {
    enable = true;
  };
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [ xdg-desktop-portal-hyprland ];
  };

  # ---- recorder ----
  programs.gpu-screen-recorder.enable = true;

  # ---- sddm ----
  environment.systemPackages = with pkgs; [
    (pkgs.sddm-astronaut.override {
      embeddedTheme = "pixel_sakura";
    })
  ];
  services.displayManager.sddm = {
    enable = true;
    theme = "sddm-astronaut-theme";
    wayland.enable = false;
    package = pkgs.kdePackages.sddm; # use qt6
    extraPackages = with pkgs; [
      kdePackages.qtsvg
      kdePackages.qtvirtualkeyboard
      kdePackages.qtmultimedia
    ];
  };
}
