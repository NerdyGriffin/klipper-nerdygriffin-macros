# Client Macros (client_macros.cfg)

The client macros provide integration with Mainsail/Fluidd pause/resume/cancel operations, automatically handling filament sensors and optional AFC (Automated Filament Control) features.

## Usage

To enable client macro hooks, add the following `_CLIENT_VARIABLE` configuration to your `printer.cfg`:

```ini
[gcode_macro _CLIENT_VARIABLE]
variable_park_at_cancel   : True
variable_user_pause_macro : "_AFTER_PAUSE"    # Hook to plugin macro
variable_user_resume_macro: "_BEFORE_RESUME"  # Hook to plugin macro
variable_user_cancel_macro: "_BEFORE_CANCEL"  # Hook to plugin macro
```

The hook macros automatically handle:
- Filament sensor management (enabling/disabling as needed)
- Optional AFC (Automated Filament Control) integration
- Safe state transitions during pause/resume/cancel operations

> **Note**:
>
> See [mainsail.cfg](https://github.com/mainsail-crew/mainsail-config/blob/master/client.cfg) for all available `_CLIENT_VARIABLE` options and more advanced customization.

## Internal Macros

These macros are triggered automatically by print lifecycle events and should not be called directly:

- `_AFTER_PAUSE` - Triggered by Mainsail/Fluidd PAUSE command
- `_BEFORE_RESUME` - Triggered by Mainsail/Fluidd RESUME command
- `_BEFORE_CANCEL` - Triggered by Mainsail/Fluidd CANCEL_PRINT command
