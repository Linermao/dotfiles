{
  inputs,
  hostConfig,
  pkgs,
  root,
  ...
}:
{
  imports = [
    inputs.dms.nixosModules.greeter
  ];

  programs.niri.enable = true;
  programs.dank-material-shell.greeter = {
    enable = true;
    compositor.name = "niri";
  };

  environment.systemPackages = with pkgs; [
    xwayland-satellite
  ];

  security.polkit.enable = true;
  security.pam.services.swaylock = { };

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
  };

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };
}
