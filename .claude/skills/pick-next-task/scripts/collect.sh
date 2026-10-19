#!/usr/bin/env bash
# Print every TODO.md and every open GitHub issue across the printer repos.
# Output is plain text meant to be read by the agent; nothing is parsed downstream.
set -u

# Host-specific values (peer hostname, peer repo, paths) come from the
# git-ignored dev/.env, loaded through dev/env.sh. This repo is public, so
# no hostname may appear in this file.
SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPO_DIR="$(cd "$SKILL_DIR/../../.." && pwd)"
if ! . "$REPO_DIR/dev/env.sh"; then
  echo "-- dev/env.sh could not be loaded (is dev/.env in place with PEER_HOST set?)."
  echo "-- Continuing with local repos only; the peer config will be skipped."
  PEER_HOST=""
  PEER_CONFIG_CLONE="/nonexistent"
  CONFIG_DIR="${CONFIG_DIR:-$HOME/printer_data/config}"
  MACROS_DIR="${MACROS_DIR:-$HOME/klipper-nerdygriffin-macros}"
fi

echo "PEER_HOST=${PEER_HOST:-<unset>}   (use http://\$PEER_HOST:7125 for the peer's Moonraker)"
echo

# GitHub repo name from each clone's origin URL, so the labels are right on
# either host (the local config and the peer clone swap between printers).
repo_name() {
  local url
  url=$(git -C "$1" remote get-url origin 2>/dev/null) || url="$1"
  basename "$url" .git
}
REPOS=(
  "$(repo_name "$CONFIG_DIR")|$CONFIG_DIR"
  "$(repo_name "$MACROS_DIR")|$MACROS_DIR"
  "$(basename "${PEER_CONFIG_REPO:-$PEER_CONFIG_CLONE}" .git)|$PEER_CONFIG_CLONE"
)
OWNER=NerdyGriffin

gh_ok=0
if command -v gh >/dev/null 2>&1 && gh auth status >/dev/null 2>&1; then
  gh_ok=1
fi

for entry in "${REPOS[@]}"; do
  name="${entry%%|*}"
  path="${entry##*|}"
  echo "=================================================================="
  echo "REPO: $name  ($path)"
  echo "=================================================================="

  if [ ! -d "$path" ]; then
    echo "-- path not present (peer clone missing? run dev/sync_peer_config.sh)"
  else
    # TODO.md in the repo root or up to two levels down, any case; skip symlinked dirs and git internals.
    mapfile -t todos < <(find "$path" -maxdepth 3 -type f -iname 'todo.md' -not -path '*/.git/*' 2>/dev/null)
    if [ "${#todos[@]}" -eq 0 ]; then
      echo "-- no TODO.md found"
    else
      for f in "${todos[@]}"; do
        echo "-- TODO file: $f"
        cat "$f"
        echo
      done
    fi
  fi

  echo "-- open issues on $OWNER/$name:"
  if [ "$gh_ok" -eq 1 ]; then
    gh issue list --repo "$OWNER/$name" --state open --limit 100 \
      --json number,title,labels,updatedAt,body \
      --template '{{range .}}#{{.number}} {{.title}} [{{range .labels}}{{.name}} {{end}}] updated {{.updatedAt}}{{"\n"}}{{.body}}{{"\n\n"}}{{end}}' \
      || echo "   (gh failed; see above)"
  else
    echo "   (gh not authenticated; using public API)"
    curl -sf "https://api.github.com/repos/$OWNER/$name/issues?state=open&per_page=100" \
      | python3 -I -c '
import json, sys
d = json.load(sys.stdin)
if not isinstance(d, list):
    print("   API error:", d.get("message")); sys.exit(0)
d = [i for i in d if "pull_request" not in i]
if not d:
    print("   none")
for i in d:
    labels = " ".join(l["name"] for l in i.get("labels", []))
    print(f"#{i['number']} {i['title']} [{labels}] updated {i['updated_at']}")
    body = (i.get("body") or "").strip()
    if body:
        print(body)
    print()
' || echo "   (request failed)"
  fi
  echo
done
