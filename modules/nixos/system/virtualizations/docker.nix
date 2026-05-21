{
  hostConfig,
  lib,
  ...
}:

let
  proxy = hostConfig.proxy or { };
  dockerProxyEnv = lib.filterAttrs (_: value: value != null && value != "") {
    HTTP_PROXY = proxy.http or null;
    HTTPS_PROXY = proxy.https or null;
    NO_PROXY = proxy.noProxy or null;
  };
in
{
  virtualisation.docker = {
    enable = true;
    autoPrune.enable = true;
    daemon.settings = {
      "registry-mirror" = [
        "https://docker.xuanyuan.me"
      ];
    };
  };

  hardware.nvidia-container-toolkit.enable = (hostConfig.modules.system.gpu or null) == "nvidia";

  systemd.services.docker.environment = dockerProxyEnv;
}
