{ inputs, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # home-manager
    inputs.home-manager.packages.${pkgs.stdenv.hostPlatform.system}.default

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
  ];
}
