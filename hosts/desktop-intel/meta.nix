{ ... }:

{
  type = "nixos";
  system = "x86_64-linux";
  hostName = "desktop_intel";

  modules = [
    ./hardware-configuration.nix
    ../../modules/system/nixos/base.nix
    ../../modules/system/nixos/desktop.nix
    ../../modules/system/nixos/nix.nix
    ../../modules/system/nixos/system.nix
    ../../modules/system/nixos/users.nix
    ../../modules/system/nixos/virtualization.nix
    ../../modules/system/nixos/services/sunshine.nix
    ../../modules/system/nixos/services/tailscale.nix
    ../../modules/system/nixos/hardware/intel.nix
  ];
}
