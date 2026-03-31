#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FLAKE_PREFIX="path:${ROOT_DIR}"

HOST=""
ACTION="switch"
INSTALL_NIX=""
ASSUME_YES=0
LIST_HOSTS=0

usage() {
  cat <<'EOF'
Usage:
  ./install_macos.sh [options]

Options:
  --host <name>     macOS host to activate
  --action <name>   darwin-rebuild action: build or switch
  --list-hosts      Show available macOS hosts and exit
  --install-nix     Install Nix first
  --skip-nix        Skip Nix installation step
  --yes             Skip confirmation prompts
  --help            Show this help message

Notes:
  - This script bootstraps Nix if needed and then activates the selected
    nix-darwin host via darwin-rebuild.
  - It uses the stable nix-darwin 25.11 bootstrap target to match this repo.
EOF
}

choose_from_list() {
  local prompt="$1"
  shift
  local options=("$@")
  local selected=""

  echo "${prompt}" >&2
  select selected in "${options[@]}"; do
    if [[ -n "${selected}" ]]; then
      printf '%s\n' "${selected}"
      return 0
    fi
    echo "[!] Invalid selection." >&2
  done
}

confirm() {
  local prompt="$1"
  local answer
  read -r -p "${prompt} [y/N] " answer
  [[ "${answer}" =~ ^[Yy]([Ee][Ss])?$ ]]
}

detect_hosts() {
  local meta
  for meta in "${ROOT_DIR}"/hosts/*/meta.nix; do
    [[ -f "${meta}" ]] || continue
    if grep -q 'type = "macos";' "${meta}"; then
      basename "$(dirname "${meta}")"
    fi
  done
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --host)
      HOST="${2:-}"
      shift 2
      ;;
    --action)
      ACTION="${2:-}"
      shift 2
      ;;
    --list-hosts)
      LIST_HOSTS=1
      shift
      ;;
    --install-nix)
      INSTALL_NIX="yes"
      shift
      ;;
    --skip-nix)
      INSTALL_NIX="no"
      shift
      ;;
    --yes)
      ASSUME_YES=1
      shift
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      echo "[!] Unexpected argument: $1" >&2
      usage
      exit 1
      ;;
  esac
done

AVAILABLE_HOSTS=()
while IFS= read -r host; do
  [[ -n "${host}" ]] && AVAILABLE_HOSTS+=("${host}")
done < <(detect_hosts)

if [[ "${#AVAILABLE_HOSTS[@]}" -eq 0 ]]; then
  echo "[!] No macOS hosts found under ${ROOT_DIR}/hosts" >&2
  exit 1
fi

if [[ "${LIST_HOSTS}" -eq 1 ]]; then
  echo "Available macOS hosts:"
  for host in "${AVAILABLE_HOSTS[@]}"; do
    echo "  - ${host}"
  done
  exit 0
fi

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "[!] install_macos.sh must be run on macOS." >&2
  exit 1
fi

if [[ -z "${HOST}" ]]; then
  HOST="$(choose_from_list "Select a macOS host:" "${AVAILABLE_HOSTS[@]}")"
fi

if [[ "${ACTION}" != "build" && "${ACTION}" != "switch" ]]; then
  echo "[!] Invalid action: ${ACTION}" >&2
  exit 1
fi

if [[ -z "${INSTALL_NIX}" ]]; then
  if command -v nix >/dev/null 2>&1; then
    INSTALL_NIX="no"
  elif [[ "${ASSUME_YES}" -eq 1 ]]; then
    INSTALL_NIX="yes"
  elif confirm "Nix is not installed. Install it now?"; then
    INSTALL_NIX="yes"
  else
    echo "Cancelled."
    exit 0
  fi
fi

echo
echo "macOS bootstrap summary"
echo "  Host   : ${HOST}"
echo "  Action : ${ACTION}"
echo "  Flake  : ${FLAKE_PREFIX}#${HOST}"
echo "  Install Nix first : ${INSTALL_NIX}"
echo

if [[ "${ASSUME_YES}" -ne 1 ]]; then
  confirm "Continue with macOS bootstrap?" || exit 0
fi

if [[ "${INSTALL_NIX}" == "yes" ]]; then
  echo "[*] Installing Nix"
  sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install)

  if ! command -v nix >/dev/null 2>&1; then
    if [[ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
      # shellcheck disable=SC1091
      . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
    fi
  fi
fi

echo
echo "[*] Running nix-darwin bootstrap"
echo

sudo nix run github:nix-darwin/nix-darwin/nix-darwin-25.11#darwin-rebuild \
  --extra-experimental-features "nix-command flakes" \
  -- "${ACTION}" --flake "${FLAKE_PREFIX}#${HOST}"
