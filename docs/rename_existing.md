# Rename Existing (rename_existing.cfg)

The `rename_existing.cfg` safely overrides Klipper built-in commands by renaming them and providing wrapper macros. This allows plugins to hook into standard G-code commands without conflicts.

## Affected Commands

| Original | Renamed To | Purpose |
|----------|------------|---------|
| `M109` | `_M109` | Set extruder temp and wait |
| `M190` | `_M190` | Set bed temp and wait |
| `M117` | `_M117` | Display message to both LCD and console |
| `G28` | `_G28` | Home all axes |

> **Note**:
>
> This file is automatically included and requires no additional configuration. All original commands remain available with underscore prefix if you need to call them directly.
