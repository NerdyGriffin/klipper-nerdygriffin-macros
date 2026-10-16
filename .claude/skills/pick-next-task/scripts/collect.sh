#!/usr/bin/env bash
# Print every TODO.md and every open GitHub issue across the printer repos.
# Output is plain text meant to be read by the agent; nothing is parsed downstream.
set -u

REPOS=(
  "Klipper-Config-VT1548|$HOME/printer_data/config"
  "klipper-nerdygriffin-macros|$HOME/klipper-nerdygriffin-macros"
  "Klipper-Config-V03048|/mnt/v0-3048/printer_data/config"
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
    echo "-- path not present (peer config not mounted?)"
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
