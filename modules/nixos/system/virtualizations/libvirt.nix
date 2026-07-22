{
  hostConfig,
  lib,
  pkgs,
  ...
}:

let
  cpu = hostConfig.cpu;
  gpuDevice = hostConfig.modules.system.gpu.device;
  kvmModule =
    if cpu == "amd" then
      "kvm-amd"
    else if cpu == "intel" then
      "kvm-intel"
    else
      throw "Unsupported hostConfig.cpu `${cpu}` for libvirt nested virtualization";
  qemuVulkanLibraryPath = lib.makeLibraryPath [ pkgs.vulkan-loader ];
  preferredVulkanIcd =
    if
      builtins.elem gpuDevice [
        "intel"
        "nvidia-intel"
      ]
    then
      "/run/opengl-driver/share/vulkan/icd.d/intel_icd.x86_64.json"
    else if gpuDevice == "amd" then
      "/run/opengl-driver/share/vulkan/icd.d/radeon_icd.x86_64.json"
    else if gpuDevice == "nvidia" then
      "/run/opengl-driver/share/vulkan/icd.d/nvidia_icd.json"
    else
      null;
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
    vulkan-loader
    vulkan-tools
  ];

  programs.virt-manager.enable = true;

  # virglrenderer's Venus path dlopens libvulkan.so at runtime, so the
  # libvirtd-managed QEMU process needs an explicit loader path and ICD view.
  systemd.services.libvirtd.environment = {
    LD_LIBRARY_PATH = "/run/opengl-driver/lib:${qemuVulkanLibraryPath}";
  }
  // lib.optionalAttrs (preferredVulkanIcd != null) {
    VK_ICD_FILENAMES = preferredVulkanIcd;
  };

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
