{ paths, ... }:

{
  time.timeZone = "Asia/Shanghai";

  system = {
    stateVersion = 6;

    defaults = {
      menuExtraClock.Show24Hour = true;  # show 24 hour clock
      # other macOS's defaults configuration.
      # ......
    };
  };

  # use dark modle
  system.defaults.NSGlobalDomain.AppleInterfaceStyle = "Dark";

  # Add ability to used TouchID for sudo authentication
  security.pam.services.sudo_local.touchIdAuth = true;

  # close the startup sound
  system.startup.chime = false;
}
