{ pkgsUnstable, ... }:

{
  home.packages = with pkgsUnstable; [
    clash-verge-rev
  ];
}