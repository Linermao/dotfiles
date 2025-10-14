{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # ---- fonts ----
    nerd-fonts.jetbrains-mono
    nerd-fonts.caskaydia-cove
    nerd-fonts.caskaydia-mono
    nerd-fonts.hack
    nerd-fonts.fira-code
  ];
  
  fonts.fontconfig.enable = true;
}