# Maintenance Macros (maintenance_macros.cfg)

Utilities for printer maintenance tasks including nozzle changes and developer diagnostics.

## Usage

```gcode
NOZZLE_CHANGE_POSITION   # Park toolhead at front-center for nozzle swap
```

- `NOZZLE_CHANGE_POSITION` — Homes if needed, heats to 280°C (if extruder can extrude), and parks front-center at Z=100 for convenient nozzle access. Calls `NW_RETRACT` if available.

## Internal Macros

- `_DEBUG_PRINT_STATE` — Prints current toolhead position, homing state, and coordinate mode to the console. Accepts an optional `MSG` parameter for labeling output.

See [belt_tension.md](belt_tension.md) for `SETTLE_BELT_TENSION` and the shared `_BELT_TENSION_VARS` configuration.
