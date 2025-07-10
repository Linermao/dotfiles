{ pkgs, ... }:

{
  services.dbus.enable = true;
  services.openssh.enable = true;

  # xservice
  services.xserver.enable = true;
  services.xserver.xkb.layout = "us";
}
