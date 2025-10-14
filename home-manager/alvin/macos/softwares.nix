{ pkgs, ... }:

{
  home.packages = with pkgs; [
    qq
    raycast
  ];

  # ---- firefox ----
  programs.firefox.enable = true;
}
