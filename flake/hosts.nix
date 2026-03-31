{
  inputs,
  lib,
  dotfiles,
  ...
}:

let
  inherit (dotfiles)
    hostMetas
    macosHostNames
    mkSpecialArgs
    nixosHostNames
    ;
in
{
  flake = {
    # ---- NixOS ----
    nixosConfigurations = lib.listToAttrs (
      map (host: {
        name = host;
        value = inputs.nixpkgs.lib.nixosSystem {
          system = hostMetas.${host}.system;
          specialArgs = mkSpecialArgs {
            inherit host;
            hostName = hostMetas.${host}.hostName or host;
            system = hostMetas.${host}.system;
          };
          modules = hostMetas.${host}.modules;
        };
      }) nixosHostNames
    );

    # ---- MacOS ----
    darwinConfigurations = lib.listToAttrs (
      map (host: {
        name = host;
        value = inputs.nix-darwin.lib.darwinSystem {
          system = hostMetas.${host}.system;
          specialArgs = mkSpecialArgs {
            inherit host;
            hostName = hostMetas.${host}.hostName or host;
            system = hostMetas.${host}.system;
          };
          modules = hostMetas.${host}.modules;
        };
      }) macosHostNames
    );
  };
}
