{ ... }:

{
  # ---- touchpad ----
  # swiping left or right with two fingers to navigate backward or forward
  system.defaults.NSGlobalDomain.AppleEnableMouseSwipeNavigateWithScrolls = false;
  system.defaults.NSGlobalDomain.AppleEnableSwipeNavigateWithScrolls = false;
  # allow tap to click
  system.defaults.trackpad.Clicking = true;

  # ---- keyboard ----
  system.defaults.NSGlobalDomain.KeyRepeat = 2;
  system.defaults.NSGlobalDomain.InitialKeyRepeat = 15;
}
