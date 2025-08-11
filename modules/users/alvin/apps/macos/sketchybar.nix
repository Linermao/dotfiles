{ pkgs, ... }:

{
  home.packages = with pkgs; [
    sketchybar
  ];

  home.file = {
    ".config/sketchybar" = {
      source = ../../configs/.config/sketchybar;
      recursive = true;
      force = true;
    };
  };
}
