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
    sshKeys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM+N3j3ytRRUXM4+dgLosNhI1KbkWG/2ttOwXodsPADm LinermaoGemail@gmail.com"
    ];
    shell = "fish";
    extraGroups = [
      "video"
      "render"
      "docker"
      "libvirtd"
    ];
  };
}
