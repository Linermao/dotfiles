{
  hostConfig,
  root,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  resolved = import (root + "/modules/nixos/system/resolve.nix") {
    inherit hostConfig root lib;
  };

  user = hostConfig.user;
in
{
  imports = [ ./hardware-configuration.nix ] ++ resolved.imports;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  time.timeZone = "Asia/Shanghai";
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

  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  hardware.bluetooth.enable = true;
  services.upower.enable = true;
  powerManagement.cpuFreqGovernor = "performance";

  networking.hostName = hostConfig.hostName;
  networking.networkmanager.enable = true;
  networking.nameservers = [
    "223.5.5.5"
    "8.8.8.8"
  ];
  
  networking.proxy = {
    default = hostConfig.proxy.http;
    noProxy = hostConfig.proxy.noProxy;
  };

  systemd.services.nix-daemon.environment = {
    http_proxy = hostConfig.proxy.http;
    https_proxy = hostConfig.proxy.https;
    all_proxy = hostConfig.proxy.http;
    no_proxy = hostConfig.proxy.noProxy;
  };

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nix.settings.substituters = [
    "https://mirror.sjtu.edu.cn/nix-channels/store"
    "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
  ];
  nix.settings.trusted-users = [
    "root"
    "@nix"
  ];

  nixpkgs.config.allowUnfree = hostConfig.allowUnfree;

  users.users.${user.name} = {
    isNormalUser = user.isNormalUser;
    description = user.name;
    extraGroups = [
      "networkmanager"
      "wheel"
    ]
    ++ (user.extraGroups or [ ]);
    openssh.authorizedKeys.keys = user.sshKeys or [ ];
    shell = pkgs.${user.shell};
  };

  programs.${user.shell}.enable = true;

  environment.systemPackages = with pkgs; [
    inputs.home-manager.packages.${pkgs.stdenv.hostPlatform.system}.default

    curl
    wget
    nmap
    tcpdump
    git
    vim
    nano
    tree
    unzip
    pciutils
    usbutils
    dnsutils
  ];

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    source-han-sans
    source-han-serif
  ];

  system.stateVersion = hostConfig.stateVersion;
}
