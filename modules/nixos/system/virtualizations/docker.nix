{
  hostConfig,
  lib,
  ...
}:

{
  virtualisation.docker = {
    enable = true;
    autoPrune.enable = false;
    daemon.settings = {
      "registry-mirror" = [
        "https://docker.xuanyuan.me"
      ];
    };
  };
}
