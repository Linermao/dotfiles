{ pkgs, ... }:

{
  home.packages = with pkgs; [
    tracy
    heaptrack
    phoronix-test-suite
    glmark2
  ];
}