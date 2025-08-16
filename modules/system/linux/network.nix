{ pkgs, host, config, ... }:

{
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
}
