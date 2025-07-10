#!/usr/bin/env sh

# ******* this will erase all data *******
wipefs -a /dev/nvme0n1
dd if=/dev/zero of=/dev/nvme0n1 bs=1M count=10 status=progress

parted /dev/nvme0n1 --script mklabel gpt

# EFI 512MB，fat32
parted /dev/nvme0n1 --script mkpart ESP fat32 1MiB 513MiB
parted /dev/nvme0n1 --script set 1 boot on

# btrfs 513MiB (total - 32GiB)
TOTAL_SIZE=$(blockdev --getsize64 /dev/nvme0n1)
SWAP_SIZE=34359738368   # 32 * 1024^3 bytes
BTRFS_END=$((TOTAL_SIZE - SWAP_SIZE))
BTRFS_END_MiB=$((BTRFS_END / 1024 / 1024))

parted /dev/nvme0n1 --script mkpart primary 513MiB ${BTRFS_END_MiB}MiB

# swap 32GB
parted /dev/nvme0n1 --script mkpart primary linux-swap ${BTRFS_END_MiB}MiB 100%

# mk EFI as FAT32
mkfs.fat -F 32 /dev/nvme0n1p1

# mk Btrfs as home
mkfs.btrfs -f /dev/nvme0n1p2

# mk swap
mkswap -f /dev/nvme0n1p3

# mount home to /mnt
mount /dev/nvme0n1p2 /mnt

# make subvolume
btrfs subvolume create /mnt/root
btrfs subvolume create /mnt/home
btrfs subvolume create /mnt/nixos

# for mount children
umount /mnt

mount -o compress=zstd,subvol=root /dev/nvme0n1p2 /mnt

mkdir -p /mnt/{home,nixos,boot}

# mount children
mount -o compress=zstd,subvol=home /dev/nvme0n1p2 /mnt/home
mount -o compress=zstd,noatime,subvol=nixos /dev/nvme0n1p2 /mnt/nixos
mount /dev/nvme0n1p1 /mnt/boot

# make swapon
swapon /dev/nvme0n1p3

# generate hardware-configuration
nixos-generate-config --root /mnt

# change this path to nixos/
cp /mnt/etc/nixos/hardware-configuration.nix ./hosts/desktop/hardware-configuration.nix

# copy current configuration to mnt
cp ./* /mnt/nixos/

# install nixos using flake
nixos-install --flake .#desktop --root /mnt --show-trace --option substituters https://mirror.sjtu.edu.cn/nix-channels/store
