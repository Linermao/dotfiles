{ hostConfig, ... }:

{
  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = true; # only needed for Wayland -- omit this when using with X11
    openFirewall = true;
    settings = {
      sunshine_name = hostConfig.hostName;
    };
  };
}
