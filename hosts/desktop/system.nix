{ config, paths, host, ... }:

{
  # ---- boot loader ----
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # ---- i2c bus ----
  boot.kernelModules = [ "i2c-dev" ];
  services.udev.extraRules = ''
    KERNEL=="i2c-[0-9]*", GROUP="i2c", MODE="0660"
  '';

  # ---- services ----
  services.dbus.enable = true;
  services.openssh.enable = true;

  # ---- network ----
  networking.hostName = "${host}";
  networking.networkmanager.enable = true;
  networking.firewall = {
    enable = true;
    # sunshine
    allowedTCPPorts = [ 22 47984 47989 47990 48010 ];
    # always allow traffic from your Tailscale network
    trustedInterfaces = [ "tailscale0" ];
    # allow the Tailscale UDP port through the firewall
    allowedUDPPorts = [ config.services.tailscale.port ];
    allowedUDPPortRanges = [
      { from = 47998; to = 48000; }
      { from = 8000; to = 8010; }
    ];
  };

  # ---- bluetooth ----
  hardware.bluetooth.enable = true;

  # ---- upower ----
  services.upower.enable = true;
  
  # ---- cpu ----
  powerManagement.cpuFreqGovernor = "performance";

  # ---- time zone ----
  time.timeZone = "Asia/Shanghai";

  # ---- path ----
  environment.sessionVariables = {
    NIX_ROOT = "${paths.root}";
  };

  # ---- system version ----
  system.stateVersion = "25.05";
}
