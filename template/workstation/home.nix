{ hostConfig, root, lib, pkgs, ... }:

let
  resolved = import (root + "/modules/nixos/home/resolve.nix") {
    inherit hostConfig root lib;
  };
in

{
  imports = resolved.imports;
  fonts.fontconfig.enable = true;

  gtk = {
    enable = true;
    colorScheme = "dark";
  };

  qt = {
    enable = true;
    platformTheme.name = "adwaita";
    style.name = "adwaita-dark";
  };

  home.packages = with pkgs; [
    # ---- tui ----
    fastfetch
    cmatrix
    cava
    bottom
    gitui
    clock-rs
    
    # ---- media ----
    mpv
    loupe

    # ---- hardware tools ----
    lm_sensors
    pulseaudio
    bluez

    # ---- controller ----
    ddcutil
    brightnessctl
    playerctl

    # ---- misc tools ----
    jq
    gh
    ripgrep

    # ---- fonts ----
    fontpreview
    nerd-fonts.jetbrains-mono
    nerd-fonts.caskaydia-cove
    nerd-fonts.caskaydia-mono
    nerd-fonts.hack
    nerd-fonts.fira-code
  ];

  home.username = hostConfig.user.name;
  home.homeDirectory = hostConfig.user.homeDirectory;
  home.stateVersion = hostConfig.stateVersion;
}
