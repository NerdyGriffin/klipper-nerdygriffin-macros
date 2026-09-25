#!/usr/bin/env bash
# Mount the peer printer's config per /etc/fstab and show the result.
# Part of klipper-nerdygriffin-macros
set -euo pipefail

# shellcheck source=dev/env.sh
. "$(dirname "$(readlink -f "$0")")/env.sh"

echo "[mount_printers] Host: $LOCAL_HOST  Peer: $PEER_HOST"

echo "Creating mount point: $PEER_MOUNT"
sudo mkdir -pv "$PEER_MOUNT"

echo "Reloading systemd and mounting all (per /etc/fstab) ..."
sudo systemctl daemon-reload
sudo mount -av || true

printf "\nMounted paths under %s:\n" "$MOUNT_ROOT"
nfs_mounts_under "$MOUNT_ROOT" | grep . || echo "No NFS mounts found under $MOUNT_ROOT"

printf "\nVerifying peer config access:\n"
PEER_CFG="$PEER_MOUNT/printer.cfg"
if [[ -f "$PEER_CFG" ]]; then
  echo "OK  $PEER_CFG"
  head -3 "$PEER_CFG" || true
else
  echo "MISSING  $PEER_CFG"
fi

printf "\n[Done]\n"
