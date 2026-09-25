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
| `sync_macros_repo.sh`   | `git pull` the macros repo locally and on the peer over SSH                |
| `sync_all.sh`           | Mount, sync macros (optionally a branch), then verify                      |
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
dev/sync_macros_repo.sh              # pull the macros repo on both hosts
dev/sync_macros_repo.sh my-branch    # check out and pull a branch on both hosts
dev/sync_all.sh                      # mount, sync, verify
```

Edit shared macros only in the local clone, never through the peer's NFS mount. Edit the peer's
printer config through the mount as needed.

## Safety notes

- Never point Klipper at a config directory mounted from the other printer.
- Do not edit the same file on both hosts at once. Commit before switching hosts.
- `dev/copilot/` is git-ignored scratch space for AI session notes.
