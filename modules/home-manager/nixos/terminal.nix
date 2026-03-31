{ ... }:

{
  # ---- kitty ----
  programs.kitty = {
    enable = true;
    themeFile = "tokyo_night_night";
    font.name = "FiraCode Nerd Font";
    settings = {
      enable_audio_bell = "no";
      cursor_shape = "beam";
    };
  };
  home.file = {
    ".config/kitty" = {
      source = ../../../assets/config/.config/kitty/linux;
      recursive = true;
      force = true;
    };
  };

  # ---- fish shell ----
  home.file = {
    ".config/fish" = {
      source = ../../../assets/config/.config/fish/linux;
      recursive = true;
      force = true;
    };
  };
}
