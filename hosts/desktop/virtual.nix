{ pkgs, ... }:

{
  # ---- docker ----
  virtualisation.docker = {
    enable = true;
    storageDriver = "btrfs";
    daemon.settings = {
      "registry-mirror" = [
        "https://docker.xuanyuan.me"
      ];
    };
  };

  systemd.services.docker.environment = {
    HTTP_PROXY = "http://127.0.0.1:7890";
    HTTPS_PROXY = "http://127.0.0.1:7890";
    NO_PROXY = "127.0.0.1,localhost";
  };

  ## ---- virtual box ----
  # ----------------------------------
  # virtualisation.virtualbox.host.enable = true;
  # virtualisation.virtualbox.host.enableExtensionPack = true;

  # # disable kvm
  # boot.blacklistedKernelModules = [ "kvm-intel" "kvm" ];

  # boot.kernelModules = [
  #   "vboxdrv"
  #   "vboxnetflt"
  #   "vboxnetadp"
  #   "vboxpci"
  # ];

  # ---- QEMU/KVM ----
  virtualisation.libvirtd.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;
  virtualisation.libvirtd.extraConfig = "uri_default = \"qemu:///system\"";

  environment.systemPackages = with pkgs ;[
    qemu_kvm
    virt-manager
    libvirt
    OVMF
  ];

  # enable nested virtualization (option)
  boot.kernelModules = [ "kvm" "kvm-intel" ];  # Intel CPU
  # boot.kernelModules = [ "kvm" "kvm-amd" ];   # AMD CPU
  boot.extraModprobeConfig = "options kvm-intel nested=1";  # Intel
  # boot.extraModprobeConfig = "options kvm-amd nested=1";   # AMD
}
