{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # ---- TUI interesting ----
    cowsay
    fortune-kind
    fastfetch
    cmatrix
    pipes
    cbonsai
    cava
    
    # ---- hardware tools ----
    lm_sensors
    pulseaudio
    bluez

    # ---- fonts ----
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    source-han-sans
    source-han-serif
    nerd-fonts.jetbrains-mono
    nerd-fonts.caskaydia-cove
    nerd-fonts.caskaydia-mono
    nerd-fonts.hack
    nerd-fonts.fira-code

    # ---- recorder ----
    gpu-screen-recorder

    # ---- brightness controller ----
    ddcutil
    brightnessctl
  ];

  # ---- icon theme ----
  gtk = {
    enable = true;
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
  };

  qt = {
    enable = true;
    style.name = "adwaita-dark";
    platformTheme.name = "gtk3";
  };

  fonts.fontconfig.enable = true;
}