{ pkgs, ... }:

{
  home.packages = with pkgs; [
      waybar
      adwaita-icon-theme
      (python3.withPackages (ps: with ps; [ pygobject3 ])) # python with pygobject3
  ];

  home.file = {
    ".config/waybar" = {
      source = ../../configs/.config/waybar;
      recursive = true;
      force = true;
    };
  };
}
