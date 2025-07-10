{ inputs, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # network
    curl
    wget
    nmap
    tcpdump

    # home-manager
    inputs.home-manager.packages.${pkgs.system}.default

    # basic tools
    git
    vim
    nano
    tree
    bottom
  ];
}
