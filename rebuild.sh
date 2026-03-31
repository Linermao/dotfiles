#!/usr/bin/env bash
set -euo pipefail

MIRROR="https://mirror.sjtu.edu.cn/nix-channels/store"
FALLBACK_SUBSTITUTER="https://cache.nixos.org/"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FLAKE_PREFIX="path:${ROOT_DIR}"

HOST=""
ACTION=""
ASSUME_YES=0
LIST_ONLY=0
USE_MIRROR=1

usage() {
  cat <<'EOF'
Usage:
  ./rebuild.sh [host] [action]
  ./rebuild.sh --host <name> --action <build|test|switch>

Options:
  --host <name>     Rebuild target host
  --action <name>   Rebuild action
  --mirror <url>    Override substituter mirror
  --no-mirror       Disable custom substituter mirror
  --yes             Skip confirmation prompt
  --list            Show available hosts for the current platform and exit
  --help            Show this help message

Notes:
  - Linux uses nixos-rebuild
  - macOS uses darwin-rebuild
  - This script uses path-based flakes so ignored local files like
    hardware-configuration.nix are still visible to Nix
EOF
}

detect_platform() {
  case "$(uname -s)" in
    Linux)
      PLATFORM="nixos"
      OS_LABEL="Linux / NixOS"
      REBUILD_CMD="nixos-rebuild"
      ACTIONS=("build" "test" "switch")
      ;;
    Darwin)
      PLATFORM="macos"
      OS_LABEL="macOS / nix-darwin"
      REBUILD_CMD="darwin-rebuild"
      ACTIONS=("build" "switch")
      ;;
    *)
      echo "[!] Unsupported OS: $(uname -s)" >&2
      exit 1
      ;;
  esac
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

read_host_name() {
  local host="$1"
  local meta="${ROOT_DIR}/hosts/${host}/meta.nix"
  sed -n 's/^[[:space:]]*hostName = "\(.*\)";/\1/p' "${meta}" | head -n 1
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
      if [[ -z "${HOST}" ]]; then
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

AVAILABLE_HOSTS=()
while IFS= read -r host; do
  [[ -n "${host}" ]] && AVAILABLE_HOSTS+=("${host}")
done < <(discover_hosts)

if [[ "${#AVAILABLE_HOSTS[@]}" -eq 0 ]]; then
  echo "[!] No ${PLATFORM} hosts found under ${ROOT_DIR}/hosts" >&2
  exit 1
fi

if [[ "${LIST_ONLY}" -eq 1 ]]; then
  echo "Available ${PLATFORM} hosts:"
  for host in "${AVAILABLE_HOSTS[@]}"; do
    echo "  - ${host} (hostName: $(read_host_name "${host}"))"
  done
  exit 0
fi

if [[ -z "${HOST}" ]]; then
  HOST="$(choose_from_list "Select a host:" "${AVAILABLE_HOSTS[@]}")"
fi

if [[ ! -f "${ROOT_DIR}/hosts/${HOST}/meta.nix" ]]; then
  echo "[!] Unknown host: ${HOST}" >&2
  echo "Available ${PLATFORM} hosts: ${AVAILABLE_HOSTS[*]}" >&2
  exit 1
fi

if ! grep -q "type = \"${PLATFORM}\";" "${ROOT_DIR}/hosts/${HOST}/meta.nix"; then
  echo "[!] Host '${HOST}' is not a ${PLATFORM} target." >&2
  exit 1
fi

if [[ -z "${ACTION}" ]]; then
  ACTION="$(choose_from_list "Select a rebuild action:" "${ACTIONS[@]}")"
fi

ACTION_OK=0
for candidate in "${ACTIONS[@]}"; do
  if [[ "${candidate}" == "${ACTION}" ]]; then
    ACTION_OK=1
    break
  fi
done

if [[ "${ACTION_OK}" -ne 1 ]]; then
  echo "[!] Invalid action '${ACTION}' for ${PLATFORM}" >&2
  echo "Supported actions: ${ACTIONS[*]}" >&2
  exit 1
fi

HOST_NAME="$(read_host_name "${HOST}")"
FLAKE_REF="${FLAKE_PREFIX}#${HOST}"

echo
echo "Rebuild summary"
echo "  Platform : ${OS_LABEL}"
echo "  Host     : ${HOST}"
echo "  hostName : ${HOST_NAME:-<unset>}"
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
echo "[*] Running: sudo ${REBUILD_CMD} ${ACTION} --flake ${FLAKE_REF}"
echo

cmd=(
  sudo "${REBUILD_CMD}" "${ACTION}"
  --flake "${FLAKE_REF}"
  --show-trace
)

if [[ "${USE_MIRROR}" -eq 1 ]]; then
  cmd+=(--option substituters "${MIRROR} ${FALLBACK_SUBSTITUTER}")
fi

"${cmd[@]}"
