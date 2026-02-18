# Shake&Tune Integration (shaketune.cfg)

Convenient wrappers for the [Shake&Tune](https://github.com/Frix-x/klippain-shaketune) input shaper analysis tool.

> **Note**:
>
> This integration requires the [Shake&Tune extension](https://github.com/Frix-x/klippain-shaketune) to be installed separately.

## Usage

```gcode
SHAKETUNE_BELTS_RESPONSES              # Belt comparison analysis (cold)
SHAKETUNE_COLD               # Full calibration suite (belts, shaper, vibrations) cold
SHAKETUNE_HOT                # Full calibration suite preheated (bed 100°C, chamber 50°C)
SHAKETUNE_BELT_TENSION     # Excite belts at calculated resonance frequency for tension measurement
```

- `SHAKETUNE_BELTS_RESPONSES` — Runs `COMPARE_BELTS_RESPONSES` with a cold printer.
- `SHAKETUNE_COLD` — Runs belt comparison, `AXES_SHAPER_CALIBRATION`, and `CREATE_VIBRATIONS_PROFILE` cold.
- `SHAKETUNE_HOT` — Same as cold but preheats (bed 100°C, chamber 50°C via `HEAT_SOAK`) first.
- `SHAKETUNE_BELT_TENSION` — Calculates target belt resonance frequency from calibrated belt span parameters, then runs `EXCITATE_AXIS_AT_FREQ` at that frequency. Requires `y_calibrated` to be set correctly.

All macros rely on `G28` and optional `Z_TILT_ADJUST` to position the toolhead at a safe Z height. No additional Z parking is performed.

## Configuration

`SHAKETUNE_BELT_TENSION` shares belt parameters with `SETTLE_BELT_TENSION` via the shared `_BELT_TENSION_VARS` macro. Override in your `printer.cfg`:

```ini
[gcode_macro _BELT_TENSION_VARS]
variable_belt_span_length: 150          # Distance between X/Y idler centers and front idler (mm)
variable_y_calibrated: 120              # Y position where vibrating belt span = belt_span_length
variable_belt_mass_per_meter: 0.00817   # GT2 6mm belt nominal mass (kg/m)
variable_rec_tension: 11.12             # Target tension (N) for frequency calculation
```

`SHAKETUNE_BELT_TENSION` validates that `y_calibrated` is within your printer's Y axis limits. If out of bounds, the macro errors with guidance to correct the variable. **Do not clamp this value**—accuracy of belt frequency measurement depends on the exact calibrated position matching your physical belt span.

See [belt_tension.md](belt_tension.md) for belt span calibration steps and the frequency formula.
