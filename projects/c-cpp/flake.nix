{
  description = "C & C++ development template (using g++)";

  inputs = {
    utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    utils,
    ...
  }:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in rec {
        packages.default = pkgs.stdenv.mkDerivation {
          pname = "c-cpp-template";
          version = "0.1.0";
          src = ./.;

          buildInputs = [ pkgs.gcc ];

          buildPhase = ''
            mkdir -p $out/bin

            if [ -f src/main.c ]; then
              echo "Building C source with g++..."
              ${pkgs.gcc}/bin/g++ -std=c++20 -o $out/bin/c-cpp-template src/main.c
            elif [ -f src/main.cpp ]; then
              echo "Building C++ source with g++..."
              ${pkgs.gcc}/bin/g++ -std=c++20 -o $out/bin/c-cpp-template src/main.cpp
            else
              echo "Error: No src/main.c or src/main.cpp found!"
              exit 1
            fi
          '';
        };

        apps.default = utils.lib.mkApp { drv = packages.default; };

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            gcc
            clang
            gdb
            lldb
            cmake
            meson
            ninja
            pkg-config
          ];
        };
      });
}
