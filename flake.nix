{
  description = "Single-machine generated dotfiles and NixOS repository";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    dms = {
      url = "github:AvengeMedia/DankMaterialShell/stable";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      nixpkgs,
      home-manager,
      ...
    }:
    let
      root = ./.;
      hostConfig = import ./host/meta.nix;
      paths = {
        root = toString root;
        assets = toString (root + "/assets");
      };
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
          inherit hostConfig inputs paths root;
        };

        modules = [ ./host/system.nix ];
      };

      homeConfigurations."${hostConfig.user.name}@${hostConfig.hostName}" =
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = {
            inherit hostConfig inputs paths root pkgsUnstable;
          };
          modules = [ ./host/home.nix ];
        };
    };
}
