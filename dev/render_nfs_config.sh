#!/usr/bin/env bash
# Print the /etc/fstab and /etc/exports lines this host needs for the peer,
# and report whether each is already present.
# Part of klipper-nerdygriffin-macros
set -euo pipefail

# shellcheck source=dev/env.sh
. "$(dirname "$(readlink -f "$0")")/env.sh"

FSTAB_LINE="$PEER_HOST:$PEER_CONFIG_DIR  $PEER_MOUNT  nfs  $NFS_MOUNT_OPTS  0  0"
EXPORT_LINE="$CONFIG_DIR  $PEER_EXPORT_CLIENT($NFS_EXPORT_OPTS)"

status() {
  local file=$1 source=$2 target=$3
  if grep -qsE "^[[:space:]]*${source}[[:space:]]+${target}([[:space:](]|\$)" "$file"; then
    echo "present"
  else
    echo "MISSING"
  fi
}

echo "[render_nfs_config] Host: $LOCAL_HOST  Peer: $PEER_HOST"

printf "\n/etc/fstab (%s):\n" "$(status /etc/fstab "$PEER_HOST:$PEER_CONFIG_DIR" "$PEER_MOUNT")"
echo "$FSTAB_LINE"

printf "\n/etc/exports (%s):\n" "$(status /etc/exports "$CONFIG_DIR" "$PEER_EXPORT_CLIENT")"
echo "$EXPORT_LINE"

cat <<HELP

Apply:
  sudo mkdir -pv $PEER_MOUNT
  sudo systemctl daemon-reload && sudo mount -av
  sudo exportfs -ra && sudo exportfs -v
HELP
