{
  inputs,
  lib,
  dotfiles,
  ...
}:

let
  inherit (dotfiles)
    hasHomeModule
    homeModulePath
    hostMetas
    mkSpecialArgs
    pkgsBySystem
    userMetas
    userNames
    ;

  mkHomeConfig =
    { user, host }:
    let
      hostMeta = hostMetas.${host};
      pkgs = pkgsBySystem.${hostMeta.system};
    in
    inputs.home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      extraSpecialArgs = mkSpecialArgs {
        inherit host;
        hostName = hostMeta.hostName or host;
        system = hostMeta.system;
      };
      modules = [
        (homeModulePath user hostMeta.type)
      ];
    };

  homeConfigEntries = lib.concatMap (
    user:
    let
      meta = userMetas.${user};
      nixosHosts = lib.filter (
        host: builtins.hasAttr host hostMetas && hostMetas.${host}.type == "nixos"
      ) (lib.optionals (hasHomeModule user "nixos") (meta.nixosHosts or [ ]));
      macosHosts = lib.filter (
        host: builtins.hasAttr host hostMetas && hostMetas.${host}.type == "macos"
      ) (lib.optionals (hasHomeModule user "macos") (meta.macosHosts or [ ]));
    in
    (map (host: {
      name = "${user}@${host}";
      value = mkHomeConfig { inherit user host; };
    }) nixosHosts)
    ++ (map (host: {
      name = "${user}@${host}";
      value = mkHomeConfig { inherit user host; };
    }) macosHosts)
  ) userNames;
in
{
  flake.homeConfigurations = lib.listToAttrs homeConfigEntries;
}
