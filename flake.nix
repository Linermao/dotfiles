# This is my nixos configuration
# by Linermao

{
  description = "My NixOS flake config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.05";

    # macOS specific inputs
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-25.05";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";

    # home manager
    home-manager = { 
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager-stable = { 
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    hyprland.url = "github:hyprwm/Hyprland";
    
    # caelestia
    caelestia-shell = {
      url = "github:caelestia-dots/shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-stable, home-manager, home-manager-stable, nix-darwin, nix-homebrew, ... } @inputs:
    let
      flakeDir = toString self; # get flake dir_name
      paths = { 
        root = "${flakeDir}";
      };
    in {
      # ---- NixOS ----
      nixosConfigurations = {
        desktop = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit self inputs paths;
            host = "desktop";
          };

          modules = [ 
            ./hosts/desktop
          ];
        };
      };

      # ---- macOS ----
      darwinConfigurations = {
        macbook = nix-darwin.lib.darwinSystem {
          system = "aarch64-darwin"; # Intel Mac - "x86_64-darwin"
          specialArgs = {
            inherit self inputs paths;
            host = "macbook";
          };

          modules = [ 
            ./hosts/macbook
            nix-homebrew.darwinModules.nix-homebrew {
              nix-homebrew = {
                enable = true;
                # Apple Silicon support
                enableRosetta = true;
                # Homebrew prefix
                user = "alvin";

                autoMigrate = true; # Automatically migrate from old homebrew module
              };
            }
          ];
        };
      };

      # ---- Home Manager ----
      homeConfigurations = {
        # Linux
        "alvin@desktop" = home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs { system = "x86_64-linux"; config.allowUnfree = true; };
          extraSpecialArgs = { inherit inputs paths; host = "desktop"; };
          modules = [ ./home-manager/alvin/linux ];
        };

        # macOS
        "alvin@macbook" = home-manager-stable.lib.homeManagerConfiguration {
          pkgs = import nixpkgs-stable { system = "aarch64-darwin"; config.allowUnfree = true; };
          extraSpecialArgs = { inherit inputs paths; host = "macbook"; };
          modules = [ ./home-manager/alvin/macos ];
        };
      };
    };
}
