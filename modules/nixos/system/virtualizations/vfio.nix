{
  hostConfig,
  lib,
  pkgs,
  ...
}:

let
  cfg = hostConfig.virtualisation.gpuPassthrough;
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
      message = "hostConfig.virtualisation.gpuPassthrough.pciIds must not be empty.";
    }
    {
      assertion = vmName != "";
      message = "hostConfig.virtualisation.gpuPassthrough.vmName must not be empty.";
    }
  ];

  # The normal desktop remains the parent configuration. This specialisation
  # claims the complete NVIDIA device in the initrd, boots without a graphical
  # target, and starts the already-defined libvirt guest.
  specialisation."vfio-win11" = {
    inheritParentConfig = true;

    configuration = {
      system.nixos.tags = [ "vfio-win11" ];
      systemd.defaultUnit = "multi-user.target";

      programs.niri.enable = lib.mkForce false;
      programs.dank-material-shell.greeter.enable = lib.mkForce false;
      services.xserver.videoDrivers = lib.mkForce [ ];
      xdg.portal.enable = lib.mkForce false;

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
