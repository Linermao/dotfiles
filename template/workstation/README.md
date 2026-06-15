# Host

This directory stores the generated configuration for the current machine.

The intended generated shape is:

- `host/meta.nix`
- `host/system.nix`
- `host/home.nix`

The repository root `flake.nix` reads this directory directly.
