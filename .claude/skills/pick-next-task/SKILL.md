---
name: pick-next-task
description: Read every TODO.md and every open GitHub issue across the printer repos (this config, the shared klipper-nerdygriffin-macros repo, and the peer printer's config when its NFS mount is present), then recommend exactly one item to work on next, with the reasoning and a concrete first step. Use this whenever the user asks what to work on, what's next, what to pick up, what's on the backlog, what's outstanding, "what should we do today", or wants help choosing between open items — even if they don't say "TODO" or "issue". Also use it when they ask to review or triage the TODO list or issues.
---

# Pick the next task

The goal is a decision, not a catalogue. The user already knows the backlog exists; what
they want is one well-argued pick so they can start working instead of re-reading lists.

## 1. Collect the candidates

Run the bundled collector from the skill directory:

```bash
bash scripts/collect.sh
```

It prints, for each repo it knows about, the contents of `TODO.md` (if present) and the
open GitHub issues. Issues come from `gh` when it is authenticated and fall back to the
unauthenticated public API otherwise, since the `gh` token on these hosts lapses from
time to time and the repos are public. The script never fails silently: a missing file,
an unmounted peer config, or an API error is printed as such, so you can tell "no
TODO.md" apart from "couldn't read it".

Repos covered, in this order:

| Repo | Local path | Why it matters |
| --- | --- | --- |
| Klipper-Config-VT1548 | `$CONFIG_DIR` (default `~/printer_data/config`) | this printer |
| klipper-nerdygriffin-macros | `$MACROS_DIR` (default `~/klipper-nerdygriffin-macros`) | shared by both printers |
| Klipper-Config-V03048 | `$PEER_MOUNT` (default `/mnt/$PEER_HOST/printer_data/config`) | the V0, mounted over NFS |

The paths and the peer hostname come from the git-ignored `dev/.env`, loaded via
`dev/env.sh`; the collector prints `PEER_HOST=...` on its first line. The repo is public,
so never write a real hostname into this file or the collector.

Read `TODO.md` entirely; it may use headings, checkboxes, or free prose. Items under a
"done" heading or with `[x]` are not candidates. The script searches three levels deep so
it also finds files in unusual places (the macros repo keeps its list at
`docs/dev/TODO.md`) and lowercase `todo.md` variants.

If the collector finds nothing at all, say so plainly in the first line, then fall back to
`grep -rn -i 'TODO\|FIXME\|XXX'` over the `.cfg` and `.md` files (skipping `deprecated/`
and symlinked directories), and treat those markers as the candidate list. Only if that is
empty too should the answer be "there is no recorded backlog", followed by an offer to
start one.

## 2. Check what the printers are doing

A recommendation that cannot be acted on right now is useless, so before ranking, ask
Moonraker whether either printer is busy:

```bash
. dev/env.sh   # sets PEER_HOST from dev/.env
curl -s localhost:7125/printer/objects/query?print_stats | python3 -I -c 'import json,sys; print(json.load(sys.stdin)["result"]["status"]["print_stats"]["state"])'
curl -s "http://$PEER_HOST:7125/printer/objects/query?print_stats" | python3 -I -c 'import json,sys; print(json.load(sys.stdin)["result"]["status"]["print_stats"]["state"])'
```

If a printer is `printing` or `paused`, anything that needs a `FIRMWARE_RESTART` on that
machine or moves the toolhead drops to the bottom of the ranking for today. Documentation,
shared-macro refactors that can be tested on the idle printer, and investigation tasks
stay eligible.

## 3. Rank

Weigh each candidate on these, roughly in order:

- **Safety and blast radius.** Does it touch homing, probing, heaters, or the AFC load
  path? Those need a free printer and the user at the machine. Things confined to a
  single macro or to docs are cheap to try and cheap to revert.
- **Is it blocked?** Hardware that is not built yet (the BoxTurtle), parts on order, or
  an upstream fix not yet released. Blocked items are mentioned, not recommended.
- **Is it already half done?** Check `git log --oneline -15` in the relevant repo and
  `git status`. Recent commits or an unfinished branch that touch the same area make an
  item the natural continuation, and finishing beats starting. The same check sometimes
  shows an item is already finished but never ticked off; list those under "Scanned" as
  stale so the user can close them, rather than recommending them.
- **Do its references still exist?** TODO entries point at files and paths that move.
  Verify the ones the top pick depends on; a missing reference belongs in the
  recommendation so the user is not surprised at step one.
- **Can it be verified today?** Prefer work with a clear success test (a macro that can be
  run from the console, a sensor that can be queried) over open-ended tuning.
- **Shared vs local.** A fix in `klipper-nerdygriffin-macros` benefits both printers but
  needs the push / sync / restart dance on both hosts (see `AGENTS.md`). Note that cost;
  it is not a reason to avoid it.

Do not rank by how long an item has been on the list. Age is only a tiebreak.

## 4. Answer

Keep it under about 250 words. Use this shape:

```text
**Recommendation:** <one item, named the way the source names it> (<where it came from: TODO.md section, or repo#issue>)

<Two to four sentences: why this one now. Mention printer state if it affected the pick.>

**First step:** <the single concrete action to begin with, e.g. the file to open or the command to run>

**Runners-up:**
- <item> — <one clause on why not first>
- <item> — <one clause on why not first>

**Scanned:** <which TODO.md files existed, how many open issues per repo, anything that could not be read, items that look stale or blocked>
```

The "Scanned" line matters: when the recommendation comes from a thin backlog the user
should see that it was thin, not assume a rich list was weighed. Include blocked items
there too, in one line, so they are not forgotten.

Then stop. Do not start the work; the user will say "go" or pick something else.
Starting unasked turns a recommendation into a commitment the user did not make.

## Examples

**Input:** `/pick-next-task`, with `TODO.md` listing "tune encoder detection_length",
"document the Nevermore vent macros", and "re-enable switch_sensor pause", and no open
issues; VT-1548 is printing.

**Output:** recommends documenting the Nevermore vent macros (no restart needed, verifiable
by reading), names the encoder tuning as the runner-up for when the print finishes, and
flags the switch_sensor pause as something `AGENTS.md` warns about, so it needs a design
discussion before any edit.

**Input:** "what should we work on next?", no `TODO.md` anywhere, one open issue on
klipper-nerdygriffin-macros about `PRINT_END` parking.

**Output:** states in the first line that no `TODO.md` exists, recommends the issue, and
notes it is a shared-macro change that will need syncing to both hosts.
