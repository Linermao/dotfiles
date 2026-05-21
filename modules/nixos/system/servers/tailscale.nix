{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    tailscale
  ];

  services.tailscale = {
    enable = true;
    openFirewall = true;
    # Keep Tailscale as a mesh VPN client only.
    extraSetFlags = [
      "--accept-dns=false"
      "--accept-routes=false"
    ];
  };
}
