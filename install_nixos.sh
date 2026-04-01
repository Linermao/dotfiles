#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FLAKE_PREFIX="path:${ROOT_DIR}"
MIRROR="https://mirror.sjtu.edu.cn/nix-channels/store"
FALLBACK_SUBSTITUTER="https://cache.nixos.org/"

MODE=""
HOST=""
DEVICE="/dev/nvme0n1"
EFI_PART=""
ROOT_PART=""
SWAP_PART=""
MNT="/mnt"
SWAP_SIZE_GIB=32
ASSUME_YES=0
RUN_INSTALL=""
FORMAT_ROOT=0
FORMAT_EFI=0
FORMAT_SWAP=0
LIST_HOSTS=0
USE_MIRROR=1
LAYOUT_MOUNTED=0
HOST_USERS=()

usage() {
  cat <<'EOF'
Usage:
  ./install_nixos.sh --mode <fresh|existing> [options]

Modes:
  fresh
    Wipe an entire disk, repartition it, format it, generate hardware config,
    copy the repo into the target system, and optionally run nixos-install.

  existing
    Reuse an existing partition layout, mount the given EFI/root/swap
    partitions, generate hardware config, copy the repo into the target system,
    and optionally run nixos-install.

Common options:
  --mode <name>     Install mode: fresh or existing
  --host <name>     NixOS host directory under hosts/
  --mnt <path>      Target mount point, default: /mnt
  --list-hosts      Show available NixOS hosts and exit
  --mirror <url>    Override substituter mirror
  --no-mirror       Disable custom substituter mirror
  --yes             Skip confirmation prompts
  --install         Run nixos-install automatically at the end
  --no-install      Do not run nixos-install automatically
  --help            Show this help message

Fresh mode options:
  --device <path>   Whole disk device to wipe and repartition
  --swap-size <GiB> Swap partition size in GiB, default: 32

Existing mode options:
  --efi <path>      Existing EFI partition
  --root <path>     Existing root partition, expected to be Btrfs
  --swap <path>     Existing swap partition, optional
  --format-root     Reformat the root partition as Btrfs before install
  --format-efi      Reformat the EFI partition as FAT32 before install
  --format-swap     Recreate swap signature before install

Notes:
  - fresh is destructive and intended for full-disk installs only.
  - existing is safer, but it can still destroy data if you choose formatting
    options or point at the wrong partitions.
  - The generated hosts/<name>/hardware-configuration.nix is host-local and
    ignored by git.
  - This installer uses path-based flakes so local ignored files remain usable.
EOF
}

require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "[!] Missing required command: $1" >&2
    exit 1
  fi
}

run_root() {
  if [[ "${EUID}" -eq 0 ]]; then
    "$@"
  else
    sudo "$@"
  fi
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
    if grep -q 'type = "nixos";' "${meta}"; then
      basename "$(dirname "${meta}")"
    fi
  done
}

detect_users_for_host() {
  local host="$1"
  local users_dir="${ROOT_DIR}/users"
  local meta

  for meta in "${users_dir}"/*/meta.nix; do
    [[ -f "${meta}" ]] || continue

    local user_dir user_name
    user_dir="$(dirname "${meta}")"
    user_name="$(basename "${user_dir}")"

    if [[ ! -f "${user_dir}/system/nixos.nix" ]]; then
      continue
    fi

    if grep -q "\"${host}\"" "${meta}"; then
      printf '%s\n' "${user_name}"
    fi
  done
}

read_host_name() {
  local host="$1"
  sed -n 's/^[[:space:]]*hostName = "\(.*\)";/\1/p' "${ROOT_DIR}/hosts/${host}/meta.nix" | head -n 1
}

partition_path() {
  local device="$1"
  local index="$2"
  if [[ "${device}" =~ [0-9]$ ]]; then
    printf '%sp%s\n' "${device}" "${index}"
  else
    printf '%s%s\n' "${device}" "${index}"
  fi
}

ensure_empty_mountpoint() {
  if mountpoint -q "${MNT}"; then
    echo "[!] ${MNT} is already mounted. Unmount it first and retry." >&2
    exit 1
  fi
}

ensure_btrfs_subvolumes() {
  local root_part="$1"
  local temp_mount
  temp_mount="$(mktemp -d)"

  run_root mount "${root_part}" "${temp_mount}"

  if ! run_root btrfs subvolume list "${temp_mount}" | grep -qE ' path root$'; then
    run_root btrfs subvolume create "${temp_mount}/root"
  fi

  if ! run_root btrfs subvolume list "${temp_mount}" | grep -qE ' path home$'; then
    run_root btrfs subvolume create "${temp_mount}/home"
  fi

  if ! run_root btrfs subvolume list "${temp_mount}" | grep -qE ' path nixos$'; then
    run_root btrfs subvolume create "${temp_mount}/nixos"
  fi

  run_root umount "${temp_mount}"
  rmdir "${temp_mount}"
}

mount_layout() {
  run_root mkdir -p "${MNT}"
  run_root mount -o compress=zstd,subvol=root "${ROOT_PART}" "${MNT}"
  run_root mkdir -p "${MNT}/home" "${MNT}/boot" "${MNT}/nixos"
  run_root mount -o compress=zstd,subvol=home "${ROOT_PART}" "${MNT}/home"
  run_root mount -o compress=zstd,noatime,subvol=nixos "${ROOT_PART}" "${MNT}/nixos"
  run_root mount "${EFI_PART}" "${MNT}/boot"
  if [[ -n "${SWAP_PART}" ]]; then
    run_root swapon "${SWAP_PART}"
  fi
  LAYOUT_MOUNTED=1
}

cleanup_mounts() {
  if [[ "${LAYOUT_MOUNTED}" -ne 1 ]]; then
    return 0
  fi

  echo
  echo "[*] Cleaning up mounted layout under ${MNT}"

  if [[ -n "${SWAP_PART}" ]]; then
    run_root swapoff "${SWAP_PART}" 2>/dev/null || true
  fi

  run_root umount "${MNT}/boot" 2>/dev/null || true
  run_root umount "${MNT}/home" 2>/dev/null || true
  run_root umount "${MNT}/nixos" 2>/dev/null || true
  run_root umount "${MNT}" 2>/dev/null || true

  LAYOUT_MOUNTED=0
}

prepare_fresh_layout() {
  EFI_PART="$(partition_path "${DEVICE}" 1)"
  ROOT_PART="$(partition_path "${DEVICE}" 2)"
  SWAP_PART="$(partition_path "${DEVICE}" 3)"

  echo
  echo "Fresh install summary"
  echo "  Host      : ${HOST}"
  echo "  hostName  : ${HOST_NAME}"
  echo "  Device    : ${DEVICE}"
  echo "  EFI       : ${EFI_PART}"
  echo "  Root      : ${ROOT_PART}"
  echo "  Swap      : ${SWAP_PART}"
  echo "  Mount dir : ${MNT}"
  echo "  Swap size : ${SWAP_SIZE_GIB} GiB"
  echo
  echo "[!] DANGER: fresh mode will wipe the ENTIRE disk."
  echo "[!] It will destroy all existing partitions, filesystems, operating systems,"
  echo "[!] and user data on ${DEVICE}."
  echo "[!] Only continue if this disk can be fully erased."
  echo

  if [[ "${ASSUME_YES}" -ne 1 ]]; then
    confirm "Proceed with FULL DISK WIPE on ${DEVICE}?" || exit 0
    confirm "Confirm again: erase everything on ${DEVICE}?" || exit 0
  fi

  echo "[*] Wiping ${DEVICE}"
  run_root wipefs -a "${DEVICE}"
  run_root dd if=/dev/zero of="${DEVICE}" bs=1M count=10 status=progress

  echo "[*] Creating GPT partition table"
  run_root parted "${DEVICE}" --script mklabel gpt
  run_root parted "${DEVICE}" --script mkpart ESP fat32 1MiB 513MiB
  run_root parted "${DEVICE}" --script set 1 boot on

  local total_size swap_size btrfs_end btrfs_end_mib
  total_size="$(run_root blockdev --getsize64 "${DEVICE}")"
  swap_size=$((SWAP_SIZE_GIB * 1024 * 1024 * 1024))
  btrfs_end=$((total_size - swap_size))
  btrfs_end_mib=$((btrfs_end / 1024 / 1024))

  run_root parted "${DEVICE}" --script mkpart primary 513MiB "${btrfs_end_mib}MiB"
  run_root parted "${DEVICE}" --script mkpart primary linux-swap "${btrfs_end_mib}MiB" 100%

  echo "[*] Formatting partitions"
  run_root mkfs.fat -F32 "${EFI_PART}"
  run_root mkfs.btrfs -f "${ROOT_PART}"
  run_root mkswap -f "${SWAP_PART}"

  echo "[*] Creating Btrfs subvolumes"
  ensure_btrfs_subvolumes "${ROOT_PART}"
}

prepare_existing_layout() {
  if [[ -z "${ROOT_PART}" ]]; then
    read -r -p "Root partition (Btrfs) path: " ROOT_PART
  fi
  if [[ -z "${EFI_PART}" ]]; then
    read -r -p "EFI partition path: " EFI_PART
  fi
  if [[ -z "${SWAP_PART}" ]]; then
    read -r -p "Swap partition path (optional, press Enter to skip): " SWAP_PART
  fi

  if [[ ! -b "${ROOT_PART}" ]]; then
    echo "[!] Root partition does not exist: ${ROOT_PART}" >&2
    exit 1
  fi

  if [[ ! -b "${EFI_PART}" ]]; then
    echo "[!] EFI partition does not exist: ${EFI_PART}" >&2
    exit 1
  fi

  if [[ -n "${SWAP_PART}" && ! -b "${SWAP_PART}" ]]; then
    echo "[!] Swap partition does not exist: ${SWAP_PART}" >&2
    exit 1
  fi

  if [[ "${ASSUME_YES}" -ne 1 ]]; then
    echo
    echo "Existing layout summary"
    echo "  Host      : ${HOST}"
    echo "  hostName  : ${HOST_NAME}"
    echo "  Root      : ${ROOT_PART}"
    echo "  EFI       : ${EFI_PART}"
    echo "  Swap      : ${SWAP_PART:-<none>}"
    echo "  Mount dir : ${MNT}"
    echo
    echo "[!] existing mode does NOT repartition the whole disk."
    echo "[!] But it can still destroy data if you choose formatting options"
    echo "[!] or supply the wrong root/EFI/swap partitions."
    echo

    if confirm "Format the root partition before install?"; then
      FORMAT_ROOT=1
    fi

    if confirm "Format the EFI partition before install?"; then
      FORMAT_EFI=1
    fi

    if [[ -n "${SWAP_PART}" ]] && confirm "Recreate the swap signature before install?"; then
      FORMAT_SWAP=1
    fi

    confirm "Proceed with the existing-layout install plan?" || exit 0
  fi

  if [[ "${FORMAT_ROOT}" -eq 1 ]]; then
    echo "[*] Formatting root partition as Btrfs"
    run_root mkfs.btrfs -f "${ROOT_PART}"
  fi

  if [[ "${FORMAT_EFI}" -eq 1 ]]; then
    echo "[*] Formatting EFI partition as FAT32"
    run_root mkfs.fat -F32 "${EFI_PART}"
  fi

  if [[ -n "${SWAP_PART}" && "${FORMAT_SWAP}" -eq 1 ]]; then
    echo "[*] Recreating swap signature"
    run_root mkswap -f "${SWAP_PART}"
  fi

  echo "[*] Ensuring Btrfs subvolumes exist"
  ensure_btrfs_subvolumes "${ROOT_PART}"
}

generate_hardware_config() {
  local target_config="${ROOT_DIR}/hosts/${HOST}/hardware-configuration.nix"

  echo "[*] Generating hardware-configuration.nix"
  run_root nixos-generate-config --root "${MNT}"
  run_root cp "${MNT}/etc/nixos/hardware-configuration.nix" "${target_config}"
  run_root chown "$(id -u):$(id -g)" "${target_config}"

  echo "[*] Updated ${target_config}"
}

copy_repo_into_target() {
  echo "[*] Copying repository into ${MNT}/nixos"
  run_root mkdir -p "${MNT}/nixos"
  run_root cp -a "${ROOT_DIR}/." "${MNT}/nixos"
}

run_nixos_install() {
  local target_flake="path:${MNT}/nixos#${HOST}"
  local cmd=(
    nixos-install
    --flake "${target_flake}"
    --show-trace
  )

  if [[ "${USE_MIRROR}" -eq 1 ]]; then
    cmd+=(--option substituters "${MIRROR} ${FALLBACK_SUBSTITUTER}")
  fi

  echo
  echo "[*] Running nixos-install"
  echo "    Flake: ${target_flake}"
  if [[ "${USE_MIRROR}" -eq 1 ]]; then
    echo "    Mirror: ${MIRROR}"
  else
    echo "    Mirror: disabled"
  fi
  echo
  run_root "${cmd[@]}"
}

handle_install_failure() {
  echo
  echo "[!] nixos-install failed."
  echo "[!] This is often a transient network or cache issue, but the mounted"
  echo "[!] target layout is still present under ${MNT}."
  echo

  if [[ "${ASSUME_YES}" -eq 1 ]]; then
    echo "[*] Non-interactive mode detected. Cleaning up mounts and exiting."
    cleanup_mounts
    return 1
  fi

  while true; do
    local choice
    choice="$(choose_from_list \
      "Choose how to continue:" \
      "retry-install" \
      "cleanup-and-exit" \
      "keep-mounted-and-exit")"

    case "${choice}" in
      retry-install)
        if run_nixos_install; then
          return 0
        fi
        echo
        echo "[!] nixos-install failed again."
        ;;
      cleanup-and-exit)
        cleanup_mounts
        return 1
        ;;
      keep-mounted-and-exit)
        echo "[*] Leaving ${MNT} mounted for manual inspection or retry."
        return 1
        ;;
    esac
  done
}

configure_local_passwords() {
  if [[ "${ASSUME_YES}" -eq 1 ]]; then
    return 0
  fi

  if ! command -v nixos-enter >/dev/null 2>&1; then
    echo "[!] nixos-enter is not available, skipping password setup helper."
    return 0
  fi

  echo
  echo "[*] Password setup"
  echo "[*] SSH keys are already configured for users that define them,"
  echo "[*] but local login and sudo usually still need passwords."
  echo

  if confirm "Set the root password now?"; then
    run_root nixos-enter --root "${MNT}" -c "passwd"
  fi

  for user_name in "${HOST_USERS[@]}"; do
    if confirm "Set the password for user '${user_name}' now?"; then
      run_root nixos-enter --root "${MNT}" -c "passwd ${user_name}"
    fi
  done
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --mode)
      MODE="${2:-}"
      shift 2
      ;;
    --host)
      HOST="${2:-}"
      shift 2
      ;;
    --device)
      DEVICE="${2:-}"
      shift 2
      ;;
    --efi)
      EFI_PART="${2:-}"
      shift 2
      ;;
    --root)
      ROOT_PART="${2:-}"
      shift 2
      ;;
    --swap)
      SWAP_PART="${2:-}"
      shift 2
      ;;
    --swap-size)
      SWAP_SIZE_GIB="${2:-}"
      shift 2
      ;;
    --mnt)
      MNT="${2:-}"
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
    --list-hosts)
      LIST_HOSTS=1
      shift
      ;;
    --format-root)
      FORMAT_ROOT=1
      shift
      ;;
    --format-efi)
      FORMAT_EFI=1
      shift
      ;;
    --format-swap)
      FORMAT_SWAP=1
      shift
      ;;
    --install)
      RUN_INSTALL="yes"
      shift
      ;;
    --no-install)
      RUN_INSTALL="no"
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
  echo "[!] No NixOS hosts found under ${ROOT_DIR}/hosts" >&2
  exit 1
fi

if [[ "${LIST_HOSTS}" -eq 1 ]]; then
  echo "Available NixOS hosts:"
  for host in "${AVAILABLE_HOSTS[@]}"; do
    echo "  - ${host} (hostName: $(read_host_name "${host}"))"
  done
  exit 0
fi

for cmd in parted wipefs dd mkfs.fat mkfs.btrfs mkswap swapon mount umount nixos-generate-config cp grep btrfs blockdev; do
  require_command "${cmd}"
done

if [[ -z "${MODE}" ]]; then
  MODE="$(choose_from_list "Select install mode:" "fresh" "existing")"
fi

if [[ "${MODE}" != "fresh" && "${MODE}" != "existing" ]]; then
  echo "[!] Invalid mode: ${MODE}" >&2
  exit 1
fi

if [[ -z "${HOST}" ]]; then
  HOST="$(choose_from_list "Select a NixOS host:" "${AVAILABLE_HOSTS[@]}")"
fi

if [[ ! -f "${ROOT_DIR}/hosts/${HOST}/meta.nix" ]]; then
  echo "[!] Unknown host: ${HOST}" >&2
  exit 1
fi

HOST_NAME="$(read_host_name "${HOST}")"
while IFS= read -r user_name; do
  [[ -n "${user_name}" ]] && HOST_USERS+=("${user_name}")
done < <(detect_users_for_host "${HOST}")

ensure_empty_mountpoint

if [[ "${MODE}" == "fresh" ]]; then
  prepare_fresh_layout
else
  prepare_existing_layout
fi

mount_layout
generate_hardware_config
copy_repo_into_target

if [[ -z "${RUN_INSTALL}" && "${ASSUME_YES}" -eq 1 ]]; then
  RUN_INSTALL="no"
fi

if [[ -z "${RUN_INSTALL}" ]]; then
  if confirm "Run nixos-install now?"; then
    RUN_INSTALL="yes"
  else
    RUN_INSTALL="no"
  fi
fi

echo
echo "Install summary"
echo "  Mode      : ${MODE}"
echo "  Host      : ${HOST}"
echo "  hostName  : ${HOST_NAME}"
echo "  Root      : ${ROOT_PART}"
echo "  EFI       : ${EFI_PART}"
echo "  Swap      : ${SWAP_PART:-<none>}"
echo "  Mount dir : ${MNT}"
echo "  Flake     : ${FLAKE_PREFIX}#${HOST}"
if [[ "${USE_MIRROR}" -eq 1 ]]; then
  echo "  Mirror    : ${MIRROR}"
else
  echo "  Mirror    : disabled"
fi
if [[ "${#HOST_USERS[@]}" -gt 0 ]]; then
  echo "  Users     : ${HOST_USERS[*]}"
else
  echo "  Users     : <none detected for this host>"
fi
echo
echo "Updated host-local hardware config:"
echo "  ${ROOT_DIR}/hosts/${HOST}/hardware-configuration.nix"
echo "Copied repository into target system:"
echo "  ${MNT}/nixos"
echo "After first boot, the same checkout will be available at:"
echo "  /nixos"
echo
echo "Recommended checks before reboot:"
echo "  1. Review hosts/${HOST}/hardware-configuration.nix"
echo "  2. Confirm the mounted layout under ${MNT}"
echo "  3. Remember that /nixos is the canonical system-side checkout"
echo "  4. Keep using path-based flakes for this repo"
echo

if [[ "${RUN_INSTALL}" == "yes" ]]; then
  if ! run_nixos_install; then
    if ! handle_install_failure; then
      exit 1
    fi
  fi
  configure_local_passwords
  echo
  echo "[*] Installation finished."
  echo "[*] Suggested next steps:"
  echo "    1. Reboot into the installed system"
  echo "    2. Do not expect the desktop session to be ready on the first boot"
  echo "    3. Your graphical session is managed by Home Manager, so SDDM may not"
  echo "       have a usable Hyprland session until user-level config is built"
  echo "    4. Switch to a TTY, for example Ctrl+Alt+F3, and log in there"
  echo "    5. Verify networking, mounts, graphics, and local login"
  echo "    6. If you skipped passwords above, set them with:"
  echo "       sudo passwd"
  if [[ "${#HOST_USERS[@]}" -gt 0 ]]; then
    first_user="${HOST_USERS[0]}"
    echo "       sudo passwd ${first_user}"
  fi
  echo "    7. Run /nixos/rebuild.sh ${HOST} switch"
  if [[ "${#HOST_USERS[@]}" -gt 0 ]]; then
    echo "    8. Run /nixos/rebuild_user.sh"
    echo "    9. Reboot again before expecting the graphical session to work normally"
  else
    echo "    8. Reboot again after any user-level setup is finished"
  fi
else
  echo "[*] nixos-install was skipped."
  echo "[*] Suggested next steps:"
  echo "    1. Review hosts/${HOST}/hardware-configuration.nix"
  echo "    2. Inspect the mounted target under ${MNT}, especially ${MNT}/nixos"
  echo "    3. Run:"
  if [[ "${USE_MIRROR}" -eq 1 ]]; then
    echo "       sudo nixos-install --flake path:${MNT}/nixos#${HOST} --show-trace --option substituters '${MIRROR} ${FALLBACK_SUBSTITUTER}'"
  else
    echo "       sudo nixos-install --flake path:${MNT}/nixos#${HOST} --show-trace"
  fi
  echo "    4. After nixos-install, you can set passwords before reboot with:"
  echo "       sudo nixos-enter --root ${MNT} -c 'passwd'"
  if [[ "${#HOST_USERS[@]}" -gt 0 ]]; then
    echo "       sudo nixos-enter --root ${MNT} -c 'passwd ${HOST_USERS[0]}'"
  fi
fi
