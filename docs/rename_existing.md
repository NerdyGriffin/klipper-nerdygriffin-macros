# Rename Existing (rename_existing.cfg)

The `rename_existing.cfg` safely overrides Klipper built-in commands by renaming them and providing wrapper macros. This allows plugins to hook into standard G-code commands without conflicts.

## Affected Commands

| Macro | Purpose |
|----------|----------|
| `M0` | Alias for Marlin-style "Unconditional stop" |
| `M18` | Turn off motors and set `STATUS_OFF` |
| `M84` | Turn off motors and set `STATUS_OFF` (alias for `M18`) |
| `M205` | Alias for Marlin-style "Set Advanced Settings" |
| `M226` | Alias for Marlin-style "Wait for Pin State" |
| `M109` | Add support for `STATUS_MACROS` and `SET_DISPLAY_TEXT` |
| `M190` | Add support for `STATUS_MACROS` and `SET_DISPLAY_TEXT` |
| `SET_HEATER_TEMPERATURE` | Add support for `STATUS_MACROS` and `SET_DISPLAY_TEXT` |
| `TURN_OFF_HEATERS` | Add support for `STATUS_MACROS` |
| `M117` | Override the default M117 command to echo the message to the console. |

> **Note**:
>
> This file is automatically included and requires no additional configuration. All original commands remain available with underscore prefix if you need to call them directly.
