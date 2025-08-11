#!/usr/bin/env bash
set -euo pipefail

# Mirror URL
MIRROR="https://mirror.sjtu.edu.cn/nix-channels/store"


# Get the current system type (Linux or Darwin)
OS_TYPE=$(uname -s)

echo
echo "[*] Using OS: $OS_TYPE"
echo

# Determine the host argument
if [[ $# -ge 1 ]]; then
  HOST="$1"
else
  echo "[*] No host specified. Detecting available hosts in ./hosts/..."
  host_dirs=()
  for d in ./hosts/*/; do
    name=$(basename "$d")
    host_dirs+=("$name")
  done

  echo "Available hosts:"
  select selected_host in "${host_dirs[@]}"; do
    if [[ -n "$selected_host" ]]; then
      HOST="$selected_host"
      break
    else
      echo "Invalid selection."
    fi
  done
fi

echo
echo "[*] Rebuilding system for host: $HOST"
echo

# Determine the appropriate command based on OS type
if [[ "$OS_TYPE" == "Linux" ]]; then
  # Linux system: Use nixos-rebuild
  echo "[*] Detected Linux. Running nixos-rebuild..."
  sudo nixos-rebuild switch \
    --flake .#"${HOST}" \
    --show-trace \
    --option substituters "${MIRROR}"
  
elif [[ "$OS_TYPE" == "Darwin" ]]; then
  # macOS system: Use darwin-rebuild
  echo "[*] Detected macOS. Running darwin-rebuild..."
  sudo darwin-rebuild switch \
    --flake .#"${HOST}" \
    --show-trace \
    --option substituters "${MIRROR}"
  
else
  echo "[*] Unsupported OS: $OS_TYPE"
  exit 1
fi
