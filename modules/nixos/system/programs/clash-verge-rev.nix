{ pkgsUnstable, ... }:

{
  programs.clash-verge = {
    enable = true;
    package = pkgsUnstable.clash-verge-rev;
    serviceMode = true;
    autoStart = true;
  };
}
