{ pkgsUnstable, ... }:

{
  home.packages = with pkgsUnstable; [
    codex
  ];
}
