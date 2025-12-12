{ pkgs, ... }:

{
  # ---- direnv ----
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # ---- vscode ----
  home.packages = with pkgs; [
    clang
    vscode-fhs
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
