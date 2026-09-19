# MacBook configuration

This directory contains a reference configuration for an Apple Silicon MacBook. It is not a separate flake and is not read directly by the repository root flake.

The configuration intentionally manages only macOS personalization and machine policy:

- Dock, Finder, keyboard, trackpad, menu bar, dark mode, screen saver, and login-window defaults
- hostname and time zone
- Touch ID authentication for `sudo`
- startup chime

It intentionally does not manage applications, Homebrew, App Store software, Home Manager, shell configuration, or user dotfiles. Add `home.nix` only if user-level configuration is introduced later.

Copy the template into the active `host/` directory:

```sh
mkdir -p host
cp template/macbook/meta.nix template/macbook/system.nix host/
```

The root flake always reads `host/meta.nix`. Its `platform` value selects nix-darwin, and `host/system.nix` becomes the active Darwin module.

For the first activation, when `darwin-rebuild` is not installed yet, run from the repository root:

```sh
sudo nix \
  --extra-experimental-features "nix-command flakes" \
  --option substituters \
    "https://mirrors.ustc.edu.cn/nix-channels/store https://cache.nixos.org/" \
  run nix-darwin/nix-darwin-26.05#darwin-rebuild -- \
  switch --flake "path:$PWD#macbook"
```

The bootstrap command tries the USTC binary-cache mirror first and keeps the
official cache as a fallback. After activation, `host/system.nix` manages the
same substituters and enables `nix-command` and flakes permanently.

After nix-darwin is installed, apply later changes with:

```sh
sudo darwin-rebuild switch --flake "path:$PWD#macbook"
```

The configuration keeps nix-darwin `system.stateVersion` at `6`, matching the previous MacBook configuration. Do not change it merely when updating nix-darwin.
