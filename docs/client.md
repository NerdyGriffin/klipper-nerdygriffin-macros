# Client Macros (client.cfg)

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
- Prolonged-pause hotend standby (see below)

## Prolonged-pause hotend standby

`_AFTER_PAUSE` arms a `[delayed_gcode NOZZLE_STANDBY_COOLDOWN]` on every pause. If the pause
outlasts the normal idle timeout, the hotend is dropped to a **standby** temperature instead of
being held at full print temp (which slowly cooks the filament parked in the nozzle). This matters
most with AFC error pauses, where AFC extends `idle_timeout` to `error_timeout` (10 h) — so the
stock idle_timeout would otherwise leave the hotend hot for hours.

- **Standby temperature:** `standby_extruder` from `print_macros.cfg` (`PRINT_START`), defaulting to
  150 °C if `print_macros.cfg` is not included.
- **Restore on resume:** the pre-pause target is preserved by stock PAUSE in
  `RESUME.last_extruder_temp`; the cooldown sets `RESUME` `idle_state=True` so stock RESUME reheats to
  it before resuming. `LOAD_FILAMENT`/`UNLOAD_FILAMENT` and AFC `TOOL_LOAD`/`TOOL_UNLOAD` also reheat
  from standby on their own.
- **Full-off backstop:** unchanged — the (AFC-extended) `idle_timeout` still turns the hotend fully
  off when it eventually fires.
- **Timing:** the timer fires ~30 s before the configured idle timeout so it wins deterministically;
  for a normal pause the stock idle_timeout follows shortly after and takes the hotend fully off.

`idle_timeout.cfg` optionally cancels this timer when it fires (guarded on `_AFTER_PAUSE` being
defined), so the two never fight. See [DEPENDENCIES.md](DEPENDENCIES.md) for the coupling.

> **Note**:
>
> See [mainsail.cfg](https://github.com/mainsail-crew/mainsail-config/blob/master/client.cfg) for all available `_CLIENT_VARIABLE` options and more advanced customization.

## Internal Macros

These macros are triggered automatically by print lifecycle events and should not be called directly:

- `_AFTER_PAUSE` - Triggered by Mainsail/Fluidd PAUSE command
- `_BEFORE_RESUME` - Triggered by Mainsail/Fluidd RESUME command
- `_BEFORE_CANCEL` - Triggered by Mainsail/Fluidd CANCEL_PRINT command
- `NOZZLE_STANDBY_COOLDOWN` - `delayed_gcode` armed by `_AFTER_PAUSE`; drops the hotend to standby on a prolonged pause
