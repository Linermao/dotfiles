{ ... }:

let
  home = "/User/alvin";
in
{
  launchd.user.envVariables = {
    PATH = lib.concatStringsSep ":" [
      "/nix/var/nix/profiles/default/bin"
      "${home}/.nix-profile/bin"
      "/run/current-system/sw/bin"
      "/usr/local/bin"
      "/usr/bin"
      "/bin"
      "/usr/sbin"
      "/sbin"
    ];
  };
}
