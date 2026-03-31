{ pkgs, ... }:

{
  # ---- nvim ----
  programs.neovim = {
    enable = true;
    extraPackages = with pkgs; [
      rust-analyzer
    ];
  };

  home.file = {
    ".config/nvim" = {
      source = ../../../assets/config/.config/nvim;
      recursive = true;
      force = true;
    };
  };
}
