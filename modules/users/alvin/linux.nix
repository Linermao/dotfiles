{ config, inputs, ... }:

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

  home.stateVersion = "25.05";
}
