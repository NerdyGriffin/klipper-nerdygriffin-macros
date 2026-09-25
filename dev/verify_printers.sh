#!/usr/bin/env bash
# Validate local paths, the peer NFS mount, and write access to it.
# Part of klipper-nerdygriffin-macros
set -euo pipefail

# shellcheck source=dev/env.sh
. "$(dirname "$(readlink -f "$0")")/env.sh"

echo "[verify_printers] Host: $LOCAL_HOST  Peer: $PEER_HOST"

printf "\nNFS mounts under %s:\n" "$MOUNT_ROOT"
nfs_mounts_under "$MOUNT_ROOT" | grep . || echo "No NFS mounts found"

printf "\nLocal config:\n"
if [[ -f "$CONFIG_DIR/printer.cfg" ]]; then
  echo "OK  $CONFIG_DIR/printer.cfg"
  head -3 "$CONFIG_DIR/printer.cfg" || true
else
  echo "MISSING  $CONFIG_DIR/printer.cfg"
fi

printf "\nPeer config (%s):\n" "$PEER_HOST"
if [[ -f "$PEER_MOUNT/printer.cfg" ]]; then
  echo "OK  $PEER_MOUNT/printer.cfg"
  head -3 "$PEER_MOUNT/printer.cfg" || true
else
  echo "MISSING or not mounted  $PEER_MOUNT/printer.cfg"
fi

printf "\nLocal macros:\n"
if [[ -d "$MACROS_DIR/macros" ]]; then
  echo "OK  $MACROS_DIR"
  ls "$MACROS_DIR/macros" | head -3 || true
else
  echo "MISSING  $MACROS_DIR"
fi

printf "\nPeer config write test:\n"
if [[ -d "$PEER_MOUNT" ]]; then
  if touch "$PEER_MOUNT/.nfs-test-write" 2>/dev/null; then
    rm -f "$PEER_MOUNT/.nfs-test-write"
    echo "OK  $PEER_MOUNT is writable"
  else
    echo "FAIL  $PEER_MOUNT is not writable"
  fi
else
  echo "FAIL  $PEER_MOUNT is not accessible"
fi

printf "\n[Done]\n"
