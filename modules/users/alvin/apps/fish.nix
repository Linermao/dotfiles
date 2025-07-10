{ configsPath, ... }:

{
  programs.fish.enable = true;

  home.file = {
    ".config/fish" = {
      source = ../configs/.config/fish;
      recursive = true;
      force = true;
    };
  };
}