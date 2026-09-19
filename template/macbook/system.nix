{ hostConfig, ... }:

{
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    substituters = [
      "https://mirrors.ustc.edu.cn/nix-channels/store"
      "https://cache.nixos.org/"
    ];
  };

  system.primaryUser = hostConfig.user.name;
  system.stateVersion = hostConfig.stateVersion;

  networking.hostName = hostConfig.hostName;
  time.timeZone = "Asia/Shanghai";

  system.defaults = {
    NSGlobalDomain = {
      AppleEnableMouseSwipeNavigateWithScrolls = false;
      AppleEnableSwipeNavigateWithScrolls = false;
      AppleInterfaceStyle = "Dark";
      InitialKeyRepeat = 15;
      KeyRepeat = 2;
    };

    trackpad.Clicking = true;

    finder = {
      AppleShowAllFiles = true;
      AppleShowAllExtensions = true;
      ShowStatusBar = true;
      ShowPathbar = true;
    };

    dock = {
      orientation = "left";
      autohide = true;
      magnification = true;
      largesize = 16;
      tilesize = 36;
      mru-spaces = false;
      persistent-apps = [ ];
    };

    screensaver = {
      askForPassword = true;
      askForPasswordDelay = 300;
    };

    loginwindow = {
      LoginwindowText = "⚠️WARNING⚠️ 💥再看一眼就要爆炸💥 ⚠️WARNING⚠️";
      PowerOffDisabledWhileLoggedIn = true;
    };

    controlcenter = {
      BatteryShowPercentage = true;
      NowPlaying = true;
    };

    menuExtraClock.Show24Hour = true;
  };

  security.pam.services.sudo_local.touchIdAuth = true;
  system.startup.chime = false;
}
