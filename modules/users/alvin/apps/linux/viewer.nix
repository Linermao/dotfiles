{ pkgs, ... }:

{
  home.packages = with pkgs; [
    loupe # simple image viewer
    mpv # media player

    nomacs # image viewer
  ];
}
