# Rename Existing (rename_existing.cfg)

The `rename_existing.cfg` safely overrides Klipper built-in commands by renaming them and providing wrapper macros. This allows plugins to hook into standard G-code commands without conflicts.

## Affected Commands

| Macro | Purpose |
|----------|----------|
| `M0` | Alias for Marlin-style "Unconditional stop" |
| `M205` | Alias for Marlin-style "Set Advanced Settings" |
| `M226` | Alias for Marlin-style "Wait for Pin State" |
| `M109` | Add `STATUS_HEATING` support |
| `M190` | Add `STATUS_HEATING` support |
| `M117` | Display message to both LCD and console |

> **Note**:
>
> This file is automatically included and requires no additional configuration. All original commands remain available with underscore prefix if you need to call them directly.
