{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    (pkgs.sddm-astronaut.override {
      embeddedTheme = "pixel_sakura";
    })
  ];

  services.displayManager.sddm = {
    enable = true;
    theme = "sddm-astronaut-theme";

    wayland.enable = false;
    
    package = pkgs.kdePackages.sddm; # use qt6
    extraPackages = with pkgs; [
      kdePackages.qtsvg
      kdePackages.qtvirtualkeyboard
      kdePackages.qtmultimedia
    ];
  };
}
