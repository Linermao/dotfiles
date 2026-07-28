{ pkgs, ... }:

{
  programs.clash-verge = {
    enable = true;
    package = pkgs.clash-verge-rev;
    serviceMode = true;
    autoStart = true;
    tunMode = true;
  };

  # Tailscale interoperability
  #
  # Clash Verge stores these settings in its mutable GUI state; this NixOS
  # module only enables TUN mode.
  #
  # 1. Exclude Tailscale and the advertised libvirt subnet in the TUN settings:
  #
  #    route-exclude-address:
  #      - 100.64.0.0/10
  #      - fd7a:115c:a1e0::/48
  #      - 192.168.122.0/24
  #
  # 2. Keep the global DNS override disabled. Enabling it replaces the
  #    subscription's DNS configuration and can prevent proxy node hostnames
  #    from resolving.
  #
  # 3. Add the following per-profile extension script. Tailscale marks its
  #    outbound sockets to bypass VPN routes, so it cannot use Mihomo's fake
  #    addresses. The script returns real IP addresses for Tailscale domains
  #    while preserving the subscription's existing DNS configuration.
  #
  #    function main(config, profileName) {
  #      if (!config.dns) {
  #        config.dns = {};
  #      }
  #      if (!Array.isArray(config.dns["fake-ip-filter"])) {
  #        config.dns["fake-ip-filter"] = [];
  #      }
  #      const tailscaleDomains = [
  #        "+.tailscale.com",
  #        "+.tailscale.io",
  #      ];
  #      for (const domain of tailscaleDomains) {
  #        if (!config.dns["fake-ip-filter"].includes(domain)) {
  #          config.dns["fake-ip-filter"].push(domain);
  #        }
  #      }
  #      return config;
  #    }
}
