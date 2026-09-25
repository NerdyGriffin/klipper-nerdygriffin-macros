#!/usr/bin/env bash
# Unmount every NFS mount under MOUNT_ROOT.
# Part of klipper-nerdygriffin-macros
set -euo pipefail

# shellcheck source=dev/env.sh
. "$(dirname "$(readlink -f "$0")")/env.sh"

echo "[umount_printers] Host: $LOCAL_HOST"
echo "Unmounting NFS mounts under $MOUNT_ROOT ..."

mapfile -t MOUNTS < <(nfs_mounts_under "$MOUNT_ROOT" | awk '{print $1}')

if [[ ${#MOUNTS[@]} -eq 0 ]]; then
  echo "No NFS mounts found under $MOUNT_ROOT"
else
  for dir in "${MOUNTS[@]}"; do
    sudo umount -v "$dir" || echo "WARN: Failed to unmount $dir"
  done
fi

printf "\nRemaining mounts:\n"
nfs_mounts_under "$MOUNT_ROOT" | grep . || echo "None"
printf "\n[Done]\n"
