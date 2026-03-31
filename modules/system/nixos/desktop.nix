{ inputs, pkgs, ... }:

{
  # ---- xserver ----
  services.xserver.enable = true;
  services.xserver.xkb.layout = "us";

  # ---- hyprland ----
  programs.hyprland = {
    enable = true;
  };
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [ xdg-desktop-portal-hyprland ];
  };

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
