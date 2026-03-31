{ inputs, pkgs, ... }:
{
  # ---- base softwares ----
  environment.systemPackages = with pkgs; [
    # home-manager
    inputs.home-manager.packages.${pkgs.stdenv.hostPlatform.system}.default

    # network
    curl
    wget
    nmap
    tcpdump

    # basic tools
    git
    tig
    vim
    nano
    tree
    bottom
    neofetch
    unzip
  ];

  # ---- input ----
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.inputMethod = {
    type = "fcitx5";
    enable = true;
    fcitx5.addons = with pkgs; [
      fcitx5-gtk
      qt6Packages.fcitx5-chinese-addons
      fcitx5-nord
      fcitx5-rime
    ];
  };

  # ---- sound ----
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  # ---- recorder ----
  programs.gpu-screen-recorder.enable = true;
}
