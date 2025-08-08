{ pkgs, ... }:

{
  imports = [
    ./hyprland

    ./dolphin.nix
    ./firefox.nix
    ./fish.nix
    ./git.nix
    ./kitty.nix
    ./clash.nix
    ./nvim.nix
    ./compiler.nix
    ./code.nix
    ./steam.nix
    ./screencopy.nix
    ./obs-studio.nix
    ./yazi.nix
    ./tracy.nix
  ];

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
}
