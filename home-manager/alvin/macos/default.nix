{ ... }:

{
  imports = [
    ./coding.nix
    ./misc.nix
    ./softwares.nix
    ./terminal.nix
  ];
 
  home.file = {
    "Picture/wallpapers" = {
      source = ./../wallpapers;
      recursive = true;
      force = true;
    };
  };

  home.username = "alvin";
  home.homeDirectory = "/Users/alvin";

  programs.home-manager.enable = true;

  home.sessionVariables = {
    http_proxy = "http://127.0.0.1:7890";
    https_proxy = "http://127.0.0.1:7890";
  };

  home.stateVersion = "25.05";
}