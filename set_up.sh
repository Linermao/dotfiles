#!/usr/bin/env bash
set -euo pipefail

# Select host
echo "[0] Detecting available hosts in ./hosts/..."
host_dirs=()
for d in ./hosts/*/; do
  name=$(basename "$d")
  host_dirs+=("$name")
done

echo "Available hosts:"
select selected_host in "${host_dirs[@]}"; do
  if [[ -n "$selected_host" ]]; then
    echo "You selected: $selected_host"
    break
  else
    echo "Invalid selection."
  fi
done

TARGET_CONFIG="./hosts/$selected_host/hardware-configuration.nix"

# default variable
DEVICE="/dev/nvme0n1"
ESP="${DEVICE}p1"
ROOT="${DEVICE}p2"
SWAP="${DEVICE}p3"
MNT="/mnt"

# clear disk device
echo
echo "[1] ⚠️ You are about to wipe all data and repartition the disk: $DEVICE"
echo "   This will erase all data, including existing systems and files!"

read -rp "ARE YOU SURE TO DO THIS: YES/NO: " confirm1
if [[ "$confirm1" != "YES" ]]; then
  echo "cancel"
  exit 1
fi

read -rp "!!!! ARE YOU SURE TO DO THIS !!!!: YES/NO: " confirm2
if [[ "$confirm2" != "YES" ]]; then
  echo "cancel"
  exit 1
fi

echo "start clear $DEVICE..."
wipefs -a "$DEVICE"
dd if=/dev/zero of="$DEVICE" bs=1M count=10 status=progress

# make gpt
parted "$DEVICE" --script mklabel gpt

# EFI 512MiB
parted "$DEVICE" --script mkpart ESP fat32 1MiB 513MiB
parted "$DEVICE" --script set 1 boot on

# Btrfs root partition
TOTAL_SIZE=$(blockdev --getsize64 "$DEVICE")
SWAP_SIZE=$((32 * 1024 * 1024 * 1024))  # 32GiB
BTRFS_END=$((TOTAL_SIZE - SWAP_SIZE))
BTRFS_END_MiB=$((BTRFS_END / 1024 / 1024))
parted "$DEVICE" --script mkpart primary 513MiB "${BTRFS_END_MiB}MiB"

# Swap
parted "$DEVICE" --script mkpart primary linux-swap "${BTRFS_END_MiB}MiB" 100%

echo
echo "[2] Format partitions..."
mkfs.fat -F32 "$ESP"
mkfs.btrfs -f "$ROOT"
mkswap -f "$SWAP"

echo
echo "[3] Mount and create Btrfs subvolumes..."
mount "$ROOT" "$MNT"
btrfs subvolume create "$MNT/root"
btrfs subvolume create "$MNT/home"
btrfs subvolume create "$MNT/nixos"
umount "$MNT"

echo
echo "[4] Remount all subvolumes for installation..."
mount -o compress=zstd,subvol=root "$ROOT" "$MNT"
mkdir -p "$MNT"/{home,boot,nixos}
mount -o compress=zstd,subvol=home "$ROOT" "$MNT/home"
mount -o compress=zstd,noatime,subvol=nixos "$ROOT" "$MNT/nixos"
mount "$ESP" "$MNT/boot"
swapon "$SWAP"

echo
echo "[5] Generate and Overwriting hardware-configuration.nix with fixed UUIDs..."

nixos-generate-config --root "$MNT"

UUID=$(blkid -s UUID -o value "$ROOT")
SWAP_UUID=$(blkid -s UUID -o value "$SWAP")
ESP_UUID=$(blkid -s UUID -o value "$ESP")

cp "$MNT/etc/nixos/hardware-configuration.nix" "$TARGET_CONFIG"
cp -a . "$MNT/nixos"

# Replace root UUID
sed -i "s|device = \".*\";|device = \"/dev/disk/by-uuid/$UUID\";|g" "$TARGET_CONFIG"
sed -i "s|device = \".*\";|device = \"/dev/disk/by-uuid/$UUID\";|g" "$TARGET_CONFIG"
sed -i "s|device = \".*\";|device = \"/dev/disk/by-uuid/$UUID\";|g" "$TARGET_CONFIG"

# Replace swap UUID
sed -i "s|device = \".*\";|device = \"/dev/disk/by-uuid/$SWAP_UUID\";|g" "$TARGET_CONFIG"

# Replace ESP if needed
sed -i "s|device = \".*\";|device = \"/dev/disk/by-uuid/$ESP_UUID\";|g" "$TARGET_CONFIG"


echo "********************************************"
echo "********************************************"
echo 
echo "[⚠] please manually check if the following files are correct."
echo "     $TARGET_CONFIG"
echo
echo "Please run after the inspection is completed."
echo "     nixos-install --flake .#$selected_host --show-trace"
echo "Then run: "
echo "     ./rebuild_user.sh"
echo 
echo "********************************************"
echo "********************************************"
