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

    nixfmt
  ];
}
