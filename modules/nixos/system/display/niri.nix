{
  inputs,
  hostConfig,
  lib,
  pkgs,
  root,
  ...
}:

let
  gpuDevice = hostConfig.modules.system.gpu.device;
  hasNvidia = builtins.elem gpuDevice [
    "nvidia"
    "nvidia-intel"
  ];
in
{
  imports = [
    inputs.dms.nixosModules.greeter
  ];

  programs.niri.enable = true;
  programs.dank-material-shell.greeter = {
    enable = true;
    compositor.name = "niri";
  };

  environment.systemPackages = with pkgs; [
    xwayland-satellite
  ];

  security.polkit.enable = true;
  security.pam.services.swaylock = { };

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
  };

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };

  environment.etc = lib.mkIf hasNvidia {
    "nvidia/nvidia-application-profiles-rc.d/50-limit-free-buffer-pool-in-wayland-compositors.json".text =
      builtins.toJSON {
        rules = [
          {
            pattern = {
              feature = "procname";
              matches = "niri";
            };
            profile = "Limit Free Buffer Pool On Wayland Compositors";
          }
        ];
        profiles = [
          {
            name = "Limit Free Buffer Pool On Wayland Compositors";
            settings = [
              {
                key = "GLVidHeapReuseRatio";
                value = 0;
              }
            ];
          }
        ];
      };
  };
}
