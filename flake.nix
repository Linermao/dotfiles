# This is my nixos configuration
# by Linermao

{
  description = "My NixOS flake config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager = { 
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    }; 

    hyprland.url = "github:hyprwm/Hyprland";

    # macOS specific inputs
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
  };

  outputs = { self, nixpkgs, home-manager, nix-darwin, nix-homebrew, ... } @inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      lib = nixpkgs.lib;
      flakeDir = toString self; # get flake dir_name

      host = "desktop";
      paths = { 
        root = "${flakeDir}";
        resources = "${flakeDir}/resources";
      };
    in {
      # ---- Linux NixOS ----
      nixosConfigurations = {
        desktop = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit self inputs pkgs host paths;
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
          modules = [ ./modules/users/alvin/linux.nix ];
        };

        # macOS
        "alvin@macbook" = home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs { system = "aarch64-darwin"; config.allowUnfree = true; };
          extraSpecialArgs = { inherit inputs paths; host = "macbook"; };
          modules = [ ./modules/users/alvin/macos.nix ];
        };
      };
    };
}
