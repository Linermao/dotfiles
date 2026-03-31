{ pkgs, ... }:

{
  # ---- tailscale ----
  environment.systemPackages = with pkgs; [
    tailscale
  ];

  services.tailscale.enable = true;
  systemd.services.tailscale-autoconnect = {
    description = "Automatic connection to Tailscale";
    # make sure tailscale is running before trying to connect to tailscale
    after = [ "network-pre.target" "tailscale.service" ];
    wants = [ "network-pre.target" "tailscale.service" ];
    wantedBy = [ "multi-user.target" ];
    # set this service as a oneshot job
    serviceConfig.Type = "oneshot";
  };
}
