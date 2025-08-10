{ config, pkgs, inputs, ... }:

{
  imports = [
    ./apps/common
    ./apps/linux
  ];

  home.file = {
    ".config/nixos/resources" = {
      source = ./resources;
      recursive = true;
      force = true;
    };
  };

  home.username = "alvin";
  home.homeDirectory = "/home/alvin";

  programs.home-manager.enable = true;

  home.sessionVariables = {
    http_proxy = "http://127.0.0.1:7890";
    https_proxy = "http://127.0.0.1:7890";
  };

  # something interesting
  home.packages = with pkgs; [
    cowsay
    fortune-kind
    fastfetch
    cmatrix
    pipes
    cbonsai
    cava
  ];

  home.stateVersion = "25.05";
}
