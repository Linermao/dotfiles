#!/usr/bin/env bash
set -euo pipefail

# mirror
MIRROR="https://mirror.sjtu.edu.cn/nix-channels/store"

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

sudo nixos-rebuild switch \
  --flake .#"${HOST}" \
  --show-trace \
  --option substituters "${MIRROR}"
