{ ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./../../modules/system/common
    ./../../modules/system/linux
  ];

  powerManagement.cpuFreqGovernor = "performance";
}