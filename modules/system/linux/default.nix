{ paths, ... }:

{
  imports = [
    ./boot.nix
    ./docker.nix
    ./hyprland.nix
    ./input.nix
    ./network.nix
    ./nvidia.nix
    ./sddm.nix
    ./services.nix
    ./sound.nix
    ./sunshine.nix
    ./system.nix
    ./tailscale.nix
    ./users.nix
    ./virtual.nix
  ];

  environment.sessionVariables = {
    NIX_ROOT = "${paths.root}";
  };
}
