{ inputs, primaryMacosUser, ... }:

{
  type = "macos";
  system = "aarch64-darwin";
  hostName = "macbook";

  modules = [
    ../../modules/system/macos/base.nix
    ../../modules/system/macos/desktop.nix
    ../../modules/system/macos/nix.nix
    ../../modules/system/macos/system.nix
    ../../modules/system/macos/users.nix
    ../../modules/system/macos/homebrew.nix
    inputs.nix-homebrew.darwinModules.nix-homebrew
    {
      nix-homebrew = {
        enable = true;
        enableRosetta = true;
        user = primaryMacosUser;
        autoMigrate = true;
      };
    }
  ];
}
