{ ... }:

{
  imports = [
    ../../../modules/home-manager/common/git.nix
    ../../../modules/home-manager/common/nvim.nix
    ../../../modules/home-manager/common/shell.nix
    ../../../modules/home-manager/common/yazi.nix
    ../../../modules/home-manager/nixos/coding.nix
    ../../../modules/home-manager/nixos/desktop.nix
    ../../../modules/home-manager/nixos/misc.nix
    ../../../modules/home-manager/nixos/scripts.nix
    ../../../modules/home-manager/nixos/softwares.nix
    ../../../modules/home-manager/nixos/terminal.nix
  ];

  home.file = {
    ".face" = {
      source = ../../../assets/avatars/face.jpg;
    };
  };


  home.file = {
    "Pictures/wallpapers" = {
      source = ../../../assets/wallpapers;
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
