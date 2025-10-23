{ host, lib, ... }:

let
  home = "/User/alvin";
in
{
  # ---- finder ----
  system.defaults.finder.AppleShowAllFiles = true;
  system.defaults.finder.AppleShowAllExtensions = true;
  system.defaults.finder.ShowStatusBar = true;
  system.defaults.finder.ShowPathbar = true;

  # ---- docker ----
  system.defaults.dock.orientation = "left";
  system.defaults.dock.autohide = true;
  system.defaults.dock.magnification = true;
  system.defaults.dock.largesize = 16;
  system.defaults.dock.tilesize = 36;
  system.defaults.dock.mru-spaces = false; # auto rearrange spaces based on usage
  system.defaults.dock.persistent-apps = [];

  ## ---- manubar ----
  # system.defaults.NSGlobalDomain._HIHideMenuBar = true;

  # ---- screen saver ----
  system.defaults.screensaver.askForPassword = true;
  system.defaults.screensaver.askForPasswordDelay = 300;

  # ---- login window ----
  system.defaults.loginwindow.LoginwindowText = "⚠️WARNING⚠️ 💥再看一眼就要爆炸💥 ⚠️WARNING⚠️";
  system.defaults.loginwindow.PowerOffDisabledWhileLoggedIn = true;

  # ---- control center ----
  system.defaults.controlcenter.BatteryShowPercentage = true;
  system.defaults.controlcenter.NowPlaying = true;

  # ---- launchd ----
  launchd.user.envVariables = {
    PATH = lib.concatStringsSep ":" [
      "/nix/var/nix/profiles/default/bin"
      "${home}/.nix-profile/bin"
      "/run/current-system/sw/bin"
      "/usr/local/bin"
      "/usr/bin"
      "/bin"
      "/usr/sbin"
      "/sbin"
    ];
  };

  # ---- network ----
  networking.hostName = "${host}";

  # ---- time zone ----
  time.timeZone = "Asia/Shanghai";

  # ---- system ----
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
