{ pkgs, ... }:

{
  virtualisation.docker = {
    enable = true;
    storageDriver = "btrfs";
    daemon.settings = {
      "registry-mirror" = [
        "https://docker.xuanyuan.me"
      ];
    };
  };
}
