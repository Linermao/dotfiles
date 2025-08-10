{ pkgs, lib, ... }:

{
  imports = [
    ./control-center.nix
    ./dock.nix
    ./finder.nix
    ./input.nix
    ./network.nix
    ./system.nix
    ./users.nix
  ];
}
