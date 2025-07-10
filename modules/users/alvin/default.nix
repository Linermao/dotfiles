{ config, pkgs, inputs, ... }:

{
  imports = [
    ./apps
  ];

  home.file = {
    "nixos/resources" = {
      source = ./resources;
      recursive = true;
      force = true;
    };
  };

  home.username = "alvin";
  home.homeDirectory = "/home/alvin";
  
  programs.home-manager.enable = true;

  home.stateVersion = "25.05";
}