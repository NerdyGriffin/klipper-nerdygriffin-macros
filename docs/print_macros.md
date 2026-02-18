# Print Start/End Macros (print_macros.cfg)

The `print_macros.cfg` provides hardware-agnostic `PRINT_START` and `PRINT_END` macros that automatically detect your printer's capabilities (AFC, nozzle wiper, Beacon probe, etc.) and adjust behavior accordingly.

## Usage

```gcode
PRINT_START BED=100 EXTRUDER=240 [CHAMBER=45]
PRINT_END
```

### PRINT_START Parameters

| parameters | default value | description |
|-----------:|---------------|-------------|
| BED | 60 | Target bed temperature in °C |
| EXTRUDER | 200 | Target extruder temperature in °C |
| CHAMBER | None | Target chamber temperature in °C (optional, auto-calculated from bed temp if omitted) |

## PRINT_START Behavior

### AFC branch (if `AFC_PARK` is defined)

When an AFC system is present, an extra early-print step runs before heating:

1. `AFC_PARK` — move toolhead to AFC safe position
2. Heat bed and wait for extruder temperature
3. Load initial tool (`T{TOOL}` — defaults to T0)

This path heats and loads the tool before the main sequence continues (fan on, standby extruder, heat soak, etc.).

### Nozzle cleaning

After heat soak, the nozzle is cleaned using whichever system is present (checked in priority order):

1. **AFC system** (`AFC_BRUSH` defined) → `AFC_BRUSH`
2. **Nozzle wiper** (`CLEAN_NOZZLE` defined) → heat to target extruder, `CLEAN_NOZZLE`, revert to standby temp
3. **Neither** → nozzle cleaning skipped

### Z calibration sequence

Z calibration adapts to whether a Beacon probe is configured:

- **No Beacon**: `G28 Z` after z-tilt (standard re-home for thermal expansion)
- **Beacon**: three-pass contact calibration:
  1. `G28 Z METHOD=CONTACT CALIBRATE=1` — before z-tilt (establishes reference)
  2. `Z_TILT_ADJUST` (if configured)
  3. `G28 Z METHOD=CONTACT CALIBRATE=1` — after z-tilt
  4. `BED_MESH_CALIBRATE`
  5. `AFC_BRUSH` again (if defined, cleans ooze from mesh)
  6. `G28 Z METHOD=CONTACT CALIBRATE=0` — final z offset with hot nozzle

### Park before final heat

After mesh generation, the toolhead is parked before the final nozzle heat:

- `AFC_PARK` if defined
- `SMART_PARK` (KAMP) if defined and no AFC
- No parking otherwise

### Purge and prime

After the nozzle reaches print temperature:

- `LINE_PURGE` runs unconditionally (KAMP adaptive purge line)
- `VORON_PURGE` is available as an alternative but is commented out — edit the macro to switch
- `G11` (firmware unretract) always runs after purge
- **Beacon systems**: thermal z offset is applied via `SET_GCODE_OFFSET Z_ADJUST`
- **Non-AFC, non-Beacon**: `_CONDITIONAL_UNRETRACT` + a small `_CLIENT_EXTRUDE` prime

### Encoder sensor

The filament encoder sensor is enabled at the very end of `PRINT_START` (after all purging), so filament motion during setup does not trigger false runout events.

---

## PRINT_END Behavior

### Retract and park

- `G10` (firmware retract) runs immediately after the anti-stringing move
- **AFC systems**: `AFC_PARK` handles the final park position (over silicone pad)
- **Non-AFC**: toolhead moves to rear corner, then `_CONDITIONAL_RETRACT` + `G11` (firmware retract/unretract cycle to clear pressure)

### Beacon thermal offset

If a Beacon probe is configured, the thermal z offset applied during `PRINT_START` is removed: `SET_GCODE_OFFSET Z_ADJUST=-{thermal_z_offset}`.

### Encoder sensor

The encoder sensor is disabled at the end of `PRINT_END` so idle filament motion does not trigger runouts.

### Bed temperature after print

Controlled by `variable_final_bed_temp` (default `0`):

- `0` (default) — heaters fully off, `notify_bed_cooled` delayed gcode fires after 10 s
- Non-zero — bed held at that temperature, `notify_bed_heated` fires after 10 s to alert when ready

Reset to `0` automatically after each print so it does not carry over.

### Delayed actions

After print end, two delayed gcodes are armed:

- `delayed_save_config` — fires after 60 s (saves any pending config changes)
- `delayed_shutdown` — fires after 90 s (optional auto-shutdown; no-op unless configured)

## Configuration

These macros use status LEDs and heat soak features. See:
- [status_macros.md](status_macros.md) - LED configuration
- [heat_soak.md](heat_soak.md) - Chamber preheating options
