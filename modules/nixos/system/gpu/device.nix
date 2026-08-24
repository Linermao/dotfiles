{
  config,
  hostConfig,
  lib,
  pkgs,
  ...
}:

let
  gpu = hostConfig.modules.system.gpu;
  gpuDevice = gpu.device;
  cudaSupport = gpu.cuda or false;
  devices = {
    nvidia = {
      nixpkgs.config.cudaSupport = cudaSupport;

      hardware.nvidia = {
        modesetting.enable = true;
        nvidiaSettings = true;
        open = true;
      };

      hardware.graphics = {
        enable = true;
        enable32Bit = true;
      };

      environment.sessionVariables = lib.mkIf config.hardware.nvidia.modesetting.enable {
        GBM_BACKEND = "nvidia-drm";
        __GLX_VENDOR_LIBRARY_NAME = "nvidia";
        LIBVA_DRIVER_NAME = "nvidia";
      };

      services.xserver.videoDrivers = [ "nvidia" ];
    };

    intel = {
      hardware.graphics = {
        enable = true;
        enable32Bit = true;
        extraPackages = with pkgs; [
          intel-media-driver
          vpl-gpu-rt
        ];
        extraPackages32 = with pkgs.pkgsi686Linux; [
          intel-media-driver
        ];
      };

      services.xserver.videoDrivers = [
        "modesetting"
        "intel"
      ];
    };

    nvidia-intel = {
      nixpkgs.config.cudaSupport = cudaSupport;

      hardware.nvidia = {
        modesetting.enable = true;
        nvidiaSettings = true;
        open = true;
      };

      hardware.graphics = {
        enable = true;
        enable32Bit = true;
        extraPackages = with pkgs; [
          intel-media-driver
          vpl-gpu-rt
        ];
        extraPackages32 = with pkgs.pkgsi686Linux; [
          intel-media-driver
        ];
      };

      environment.sessionVariables = lib.mkIf config.hardware.nvidia.modesetting.enable {
        GBM_BACKEND = "nvidia-drm";
        __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      };

      services.xserver.videoDrivers = [
        "nvidia"
        "modesetting"
      ];
    };
  };
in
devices.${gpuDevice}
