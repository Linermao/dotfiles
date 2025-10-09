{ pkgs, ... }:

{
  imports = [
    ./hyprland
    ./clash.nix
    ./code.nix
    ./compiler.nix
    ./fonts.nix
    ./kitty.nix
    ./obs-studio.nix
    ./screencopy.nix
    ./steam.nix
    ./tracy.nix
    ./viewer.nix
  ];

  
  home.packages = with pkgs; [
    # TUI interesting
    cowsay
    fortune-kind
    fastfetch
    cmatrix
    pipes
    cbonsai
    cava
    
    # hardware tools
    lm_sensors
    pulseaudio
    bluez
  ];
}