{ pkgs, lib, ... }:

{
  imports = [
    ./control-center.nix
    ./dock.nix
    ./finder.nix
    ./input.nix
    ./launchd.nix
    ./loginwindow.nix
    ./menubar.nix
    ./network.nix
    ./screensaver.nix
    ./system.nix
    ./touchpad.nix
    ./users.nix
  ];
}
