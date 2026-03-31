{ ... }:

{
  imports = [
    ../../../modules/home-manager/common/git.nix
    ../../../modules/home-manager/common/nvim.nix
    ../../../modules/home-manager/common/shell.nix
    ../../../modules/home-manager/common/yazi.nix
    ../../../modules/home-manager/macos/coding.nix
    ../../../modules/home-manager/macos/misc.nix
    ../../../modules/home-manager/macos/softwares.nix
    ../../../modules/home-manager/macos/terminal.nix
    ../../../modules/home-manager/macos/virtual.nix
  ];

  home.username = "alvin";
  home.homeDirectory = "/Users/alvin";

  programs.home-manager.enable = true;

  home.sessionVariables = {
    http_proxy = "http://127.0.0.1:7890";
    https_proxy = "http://127.0.0.1:7890";
  };

  home.stateVersion = "25.05";
}
