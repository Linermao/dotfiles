{ inputs, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix

    ./desktop.nix
    ./nix.nix
    ./nvidia.nix
    ./operations.nix
    ./system.nix
    ./uses.nix
    ./virtual.nix
  ];

  environment.systemPackages = with pkgs; [
    # home-manager
    inputs.home-manager.packages.${pkgs.system}.default

    # network
    curl
    wget
    nmap
    tcpdump

    # basic tools
    git
    vim
    nano
    tree
    bottom
    neofetch
    unzip
  ];
}