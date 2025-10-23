{ inputs, pkgs, ... }:
{
  imports = [
    ./desktop.nix
    ./nix.nix
    ./operations.nix
    ./system.nix
    ./users.nix

    # homebrew
    ./../../home-manager/alvin/macos/homebrew.nix
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
  ];
}