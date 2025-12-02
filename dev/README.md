Development helper scripts for mounting and verifying cross-printer NFS setup.

Scripts:
- mount_printers.sh: Mount all printers paths per /etc/fstab and show status
- umount_printers.sh: Safely unmount all printer paths
- verify_printers.sh: Validate directory structure, mounts, and permissions
 - sync_macros_repo.sh: Git pull macros repo locally and on VT-1548 over SSH
 - cleanup_legacy_mounts.sh: Remove old flat mount points and leftover dirs
 - sync_all.sh: Mount, sync macros (optionally a branch), then verify in one go
 - toggle_macros_ro.sh: Remount local macros bind as read-only or read-write

Usage:
- Run directly on each host (V0-3048, VT-1548)
- These scripts use the nested paths under /home/pi/printers/

 Examples:
 - Mount + verify:
	 ./mount_printers.sh && ./verify_printers.sh
 - Sync macros on both hosts (current branch):
	 ./sync_macros_repo.sh
 - Sync a specific branch (e.g., main):
	 ./sync_macros_repo.sh main
 - All-in-one (mount, sync, verify):
	 ./sync_all.sh
 - Temporarily make local macros read-only (safety):
	 ./toggle_macros_ro.sh ro
	 ./toggle_macros_ro.sh rw
 - Cleanup old paths:
	 ./cleanup_legacy_mounts.sh
