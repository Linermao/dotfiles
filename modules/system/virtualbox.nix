{ pkgs, ... }:

{
  virtualisation.virtualbox.host.enable = true;
  virtualisation.virtualbox.host.enableExtensionPack = true;

  # disable kvm
  boot.blacklistedKernelModules = [ "kvm_intel" "kvm" ];

  boot.kernelModules = [
    "vboxdrv"
    "vboxnetflt"
    "vboxnetadp"
    "vboxpci"
  ];
}
