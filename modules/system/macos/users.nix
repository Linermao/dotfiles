{ lib, pkgs, host, paths, ... }:

let
  root = builtins.toPath paths.root;
  usersDir = root + "/users";
  userEntries = builtins.readDir usersDir;
  userNames = lib.filter (
    name:
    userEntries.${name} == "directory"
    && builtins.pathExists (usersDir + "/${name}/meta.nix")
    && builtins.pathExists (usersDir + "/${name}/system/macos.nix")
  ) (builtins.attrNames userEntries);
  enabledUsers = lib.filter (
    name:
    let
      meta = import (usersDir + "/${name}/meta.nix");
    in
    builtins.elem host (meta.macosHosts or [ ])
  ) userNames;
  primaryUsers = lib.filter (
    name:
    let
      meta = import (usersDir + "/${name}/meta.nix");
    in
    builtins.elem host (meta.primaryMacosHosts or [ ])
  ) enabledUsers;
in
{
  imports = map (name: usersDir + "/${name}/system/macos.nix") enabledUsers;

  system.primaryUser = lib.mkIf (primaryUsers != [ ]) (builtins.head primaryUsers);
  environment.shells = [ pkgs.fish ];
  programs.fish.enable = true;
}
