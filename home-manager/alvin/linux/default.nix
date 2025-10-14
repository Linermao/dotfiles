{ ... }:

{
  imports = [
    ./coding.nix
    ./desktop.nix
    ./misc.nix
    ./scripts.nix
    ./softwares.nix
    ./terminal.nix
  ];

  home.file = {
    "Pictures/wallpapers" = {
      source = ./../Pictures/wallpapers;
      recursive = true;
      force = true;
    };
  };

  home.file = {
    ".face" = {
      source = ./../Pictures/avatars/face.jpg;
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