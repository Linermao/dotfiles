{
  description = "Single-machine NixOS dotfiles with a reference macOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-darwin.url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };
    dms = {
      url = "github:AvengeMedia/DankMaterialShell/stable";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dank-greeter = {
      url = "github:AvengeMedia/dank-greeter";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      nixpkgs,
      home-manager,
      nix-darwin,
      ...
    }:
    let
      root = ./.;
      hostConfig = import ./host/meta.nix;
      isDarwin = nixpkgs.lib.hasSuffix "-darwin" hostConfig.platform;
      paths = {
        root = toString root;
        assets = toString (root + "/assets");
      };
    in
    if isDarwin then
      {
        darwinConfigurations.${hostConfig.hostName} = nix-darwin.lib.darwinSystem {
          system = hostConfig.platform;
          specialArgs = {
            inherit
              hostConfig
              inputs
              paths
              root
              ;
          };
          modules = [ ./host/system.nix ];
        };
      }
    else
      let
        pkgs = import nixpkgs {
          system = hostConfig.platform;
          config.allowUnfree = hostConfig.allowUnfree;
        };
        pkgsUnstable = import inputs.nixpkgs-unstable {
          system = hostConfig.platform;
          config.allowUnfree = hostConfig.allowUnfree;
        };
      in
      {
        nixosConfigurations.${hostConfig.hostName} = nixpkgs.lib.nixosSystem {
          system = hostConfig.platform;

          specialArgs = {
            inherit
              hostConfig
              inputs
              paths
              pkgsUnstable
              root
              ;
          };

          modules = [
            ./host/system.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = {
                inherit
                  hostConfig
                  inputs
                  paths
                  root
                  pkgsUnstable
                  ;
              };
              home-manager.users.${hostConfig.user.name} = import ./host/home.nix;
            }
          ];
        };

        homeConfigurations."${hostConfig.user.name}@${hostConfig.hostName}" =
          home-manager.lib.homeManagerConfiguration
            {
              inherit pkgs;
              extraSpecialArgs = {
                inherit
                  hostConfig
                  inputs
                  paths
                  root
                  pkgsUnstable
                  ;
              };
              modules = [ ./host/home.nix ];
            };
      };
}
