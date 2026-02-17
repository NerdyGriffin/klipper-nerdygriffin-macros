# Maintenance Macros (maintenance_macros.cfg)

Utilities for hands-on printer maintenance: nozzle cleaning, nozzle changes, and developer diagnostics.

## Usage

```gcode
DEEP_CLEAN_NOZZLE [TEMP=260]     # Deep clean with temperature stepping
NOZZLE_CHANGE_POSITION           # Park toolhead at front-center for nozzle swap
```

### DEEP_CLEAN_NOZZLE Parameters

| parameters | default value | description |
|-----------:|---------------|-------------|
| TEMP | max_temp - 20°C | Starting temperature for cleaning cycle |

- `DEEP_CLEAN_NOZZLE` — Steps down temperature in 20°C increments, cleaning at each step until reaching 160°C. Uses `AFC_BRUSH` if available, otherwise falls back to `CLEAN_NOZZLE`.
- `NOZZLE_CHANGE_POSITION` — Homes if needed, heats to 280°C (if extruder can extrude), and parks front-center at Z=100 for convenient nozzle access. Calls `NW_RETRACT` if available.

## Internal Macros

- `_DEBUG_PRINT_STATE` — Prints current toolhead position, homing state, and coordinate mode to the console. Accepts an optional `MSG` parameter for labeling output.

See [belt_tension.md](belt_tension.md) for `SETTLE_BELT_TENSION` and the shared `_BELT_TENSION_VARS` configuration.
