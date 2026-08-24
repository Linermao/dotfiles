{
  hostConfig,
  lib,
  pkgs,
  ...
}:

let
  cfg = hostConfig.modules.system.gpu.passthrough;
  vmName = cfg.vmName;
  pciIds = cfg.pciIds;
  vfioPciIds = lib.concatStringsSep "," pciIds;
  hasLibvirt = builtins.elem "libvirt" (hostConfig.modules.system.virtualizations or [ ]);
in
{
  assertions = [
    {
      assertion = hasLibvirt;
      message = "The vfio virtualization module requires the libvirt module.";
    }
    {
      assertion = pciIds != [ ];
      message = "hostConfig.modules.system.gpu.passthrough.pciIds must not be empty.";
    }
    {
      assertion = vmName != "";
      message = "hostConfig.modules.system.gpu.passthrough.vmName must not be empty.";
    }
  ];

  # The normal desktop remains the parent configuration. This specialisation
  # keeps the same Linux desktop and user environment, but claims the complete
  # NVIDIA device in the initrd and starts the already-defined libvirt guest.
  specialisation."vfio-win11" = {
    inheritParentConfig = true;

    configuration = {
      system.nixos.tags = [ "vfio-win11" ];

      # The parent is configured for Intel + NVIDIA. In this boot mode Linux
      # keeps the Intel GPU and its complete graphical session, while NVIDIA is
      # reserved for the guest. Disabling NVIDIA modesetting also makes the GPU
      # module omit its NVIDIA-specific session variables in this mode.
      services.xserver.videoDrivers = lib.mkForce [ "modesetting" ];

      hardware.nvidia = {
        modesetting.enable = lib.mkForce false;
        nvidiaSettings = lib.mkForce false;
        open = lib.mkForce false;
      };

      boot = {
        initrd.kernelModules = [
          "vfio"
          "vfio_pci"
          "vfio_iommu_type1"
        ];
        kernelParams = [
          "intel_iommu=on"
          "iommu=pt"
          "vfio-pci.ids=${vfioPciIds}"
        ];
        blacklistedKernelModules = [
          "nouveau"
          "nvidia"
          "nvidia_drm"
          "nvidia_modeset"
          "nvidia_uvm"
        ];
      };

      # Sunshine remains available on the Linux desktop in both boot modes.
      # With NVIDIA assigned to VFIO, force the Intel Quick Sync encoder.
      services.sunshine.settings.encoder = lib.mkForce "quicksync";

      systemd.services."start-${vmName}" = {
        description = "Start the ${vmName} libvirt guest";
        wantedBy = [ "multi-user.target" ];
        requires = [ "libvirtd.service" ];
        after = [ "libvirtd.service" ];

        environment.LIBVIRT_DEFAULT_URI = "qemu:///system";
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };

        script = ''
          state="$(${pkgs.libvirt}/bin/virsh domstate ${lib.escapeShellArg vmName} 2>/dev/null)" || {
            echo "libvirt domain ${lib.escapeShellArg vmName} is not defined" >&2
            exit 1
          }

          if [[ "$state" != "running" ]]; then
            ${pkgs.libvirt}/bin/virsh start ${lib.escapeShellArg vmName}
          fi
        '';
      };
    };
  };
}
