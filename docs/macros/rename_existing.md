# Rename Existing (rename_existing.cfg)

The `rename_existing.cfg` safely overrides Klipper built-in commands by renaming them and providing wrapper macros. This allows plugins to hook into standard G-code commands without conflicts.

## Affected Commands

- `M109` (Set extruder temp and wait) → wrapped by extruder temp macro
- `M190` (Set bed temp and wait) → wrapped by bed temp macro
- `M117` (Display message) → wrapped for compatibility
- `G28` (Home all axes) → wrapped by conditional homing

**Note:** All original commands remain available with underscore prefix (e.g., `_G28`, `_M109`).
