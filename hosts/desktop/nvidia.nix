{ inputs, pkgs, config, ... }:

{
  # ---- nvidia ----
  services.xserver.videoDrivers = [ "nvidia" ];
  
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    nvidiaSettings = true;
    open = false;
    package = config.boot.kernelPackages.nvidiaPackages.latest;
  };

  environment.sessionVariables = {
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    LIBVA_DRIVER_NAME = "nvidia";
  };

  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;
  
  environment.systemPackages = with pkgs; [
    mesa
    vulkan-tools
    libGL
    libglvnd
    libdrm
  ];
}