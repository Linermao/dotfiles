{ pkgs, ... }:

let
  screen-copy = pkgs.writeShellScriptBin "screen-copy" (builtins.readFile ../../../assets/scripts/screen_copy.sh);
in
{
  home.packages = with pkgs; [
    # ---- screen copy ----
    grim
    slurp
    screen-copy
  ];
}
