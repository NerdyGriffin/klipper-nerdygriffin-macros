# Development Tools

Helper scripts for the two-printer development workflow: each printer NFS-mounts the other's
config directory, and the macros repo is kept in sync on both hosts with git.

## Setup

Every script sources [env.sh](env.sh), which loads host-specific values from `dev/.env`
(git-ignored). On each host:

```bash
cp dev/.env.example dev/.env
$EDITOR dev/.env   # at minimum, set PEER_HOST
```

`PEER_HOST` is the other printer's hostname. It becomes the fstab source, the mount point
`/mnt/<PEER_HOST>/printer_data/config`, and the SSH target unless `PEER_SSH` overrides it.
See [.env.example](.env.example) for every setting and its default.

## Scripts

| Script                  | Purpose                                                                    |
| ----------------------- | -------------------------------------------------------------------------- |
| `render_nfs_config.sh`  | Print the `/etc/fstab` and `/etc/exports` lines this host needs            |
| `mount_printers.sh`     | Create the mount point, reload systemd, `mount -a`, show the result        |
| `umount_printers.sh`    | Unmount every NFS mount under `MOUNT_ROOT`                                 |
| `verify_printers.sh`    | Check local paths, the peer mount, and write access to it                  |
| `sync_macros_repo.sh`   | `git push` local commits, then `git pull` locally and on the peer over SSH |
| `sync_all.sh`           | Mount, sync macros (optionally a branch), then verify                      |
| `sync_claude_memory.sh` | Replicate the Claude Code auto-memory dir between hosts (git, cron, hooks) |
| `setup.sh`              | Developer toolchain: Node, markdownlint, and the git pre-commit hook       |

## NFS setup

Run once per host, after `dev/.env` is in place.

1. Install packages: `sudo apt-get install -y nfs-kernel-server nfs-common`
2. Run `dev/render_nfs_config.sh` and add the printed lines to `/etc/fstab` and `/etc/exports`.
3. Apply:

   ```bash
   sudo exportfs -ra
   sudo systemctl enable --now nfs-kernel-server
   dev/mount_printers.sh
   dev/verify_printers.sh
   ```

The default mount options use `x-systemd.automount` so the mount is created on first access, and
`soft` so that reads fail with an error instead of hanging when the peer is offline. Without
`soft`, VS Code Remote-SSH stalls indefinitely on a workspace that includes the mounted folder.

The peer must resolve by name on both hosts (`/etc/hosts`, mDNS, or DNS). If it does not, set
`PEER_SSH` and `PEER_EXPORT_CLIENT` to its address in `dev/.env`.

## Daily workflow

```bash
dev/sync_macros_repo.sh              # push local commits, pull on both hosts
dev/sync_macros_repo.sh my-branch    # check out and pull a branch on both hosts
dev/sync_all.sh                      # mount, sync, verify
```

Edit shared macros only in the local clone, never through the peer's NFS mount. Edit the peer's
printer config through the mount as needed.

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

- Never point Klipper at a config directory mounted from the other printer.
- Do not edit the same file on both hosts at once. Commit before switching hosts.
- `dev/copilot/` is git-ignored scratch space for AI session notes.
