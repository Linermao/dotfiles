#!/usr/bin/env bash
set -euo pipefail

# mirror
MIRROR="https://mirror.sjtu.edu.cn/nix-channels/store"

if [[ $# -ge 1 ]]; then
  USER="$1"
else
  echo "[*] No user specified. Detecting available user in ./home-manager/..."
  user_dires=()
  for d in ./home-manager/*/; do
    name=$(basename "$d")
    user_dires+=("$name")
  done

  echo "Available Users:"
  select selected_user in "${user_dires[@]}"; do
    if [[ -n "$selected_user" ]]; then
      USER="$selected_user"
      break
    else
      echo "Invalid selection."
    fi
  done
fi

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


home-manager switch \
  --flake .#"${USER}@${HOST}" \
  --show-trace \
  --option substituters "${MIRROR}"
