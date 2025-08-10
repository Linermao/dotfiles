{ ... }:
{
  imports = [
    ./../../modules/system/common
    ./../../modules/system/macos

    # homebrew
    ./../../modules/users/alvin/apps/macos/homebrew.nix
  ];
}