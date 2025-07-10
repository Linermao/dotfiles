## My nixos configure

### 🖼️ Gallery (empty now)


## Overview

### Layout

- [flake.nix](flake.nix) base of the configuration
- [hosts](hosts) per-host configurations that contain machine specific configurations
  - [desktop](hosts/desktop/) 🖥️ Desktop specific configuration
- [modules](modules)
  - [system](modules/system/) System configuration
  - [users](modules/users/) per-user configuration with .config and apps

## 📓 Components
|                             | Nixos + Hyprland     |
| --------------------------- | :--------------------:
| **Window Manager**          | [Hyprland](Hyprland) |
| **Shell**                   | [fish](fish)         |
| **Bar**                     | [waybar](waybar)     |
| **Sddm**                    | [sddm-astronaut](sddm-astronaut)     |
