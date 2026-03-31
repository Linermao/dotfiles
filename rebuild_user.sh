#!/usr/bin/env bash
set -euo pipefail

MIRROR="https://mirror.sjtu.edu.cn/nix-channels/store"
FALLBACK_SUBSTITUTER="https://cache.nixos.org/"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FLAKE_PREFIX="path:${ROOT_DIR}"

USER_NAME=""
HOST=""
ACTION=""
ASSUME_YES=0
LIST_ONLY=0
USE_MIRROR=1

usage() {
  cat <<'EOF'
Usage:
  ./rebuild_user.sh [user] [host] [action]
  ./rebuild_user.sh --user <name> --host <name> --action <build|switch>

Options:
  --user <name>     Home Manager user
  --host <name>     Host attached to the Home Manager output
  --action <name>   Home Manager action
  --mirror <url>    Override substituter mirror
  --no-mirror       Disable custom substituter mirror
  --yes             Skip confirmation prompt
  --list            Show available users and hosts for the current platform
  --help            Show this help message

Notes:
  - Linux uses users/*/home/nixos.nix
  - macOS uses users/*/home/macos.nix
  - This script validates that <user>@<host> exists before switching
EOF
}

detect_platform() {
  case "$(uname -s)" in
    Linux)
      PLATFORM="nixos"
      OS_LABEL="Linux / NixOS"
      ;;
    Darwin)
      PLATFORM="macos"
      OS_LABEL="macOS / nix-darwin"
      ;;
    *)
      echo "[!] Unsupported OS: $(uname -s)" >&2
      exit 1
      ;;
  esac
  ACTIONS=("build" "switch")
}

discover_users() {
  local home_file
  for home_file in "${ROOT_DIR}"/users/*/home/"${PLATFORM}.nix"; do
    [[ -f "${home_file}" ]] || continue
    basename "$(dirname "$(dirname "${home_file}")")"
  done
}

discover_hosts() {
  local meta
  for meta in "${ROOT_DIR}"/hosts/*/meta.nix; do
    [[ -f "${meta}" ]] || continue
    if grep -q "type = \"${PLATFORM}\";" "${meta}"; then
      basename "$(dirname "${meta}")"
    fi
  done
}

choose_from_list() {
  local prompt="$1"
  shift
  local options=("$@")
  local selected=""

  if [[ "${#options[@]}" -eq 0 ]]; then
    return 1
  fi

  echo "${prompt}" >&2
  select selected in "${options[@]}"; do
    if [[ -n "${selected}" ]]; then
      printf '%s\n' "${selected}"
      return 0
    fi
    echo "[!] Invalid selection."
  done
}

confirm() {
  local answer
  read -r -p "Continue? [y/N] " answer
  [[ "${answer}" =~ ^[Yy]([Ee][Ss])?$ ]]
}

validate_target() {
  local user="$1"
  local host="$2"
  nix eval "${FLAKE_PREFIX}#homeConfigurations.\"${user}@${host}\".config.home.username" >/dev/null 2>&1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --user)
      USER_NAME="${2:-}"
      shift 2
      ;;
    --host)
      HOST="${2:-}"
      shift 2
      ;;
    --action)
      ACTION="${2:-}"
      shift 2
      ;;
    --mirror)
      MIRROR="${2:-}"
      USE_MIRROR=1
      shift 2
      ;;
    --no-mirror)
      USE_MIRROR=0
      shift
      ;;
    --yes)
      ASSUME_YES=1
      shift
      ;;
    --list)
      LIST_ONLY=1
      shift
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      if [[ -z "${USER_NAME}" ]]; then
        USER_NAME="$1"
      elif [[ -z "${HOST}" ]]; then
        HOST="$1"
      elif [[ -z "${ACTION}" ]]; then
        ACTION="$1"
      else
        echo "[!] Unexpected argument: $1" >&2
        usage
        exit 1
      fi
      shift
      ;;
  esac
done

detect_platform

AVAILABLE_USERS=()
while IFS= read -r user; do
  [[ -n "${user}" ]] && AVAILABLE_USERS+=("${user}")
done < <(discover_users)

AVAILABLE_HOSTS=()
while IFS= read -r host; do
  [[ -n "${host}" ]] && AVAILABLE_HOSTS+=("${host}")
done < <(discover_hosts)

if [[ "${#AVAILABLE_USERS[@]}" -eq 0 ]]; then
  echo "[!] No ${PLATFORM} Home Manager users found under ${ROOT_DIR}/users" >&2
  exit 1
fi

if [[ "${#AVAILABLE_HOSTS[@]}" -eq 0 ]]; then
  echo "[!] No ${PLATFORM} hosts found under ${ROOT_DIR}/hosts" >&2
  exit 1
fi

if [[ "${LIST_ONLY}" -eq 1 ]]; then
  echo "Available ${PLATFORM} Home Manager users:"
  for user in "${AVAILABLE_USERS[@]}"; do
    echo "  - ${user}"
  done
  echo
  echo "Available ${PLATFORM} hosts:"
  for host in "${AVAILABLE_HOSTS[@]}"; do
    echo "  - ${host}"
  done
  exit 0
fi

if [[ -z "${USER_NAME}" ]]; then
  USER_NAME="$(choose_from_list "Select a user:" "${AVAILABLE_USERS[@]}")"
fi

if [[ -z "${HOST}" ]]; then
  HOST="$(choose_from_list "Select a host:" "${AVAILABLE_HOSTS[@]}")"
fi

if [[ -z "${ACTION}" ]]; then
  ACTION="$(choose_from_list "Select a Home Manager action:" "${ACTIONS[@]}")"
fi

ACTION_OK=0
for candidate in "${ACTIONS[@]}"; do
  if [[ "${candidate}" == "${ACTION}" ]]; then
    ACTION_OK=1
    break
  fi
done

if [[ "${ACTION_OK}" -ne 1 ]]; then
  echo "[!] Invalid Home Manager action '${ACTION}'" >&2
  echo "Supported actions: ${ACTIONS[*]}" >&2
  exit 1
fi

FLAKE_REF="${FLAKE_PREFIX}#${USER_NAME}@${HOST}"

if ! validate_target "${USER_NAME}" "${HOST}"; then
  echo "[!] Home Manager output '${USER_NAME}@${HOST}' does not exist or failed to evaluate." >&2
  echo "    Check users/${USER_NAME}/meta.nix and users/${USER_NAME}/home/${PLATFORM}.nix" >&2
  exit 1
fi

echo
echo "Home Manager summary"
echo "  Platform : ${OS_LABEL}"
echo "  User     : ${USER_NAME}"
echo "  Host     : ${HOST}"
echo "  Action   : ${ACTION}"
echo "  Flake    : ${FLAKE_REF}"
if [[ "${USE_MIRROR}" -eq 1 ]]; then
  echo "  Mirror   : ${MIRROR}"
else
  echo "  Mirror   : disabled"
fi
echo

if [[ "${ASSUME_YES}" -ne 1 ]]; then
  if ! confirm; then
    echo "Cancelled."
    exit 0
  fi
fi

echo
echo "[*] Running: home-manager ${ACTION} --flake ${FLAKE_REF}"
echo

cmd=(
  home-manager "${ACTION}"
  --flake "${FLAKE_REF}"
  --show-trace
)

if [[ "${USE_MIRROR}" -eq 1 ]]; then
  cmd+=(--option substituters "${MIRROR} ${FALLBACK_SUBSTITUTER}")
fi

"${cmd[@]}"
