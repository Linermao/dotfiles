{ pkgs, ... }:

let
  screen-copy = pkgs.writeShellScriptBin "screen-copy" (builtins.readFile ../../scripts/screen_copy.sh);
in
{
  home.packages = with pkgs; [
    grim
    slurp
    screen-copy
  ];
}
