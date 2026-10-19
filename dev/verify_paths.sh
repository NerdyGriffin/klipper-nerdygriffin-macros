#!/usr/bin/env bash
# Validate the local config, the local macros repo, the KlipperScreen add-on, and the peer config clone.
# Part of klipper-nerdygriffin-macros
set -euo pipefail

# shellcheck source=dev/env.sh
. "$(dirname "$(readlink -f "$0")")/env.sh"

echo "[verify_paths] Host: $LOCAL_HOST  Peer: $PEER_HOST"

printf "\nLocal config:\n"
if [[ -f "$CONFIG_DIR/printer.cfg" ]]; then
  echo "OK  $CONFIG_DIR/printer.cfg"
  head -3 "$CONFIG_DIR/printer.cfg" || true
else
  echo "MISSING  $CONFIG_DIR/printer.cfg"
fi

printf "\nLocal macros:\n"
if [[ -d "$MACROS_DIR/macros" ]]; then
  echo "OK  $MACROS_DIR"
  ls "$MACROS_DIR/macros" | head -3 || true
else
  echo "MISSING  $MACROS_DIR"
fi

printf "\nKlipperScreen add-on:\n"
if [[ -d "$ADDON_DIR/.git" ]]; then
  echo "OK  $ADDON_DIR"
  git -C "$ADDON_DIR" log -1 --format='    %h %s'
  if [[ -L "$HOME/KlipperScreen/addons/nevermore.py" ]]; then
    echo "OK  ~/KlipperScreen/addons/nevermore.py -> $(readlink "$HOME/KlipperScreen/addons/nevermore.py")"
  else
    echo "WARN  not linked into ~/KlipperScreen/addons (run $ADDON_DIR/install.sh)"
  fi
else
  echo "MISSING  $ADDON_DIR (optional)"
fi

printf "\nPeer config clone (%s):\n" "$PEER_HOST"
if [[ -d "$PEER_CONFIG_CLONE/.git" ]]; then
  echo "OK  $PEER_CONFIG_CLONE"
  git -C "$PEER_CONFIG_CLONE" log -1 --format='    %h %s'
  git -C "$PEER_CONFIG_CLONE" status --short --branch
  behind=$(git -C "$PEER_CONFIG_CLONE" rev-list --count 'HEAD..@{upstream}' 2>/dev/null || echo 0)
  if [[ "$behind" -gt 0 ]]; then
    echo "WARN  $behind commit(s) behind upstream (last fetch); run dev/sync_peer_config.sh"
  fi
  [[ -f "$PEER_CONFIG_CLONE/printer.cfg" ]] || echo "WARN  no printer.cfg in the clone"
else
  echo "MISSING  $PEER_CONFIG_CLONE (run dev/sync_peer_config.sh)"
fi

printf "\n[Done]\n"
