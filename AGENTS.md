# Dotfiles Architecture Guidelines

## Goal

This repository is a cross-platform dotfiles and system configuration project.

It must support both:

- Linux with NixOS
- macOS with nix-darwin

The repository is intentionally split into system-level and user-level layers:

- System-level configuration is composed from `hosts/` and `modules/system/{nixos,macos}`
- User-level configuration is composed with Home Manager from `users/` and `modules/home-manager`
- Static assets deployed by Home Manager live under `assets/`

## Current Structure

```text
.
├── flake.nix
├── flake/
│   ├── core.nix
│   ├── home-manager.nix
│   ├── hosts.nix
│   └── shared.nix
├── hosts/
│   ├── desktop-intel/
│   │   ├── hardware-configuration.nix
│   │   └── meta.nix
│   ├── desktop/
│   │   ├── hardware-configuration.nix
│   │   └── meta.nix
│   └── macbook/
│       └── meta.nix
├── modules/
│   ├── system/
│   │   ├── macos/
│   │   │   ├── base.nix
│   │   │   ├── desktop.nix
│   │   │   ├── homebrew.nix
│   │   │   ├── nix.nix
│   │   │   ├── system.nix
│   │   │   └── users.nix
│   │   └── nixos/
│   │       ├── base.nix
│   │       ├── desktop.nix
│   │       ├── nix.nix
│   │       ├── system.nix
│   │       ├── users.nix
│   │       ├── virtualization.nix
│   │       ├── hardware/
│   │       │   ├── intel.nix
│   │       │   └── nvidia.nix
│   │       └── services/
│   │           ├── sunshine.nix
│   │           └── tailscale.nix
│   └── home-manager/
│       ├── common/
│       │   ├── git.nix
│       │   ├── nvim.nix
│       │   ├── shell.nix
│       │   └── yazi.nix
│       ├── macos/
│       │   ├── coding.nix
│       │   ├── misc.nix
│       │   ├── softwares.nix
│       │   ├── terminal.nix
│       │   └── virtual.nix
│       └── nixos/
│           ├── ai.nix
│           ├── coding.nix
│           ├── desktop.nix
│           ├── misc.nix
│           ├── scripts.nix
│           ├── softwares.nix
│           └── terminal.nix
├── users/
│   └── alvin/
│       ├── meta.nix
│       ├── system/
│       │   ├── macos.nix
│       │   └── nixos.nix
│       └── home/
│           ├── macos.nix
│           └── nixos.nix
└── assets/
    ├── avatars/
    ├── config/
    ├── fonts/
    ├── scripts/
    └── wallpapers/
```

## Design Principles

1. `hosts/` is the source of truth for machine definitions and system outputs.
2. `modules/` contains reusable building blocks only.
3. `modules/system/` is only for system-level modules selected by hosts.
4. `modules/home-manager/` is only for Home Manager modules selected by users.
5. `users/` is the source of truth for per-user metadata, system-level user definitions, and Home Manager composition.
6. `assets/` contains static files referenced by Home Manager.
7. System concerns and user concerns must remain separate.
8. Host files should stay thin and mainly express composition.
9. Reusable logic should be moved into `modules/`, not duplicated across hosts.
10. Home Manager modules should prefer capability-oriented boundaries.

## Responsibilities

### `hosts/`

Use `hosts/` as the canonical home for host definitions.

Typical contents:

- `meta.nix` describing host type, system, hostname, and module list
- `hardware-configuration.nix` when needed for NixOS hosts

Each host directory should map to one actual build target exposed by `flake.nix`.

Reusable logic should still live in `modules/`, but the host directory is responsible for declaring which modules are used.

### `modules/system/nixos/`

Use `modules/system/nixos/` for reusable NixOS system modules.

Examples:

- shared base system packages
- Nix settings
- generic desktop behavior
- system defaults
- user declarations
- virtualization
- hardware-specific GPU modules
- standalone service modules such as Sunshine or Tailscale

### `modules/system/macos/`

Use `modules/system/macos/` for reusable macOS system modules built with nix-darwin.

Examples:

- shared macOS packages
- macOS desktop defaults
- Nix settings
- system defaults
- user declarations
- Homebrew integration

### `modules/home-manager/common/`

Use this directory for cross-platform Home Manager modules.

Current examples:

- `git.nix`
- `nvim.nix`
- `shell.nix`
- `yazi.nix`

### `modules/home-manager/nixos/`

Use this directory for NixOS-only Home Manager modules.

Current examples:

- AI-related packages
- coding packages
- NixOS desktop integration
- NixOS scripts
- NixOS terminal packages

### `modules/home-manager/macos/`

Use this directory for macOS-only Home Manager modules.

Current examples:

- macOS coding packages
- macOS software packages
- macOS terminal-related configuration
- macOS virtualization tools

### `users/`

Use `users/` as the canonical home for user definitions.

Each user should live in its own directory, for example `users/alvin/`, and should contain:

- `meta.nix` for host membership and user metadata
- `system/nixos.nix` for NixOS user-level system declarations
- `system/macos.nix` for nix-darwin user-level system declarations
- `home/nixos.nix` for NixOS Home Manager composition
- `home/macos.nix` for macOS Home Manager composition

The goal is that adding a new user should primarily mean creating a new `users/<name>/` directory rather than editing multiple unrelated files across the repository.

### `assets/`

Use `assets/` for static files deployed or referenced by Home Manager.

Examples:

- application config directories
- shell scripts
- wallpapers
- fonts
- avatars

Static files should not be mixed into module directories.

## Home Manager Philosophy

For Home Manager, prefer small capability-oriented modules over a few large mixed files.

That means:

- shared tools belong in `modules/home-manager/common/`
- NixOS-only behavior belongs in `modules/home-manager/nixos/`
- macOS-only behavior belongs in `modules/home-manager/macos/`
- user directories under `users/` should centralize user-specific logic instead of scattering it across system and Home Manager layers

This keeps the structure clearer as the repository grows and makes later splitting or merging easier.

## Naming Guidance

Prefer specific names over vague buckets whenever practical.

Good examples:

- `users.nix`
- `homebrew.nix`
- `tailscale.nix`
- `virtualization.nix`

Broad names like `misc.nix` or `softwares.nix` are acceptable temporarily when the scope is still mixed, but should be split later if they become too large or too unclear.

Use `nixos` and `macos` consistently for local naming.
Avoid mixing local labels such as `linux` or `darwin` when referring to repository paths, module groups, or user entry files.

## Scope Decisions For Now

Fast-moving applications are not part of this restructure yet.

`codex` is the only currently identified fast-moving application. For now it remains outside this directory redesign and does not introduce a separate update layer.

This means the current restructure is focused on:

- clean support for NixOS and macOS
- clear separation between system-level and user-level configuration
- clearer ownership of host entrypoints, reusable modules, user composition, and static assets

## Editing Guidance

When continuing this refactor in the future:

1. Do not change user-facing behavior unless explicitly requested.
2. Keep usernames, package selections, and dotfile contents unchanged during structure-only work.
3. Adjust import paths and asset references as needed when moving files.
4. Keep README and rebuild scripts out of scope unless the task explicitly includes them.
5. If a module is empty or redundant, confirm before deleting it unless its removal is already agreed.
6. Prefer adding new users by creating `users/<name>/meta.nix`, `users/<name>/system/*`, and `users/<name>/home/*` instead of editing shared user registries by hand.
7. Prefer adding new hosts by creating `hosts/<name>/meta.nix` and the needed local files instead of manually registering them in `flake.nix`.
