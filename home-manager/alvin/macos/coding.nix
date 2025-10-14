{ pkgs, ... }:

{
  home.packages = with pkgs; [
    vscode
  ];

  # ---- nvim ----
  programs.neovim = {
    enable = true;
    extraPackages = with pkgs; [
      rust-analyzer
    ];
  };
  home.file = {
    ".config/nvim" = {
      source = ./../configs/.config/nvim;
      recursive = true;
      force = true;
    };
  };
}
