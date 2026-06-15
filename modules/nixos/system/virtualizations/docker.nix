{
  hostConfig,
  lib,
  ...
}:

let
  gpuDevices = hostConfig.modules.system.gpu.devices or [ ];
in
{
  virtualisation.docker = {
    enable = true;
    autoPrune.enable = true;
    daemon.settings = {
      "registry-mirror" = [
        "https://docker.xuanyuan.me"
      ];
    };
  };

  hardware.nvidia-container-toolkit.enable = lib.elem "nvidia" gpuDevices;
}
