{ ... }:

{
  # ---- git ----
  programs.git = {
    enable = true;
    userName = "Linermao";
    userEmail = "LinermaoGemail@gmail.com";
  };

  # ---- yazi ----
  programs.yazi.enable = true;
  home.file = {
    ".config/yazi" = {
      source = ./../configs/.config/yazi;
      recursive = true;
      force = true;
    };
  };

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
      source = ./../configs/.config/kitty/linux;
      recursive = true;
      force = true;
    };
  };

  # ---- fish shell ----
  programs.fish.enable = true;
  home.file = {
    ".config/fish" = {
      source = ./../configs/.config/fish;
      recursive = true;
      force = true;
    };
  };
}