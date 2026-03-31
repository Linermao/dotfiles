{ inputs, lib, ... }:

let
  hostsDir = ../hosts;
  hostEntries = builtins.readDir hostsDir;

  usersDir = ../users;
  userEntries = builtins.readDir usersDir;

  mkPkgs =
    pkgsSource: system:
    import pkgsSource {
      inherit system;
      config.allowUnfree = true;
    };

  userNames = lib.filter (
    name: userEntries.${name} == "directory" && builtins.pathExists (usersDir + "/${name}/meta.nix")
  ) (builtins.attrNames userEntries);

  readUserMeta = user: import (usersDir + "/${user}/meta.nix");
  userMetas = lib.genAttrs userNames readUserMeta;

  primaryMacosUserForHost =
    host:
    let
      primaryUsers = lib.filter (
        user:
        let
          meta = userMetas.${user};
        in
        builtins.elem host (meta.primaryMacosHosts or [ ])
      ) userNames;
    in
    if primaryUsers == [ ] then
      throw "No primary macOS user defined for host '${host}'"
    else
      builtins.head primaryUsers;

  hostNames = lib.filter (
    name: hostEntries.${name} == "directory" && builtins.pathExists (hostsDir + "/${name}/meta.nix")
  ) (builtins.attrNames hostEntries);

  readHostMeta =
    host:
    import (hostsDir + "/${host}/meta.nix") {
      inherit inputs;
      primaryMacosUser = primaryMacosUserForHost host;
    };

  hostMetas = lib.genAttrs hostNames readHostMeta;

  nixosHostNames = lib.filter (host: hostMetas.${host}.type == "nixos") hostNames;
  macosHostNames = lib.filter (host: hostMetas.${host}.type == "macos") hostNames;

  pkgsBySystem = {
    x86_64-linux = mkPkgs inputs.nixpkgs "x86_64-linux";
    aarch64-darwin = mkPkgs inputs.nixpkgs "aarch64-darwin";
  };

  mkSpecialArgs =
    {
      host,
      hostName ? host,
      system,
    }:
    {
      inherit
        inputs
        host
        hostName
        system
        ;
      paths = {
        root = toString ../.;
      };
      pkgsUnstable = mkPkgs inputs.nixpkgs-unstable system;
    };

  homeModulePath = user: platform: usersDir + "/${user}/home/${platform}.nix";

  hasHomeModule = user: platform: builtins.pathExists (homeModulePath user platform);
in
{
  _module.args.dotfiles = {
    inherit
      macosHostNames
      hasHomeModule
      homeModulePath
      hostMetas
      hostNames
      mkPkgs
      mkSpecialArgs
      nixosHostNames
      pkgsBySystem
      primaryMacosUserForHost
      readHostMeta
      readUserMeta
      userMetas
      userNames
      ;
  };
}
