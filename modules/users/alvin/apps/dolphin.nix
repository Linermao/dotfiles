{ pkgs, ... }:

{
  home.packages = with pkgs.kdePackages; [
    # base
    dolphin
    kio
    kio-extras

    # Wayland support
    kwayland
    kde-cli-tools
    
    # extend
    ffmpegthumbs
    kdegraphics-thumbnailers
    qtimageformats
    kimageformats
    qtsvg
  ];

}
