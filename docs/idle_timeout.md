# Idle Timeout (idle_timeout.cfg)

Customizes Klipper's native `[idle_timeout]` so an idle printer cools the hotend and parks instead of immediately disabling the steppers, with dedicated handling while a print is paused.

## Dependencies

**Required** (this file errors at runtime if these are not included):

- [`status_macros.cfg`](status_macros.md) — `STATUS_OFF` (called when idling while not paused)

**Optional** (auto-detected; falls back gracefully if absent):

- [`client.cfg`](client.md) — cancels its `NOZZLE_STANDBY_COOLDOWN` timer so idle_timeout stays authoritative (guarded on `_AFTER_PAUSE` being defined)
- AFC — parks and brushes via `AFC_BRUSH` / `AFC_PARK` if present

> **Note**:
>
> "Required" means the section's gcode fails when it **runs** (Klipper renders the template at idle time), not at config load. See [DEPENDENCIES.md](DEPENDENCIES.md) for the full dependency graph.

## Behavior

`[idle_timeout]` runs its gcode automatically once the printer has been idle for `timeout` seconds. This file overrides the stock behavior to keep the steppers enabled (no `M84`) while a job can still resume, and branches on whether a print is paused:

- **Always** — turns the hotend off (`M104 S0`, bed left on) and disables the encoder filament sensor. If [`client.cfg`](client.md)'s prolonged-pause standby feature is included, its pending `NOZZLE_STANDBY_COOLDOWN` timer is cancelled first so the two never fight.
- **Paused or printing from virtual SD** (`is_paused` / `virtual_sdcard.is_active`) — parks the toolhead via `AFC_BRUSH` / `AFC_PARK` (only when homed and AFC is present) and leaves the steppers enabled so the print can resume.
- **Otherwise (fully idle)** — `TURN_OFF_HEATERS`, `STATUS_OFF`, resets the extruder position (`G92 E0`), and disables the steppers (`M84`).

> **Note**:
>
> AFC extends the idle timeout to its `error_timeout` (default 10 h) when it pauses on an error, so this gcode does not fire until then. In the meantime [`client.cfg`](client.md)'s `NOZZLE_STANDBY_COOLDOWN` drops the hotend to a standby temperature — see [Prolonged-pause hotend standby](client.md#prolonged-pause-hotend-standby).

## Configuration

The idle period is set by the native `timeout` option (in seconds):

```ini
[idle_timeout]
timeout: 1800   # 30 minutes (this file's default)
```

The timeout can also be changed at runtime with Klipper's native `SET_IDLE_TIMEOUT TIMEOUT=<seconds>` command (this is how AFC extends it during an error pause).

> **Warning**:
>
> `[idle_timeout]` is a native Klipper section and must be defined exactly once. If you include this file, do not also declare `[idle_timeout]` in `printer.cfg`.
