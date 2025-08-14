{ ... }:

{
  programs.yazi.enable = true;

  home.file = {
    ".config/yazi" = {
      source = ../../configs/.config/yazi;
      recursive = true;
      force = true;
    };
  };
}