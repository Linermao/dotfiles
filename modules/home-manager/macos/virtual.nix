{ pkgs, ... }:

{
    home.packages = with pkgs; [
        docker
        lima
        colima # Container runtimes with minimal setup
    ];
}
