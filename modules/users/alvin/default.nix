{ config, pkgs, inputs, ... }:

{
  imports = [
    ./apps
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

  # fonts
  home.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    source-han-sans
    source-han-serif
  ];

  fonts.fontconfig.enable = true;

  home.stateVersion = "25.05";
}
