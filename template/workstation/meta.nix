{
  repoRoot = "/home/asterinas/dotfiles";
  hostName = "workstation";
  platform = "x86_64-linux";
  cpu = "intel";
  stateVersion = "25.05";
  allowUnfree = true;

  modules = {
    system = {
      display = "niri";
      gpu = {
        devices = [
          "intel"
          "nvidia"
        ];
        mode = "nvidia-intel";
      };
      programs = [
        "steam"
        "clash-verge-rev"
      ];
      servers = [
        "dbus"
        "tailscale"
        "sunshine"
        "openssh"
      ];
      virtualizations = [
        "docker"
        "libvirt"
      ];
    };

    home = {
      ai = [ "codex" ];
      coding = [
        "git"
        "nvim"
        "vscode"
      ];
      fileManager = [ "yazi" ];
      programs = [
        "chrome"
        "quickemu"
        "obs-studio"
        "splayer"
        "motrix"
      ];
      terminal = "kitty";
    };
  };

  user = {
    name = "asterinas";
    homeDirectory = "/home/asterinas";
    isNormalUser = true;
    git = {
      name = "Linermao";
      email = "LinermaoGemail@gmail.com";
    };
    sshKeys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF1jVC4XzXmkqS3NdN6v6kECJ46Yvs0IN5HTmaRgZOAS LinermaoGemail@gmail.com"
    ];
    shell = "fish";
    extraGroups = [
      "video"
      "render"
      "i2c"
      "docker"
      "libvirtd"
    ];
  };
}
