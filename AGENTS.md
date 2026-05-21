# Dotfiles Project Guide

## Purpose

This repository is a single-user, single-machine-oriented dotfiles and NixOS setup.

The long-term workflow is:

1. Clone the repository onto a new machine.
2. Adjust `host/meta.nix` and any required hardware facts under `host/`.
3. Run installation or rebuild commands from the repository root flake.

The repository itself stores shared config assets, reusable optional modules, host templates, and resolver logic.
It does not aim to become a long-lived multi-host inventory.

## Design Principles

- Keep shared content separate from machine-specific host output.
- Prefer NixOS-native facts and installation mechanisms over custom detection logic.
- Treat Nix as the source of truth for module selection, defaults, and derived host settings.
- Keep the checked-in host entrypoint stable, then rebuild from that stable output.
- Keep the repository organized around a single current host, not a multi-host inventory.
- Prefer resolver-driven imports derived from `host/meta.nix` over hand-maintained import lists for optional modules.
- Keep the repository root as the only flake entrypoint.
- Allow a separate `nixpkgs-unstable` input for a small number of fast-moving home-side leaf packages when needed.
- Keep system modules on the primary stable `nixpkgs` input unless there is a clear reason to do otherwise.

## Repository Model

### `assets/`

Static resources that can be linked or imported by modules.

- `assets/config/`: raw application config assets

This directory should not contain machine decisions.
Current-machine media such as wallpapers and avatars belongs under `host/`, because it is part of the current host output rather than shared module input.

### `modules/`

Reusable optional Nix modules. These are shared building blocks, not host instances.

- `modules/nixos/system/`: NixOS system-level modules and the system-side resolver
- `modules/nixos/home/`: Home Manager modules and the home-side resolver

Naming rule:

- leaf modules use descriptive filenames such as `git.nix` or `docker.nix`
- GPU-specific modules live under `gpu/`
- display-session-specific modules live under `display/`
- server-style capabilities live under `servers/`
- virtualization capabilities live under `virtualizations/`
- user-space optional capabilities live under `ai/`, `programs/`, `terminal/`, `shell/`, `coding/`, `file-manager/`, or `display/`
- `system/resolve.nix` and `home/resolve.nix` are the only places that turn structured host selections into concrete optional-module imports
- simple groups and complex groups both go through the same resolver flow
- `hostConfig.modules.home.fileManager` maps to the `file-manager/` directory; keep metadata names user-facing and directory names descriptive
- the home display selection follows `hostConfig.modules.system.display` when a matching home display module exists
- the shell home module follows `hostConfig.user.shell`

### `host/`

Machine-specific configuration for the current machine.

- `host/system.nix`: machine-specific NixOS entrypoint; contains required system baseline and imports resolver-selected optional modules
- `host/home.nix`: machine-specific Home Manager entrypoint; contains required home baseline and imports resolver-selected optional modules
- `host/meta.nix`: minimal flake-facing machine metadata, user identity, and optional module selections
- `host/hardware-configuration.nix`: detected hardware facts used by the current machine
- `host/README.md`: short description of the generated host shape
- optional host-local assets such as `host/avatar.jpg` and `host/wallpapers/`

`host/` is the stable entrypoint for the current machine.
The repository root `flake.nix` reads this directory and exports the matching NixOS and Home Manager configurations.

### `template/`

Starter files for creating or refreshing the generated current-host shape.

Templates are not active host configuration by themselves. The active configuration remains under `host/`, and the root `flake.nix` reads `host/` directly.

## Generated Host Contract

The checked-in `host/` directory is expected to remain a small, stable machine description.

The target shape is:

- `host/system.nix`
- `host/home.nix`
- `host/meta.nix`
- optional facts such as `hardware-configuration.nix` or a facter-derived file
- optional host-local media such as wallpapers or avatars

The host should describe:

- hostname
- target system architecture
- state version
- unfree policy used by the root flake package set
- small machine facts or cross-cutting values consumed by host modules, such as CPU family or proxy settings
- user identity
- structured optional-module selections under `modules.system` and `modules.home`
- selected display/session and GPU module names through those module selections
- references to hardware/fact files when needed

System-only baseline settings such as locale, input method, boot policy, CPU facts, proxy, and similar machine policy may live directly in `host/system.nix` instead of `host/meta.nix`.

## Boundaries

What belongs in host files:

- machine identity
- selected module names and structured options
- references to detected hardware facts
- current-host media such as wallpapers and avatars
- required per-host baseline configuration that should always apply and is not an optional module
- helper arguments derived from that baseline when optional modules need them

What belongs in shared modules:

- optional capabilities only
- reusable behavior
- package sets
- service definitions
- config file linking
- resolver logic that turns host selections into concrete optional-module imports
- limited unstable-package wiring for selected home modules via `pkgsUnstable`

What belongs in `assets/`:

- shared static config files consumed by modules
- reusable assets that are not current-host decisions

## Current Phase

The current phase is Nix-first.

That means:

- keep host shape and resolver rules explicit in Nix first
- validate the manual Nix workflow before adding higher-level tooling
- avoid reintroducing generator-only abstractions unless they clearly reduce maintenance

## Guidance For Future Agents

- Preserve the separation between shared modules and generated hosts.
- Do not reintroduce multi-host assumptions unless explicitly requested.
- When adding new modules, place them by behavior category, not by implementation convenience.
- Keep flake-facing metadata and selected module names explicit in `host/meta.nix`; avoid hidden runtime detection during rebuild.
- Keep `host/meta.nix` small, but allow simple host-wide values there when multiple host entrypoints or modules need the same value.
- Keep `modules/` for optional capabilities only; do not move mandatory host baseline back into shared module trees.
- Prefer small host files, but allow `host/system.nix` and `host/home.nix` to carry the mandatory baseline that always applies to the current machine.
- When optional system modules need machine-specific baseline values, prefer exposing them from `host/system.nix` through module arguments instead of bloating `host/meta.nix`.
- Before implementing functionality, keep file and path names consistent with the structure defined here.
- Use `pkgsUnstable` only for isolated home-side leaf packages such as fast-moving CLI or GUI tools.
- Do not move system services or core system capabilities to `nixpkgs-unstable` by default.
- When a home module depends on `pkgsUnstable`, ensure every active Home Manager entrypoint receives `pkgsUnstable` via `extraSpecialArgs`. If a NixOS-integrated Home Manager path is added later, wire it there as well as in standalone `homeConfigurations`.
