{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # ---- steam ----
    steam
    steam-run
    
    # ---- tracy ----
    tracy
    # heaptrack
    # phoronix-test-suite
    # glmark2

    # ---- clash ----
    clash-verge-rev

    # ---- image viewer ----
    loupe 
    nomacs

    # ---- media player ----
    mpv
    feishin
    playerctl
  ];

  # ---- obs studio ----
  programs.obs-studio.enable = true;

  # ---- firefox ----
  programs.firefox.enable = true;
}