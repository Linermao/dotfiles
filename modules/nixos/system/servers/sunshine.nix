{ hostConfig, ... }:

{
  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = true; # only needed for Wayland -- omit this when using with X11
    openFirewall = true;
    settings = {
      # KMS filters capture candidates by the encoder's GPU type. With NVENC
      # auto-detected, this keeps Intel-connected outputs out of the list while
      # still following whichever HDMI/DP output is active on the NVIDIA GPU.
      capture = "kms";
      sunshine_name = hostConfig.hostName;
    };
  };
}
