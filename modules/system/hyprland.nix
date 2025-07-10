{ inputs, pkgs, ... }:

{
  programs.hyprland = {
    enable = true;
  };

  services.dbus.enable = true;
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [ xdg-desktop-portal-hyprland ];
  };
}
