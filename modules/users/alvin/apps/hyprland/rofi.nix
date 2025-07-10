{ pkgs, ... }:

let
  rofi-launch = pkgs.writeShellScriptBin "rofi-launch" (builtins.readFile ../../scripts/rofi_launch.sh);
in
{
  home.packages = with pkgs; [ 
    rofi-wayland
    rofi-launch
  ];

  home.file = {
    ".config/rofi" = {
      source = ../../configs/.config/rofi;
      recursive = true;
      force = true;
    };
  };
}
