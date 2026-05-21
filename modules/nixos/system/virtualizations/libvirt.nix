{
  hostConfig,
  pkgs,
  ...
}:

let
  cpu = hostConfig.cpu;
  kvmModule =
    if cpu == "amd" then
      "kvm-amd"
    else if cpu == "intel" then
      "kvm-intel"
    else
      throw "Unsupported hostConfig.cpu `${cpu}` for libvirt nested virtualization";
in
{
  virtualisation.spiceUSBRedirection.enable = true;
  virtualisation.libvirtd = {
    enable = true;
    extraConfig = "uri_default = \"qemu:///system\"";
    qemu = {
      package = pkgs.qemu;
      swtpm.enable = true;
      vhostUserPackages = [ pkgs.virtiofsd ];
    };
  };

  environment.systemPackages = with pkgs; [
    libvirt
    qemu
    virt-viewer
    virglrenderer
  ];

  programs.virt-manager.enable = true;

  # Make UEFI firmware visible to virt-manager and prepare the host for
  # virgl/virtio-gpu-gl based guests and local display access.
  systemd.tmpfiles.rules = [
    "L+ /var/lib/qemu/firmware - - - - ${pkgs.qemu}/share/qemu/firmware"
  ];

  boot.kernelModules = [
    "kvm"
    kvmModule
  ];

  boot.extraModprobeConfig = ''
    options ${kvmModule} nested=1
  '';
}
