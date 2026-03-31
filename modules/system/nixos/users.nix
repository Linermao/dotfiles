{ lib, host, paths, ... }:

let
  root = builtins.toPath paths.root;
  usersDir = root + "/users";
  userEntries = builtins.readDir usersDir;
  userNames = lib.filter (
    name:
    userEntries.${name} == "directory"
    && builtins.pathExists (usersDir + "/${name}/meta.nix")
    && builtins.pathExists (usersDir + "/${name}/system/nixos.nix")
  ) (builtins.attrNames userEntries);
  enabledUsers = lib.filter (
    name:
    let
      meta = import (usersDir + "/${name}/meta.nix");
    in
    builtins.elem host (meta.nixosHosts or [ ])
  ) userNames;
in
{
  imports = map (name: usersDir + "/${name}/system/nixos.nix") enabledUsers;

  users.groups.i2c = { };
  users.groups.nix = { };
  programs.fish.enable = true;
}
