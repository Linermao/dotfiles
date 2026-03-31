{ pkgs, config, ... }:

{
  # ---- intel ----
  services.xserver.videoDrivers = [ "modesetting" "intel" ];

  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;

  environment.systemPackages = with pkgs; [
    mesa
    vulkan-tools
    libGL
    libglvnd
    libdrm
    intel-media-driver
    libva-utils
  ];
}
