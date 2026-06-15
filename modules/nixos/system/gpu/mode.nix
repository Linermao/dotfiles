{
  hostConfig,
  ...
}:

let
  gpuMode = hostConfig.modules.system.gpu.mode;
  modes = {
    nvidia = {
      environment.sessionVariables = {
        GBM_BACKEND = "nvidia-drm";
        __GLX_VENDOR_LIBRARY_NAME = "nvidia";
        LIBVA_DRIVER_NAME = "nvidia";
      };

      services.xserver.videoDrivers = [ "nvidia" ];
    };

    intel = {
      services.xserver.videoDrivers = [
        "modesetting"
        "intel"
      ];
    };

    nvidia-intel = {
      services.xserver.videoDrivers = [
        "nvidia"
        "modesetting"
      ];

      environment.sessionVariables = {
        GBM_BACKEND = "nvidia-drm";
        __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      };
    };
  };
in
modes.${gpuMode}
