# Development Tools

Helper scripts for the two-printer development workflow: each host keeps a read-only git clone of
the other printer's config for cross-referencing, and the macros repo is kept in sync on both hosts
with git.

## Setup

Every script sources [env.sh](env.sh), which loads host-specific values from `dev/.env`
(git-ignored). On each host:

```bash
cp dev/.env.example dev/.env
$EDITOR dev/.env   # at minimum, set PEER_HOST and PEER_CONFIG_REPO
```

`PEER_HOST` is the other printer's hostname; it is the SSH target unless `PEER_SSH` overrides it.
`PEER_CONFIG_REPO` is the git URL of the other printer's config repo, cloned to
`PEER_CONFIG_CLONE` (default `~/<repo name>`). See [.env.example](.env.example) for every setting
and its default.

## Scripts

| Script                  | Purpose                                                                    |
| ----------------------- | -------------------------------------------------------------------------- |
| `sync_peer_config.sh`   | Clone the peer's config repo, or `git pull --ff-only` the existing clone   |
| `verify_paths.sh`       | Check the local config, the local macros repo, and the peer config clone   |
| `sync_macros_repo.sh`   | `git push` local commits, then `git pull` locally and on the peer over SSH |
| `sync_all.sh`           | Refresh the peer clone, sync macros (optionally a branch), then verify     |
| `sync_claude_memory.sh` | Replicate the Claude Code auto-memory dir between hosts (git, cron, hooks) |
| `setup.sh`              | Developer toolchain: Node, markdownlint, and the git pre-commit hook       |

## Peer config clone

Run once per host, after `dev/.env` is in place:

```bash
dev/sync_peer_config.sh
dev/verify_paths.sh
```

The clone is a reference copy for reading and searching the other printer's config alongside this
one; add it as a folder in the VS Code workspace. It only shows what the peer has pushed, so the
peer's live `SAVE_CONFIG` block and any uncommitted edits there are not visible. Earlier versions
of these scripts NFS-mounted the peer config instead; that was dropped because an offline peer
stalled VS Code Remote-SSH on every access to the mount.

## Daily workflow

```bash
dev/sync_macros_repo.sh              # push local commits, pull on both hosts
dev/sync_macros_repo.sh my-branch    # check out and pull a branch on both hosts
dev/sync_peer_config.sh              # pull the peer's latest config commits
dev/sync_all.sh                      # refresh peer clone, sync macros, verify
```

Edit shared macros only in the local macros clone. Edit the peer's printer config on the peer host
(Remote-SSH) and push; the local clone is read-only and `sync_peer_config.sh` refuses to pull over
local changes.

## Claude memory sync

`sync_claude_memory.sh` keeps `~/.claude/projects/<slug>/memory/` (Claude Code's per-project
auto-memory: one fact per `.md` file plus the `MEMORY.md` index) identical on both hosts. Both
printers open the same config path, so the slug matches and a fact learned on one printer is
available on the other.

How it works:

- Each memory directory gets a detached git dir at `~/.claude/memory-sync/<slug>.git`. Nothing but
  memory files lives in the memory directory itself.
- Every run commits local changes, then fetches and merges the peer's repo over SSH
  (`ssh://$PEER_SSH/...`). Nobody pushes; the peer merges on its own run, so both hosts converge
  within two cycles. An unreachable peer is logged and skipped.
- `MEMORY.md` merges by line union, so index lines added on both hosts both survive. Any other file
  edited on both hosts between runs resolves in the peer's favour; the local version stays in git
  history (`git --git-dir ~/.claude/memory-sync/<slug>.git log -p -- <file>` recovers it).
- Log: `~/.claude/memory-sync/sync.log`.

Setup, once per host:

```bash
dev/sync_claude_memory.sh                 # first run: initialise, commit, merge peer
dev/sync_claude_memory.sh --install-cron  # every 5 minutes
dev/sync_claude_memory.sh --status        # HEAD, pending changes, recent log, cron line
```

Add `SessionStart` and `SessionEnd` hooks in `~/.claude/settings.json` that run
`dev/sync_claude_memory.sh --quiet` (with a 30 s timeout) so a session pulls on open and pushes on
close; cron remains the safety net.

## Safety notes

- Never point Klipper at the peer config clone.
- Do not edit the same file on both hosts at once. Commit before switching hosts.
- `dev/copilot/` is git-ignored scratch space for AI session notes.
