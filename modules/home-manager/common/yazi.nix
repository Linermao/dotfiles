{ ... }:

{
  # ---- yazi ----
  programs.yazi.enable = true;

  home.file = {
    ".config/yazi" = {
      source = ../../../assets/config/.config/yazi;
      recursive = true;
      force = true;
    };
  };
}
