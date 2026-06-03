{
  repoRoot = "/home/alvin/Investigation/dotfiles";
  hostName = "desktop";
  platform = "x86_64-linux";
  cpu = "intel";
  stateVersion = "25.05";
  allowUnfree = true;

  proxy = {
    http = "http://127.0.0.1:7890";
    https = "http://127.0.0.1:7890";
    noProxy = "127.0.0.1,localhost";
  };

  modules = {
    system = {
      display = "niri";
      gpu = "nvidia";
      programs = [ "steam" ];
      servers = [ "dbus" "tailscale" "sunshine" "openssh"];
      virtualizations = [ "docker" "libvirt" ];
    };

    home = {
      ai = [ "codex" ];
      coding = [ "git" "nvim" "vscode" ];
      fileManager = [ "yazi" ];
      programs = [ "clash-verge-rev" "chrome" "quickemu" "obs-studio" "splayer" "motrix"];
      terminal = "kitty";
    };
  };

  user = {
    name = "alvin";
    homeDirectory = "/home/alvin";
    isNormalUser = true;
    sshKeys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM+N3j3ytRRUXM4+dgLosNhI1KbkWG/2ttOwXodsPADm LinermaoGemail@gmail.com"
    ];
    shell = "fish";
    extraGroups = [
      "docker"
      "libvirtd"
    ];
  };
}
