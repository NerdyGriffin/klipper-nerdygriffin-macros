# Maintenance Macros (maintenance_macros.cfg)

Utilities for printer maintenance tasks including belt tension settling and nozzle changes.

## Usage

```gcode
SETTLE_BELT_TENSION      # Settle belts through full range of motion, then park for frequency measurement
NOZZLE_CHANGE_POSITION   # Park toolhead at front-center for nozzle swap
```

- `SETTLE_BELT_TENSION` — Cycles the toolhead through its full range of motion to settle belts after a tension adjustment, then parks at a pre-calibrated Y position for external frequency measurement. Displays the target frequency range on completion.
- `NOZZLE_CHANGE_POSITION` — Homes if needed, heats to 280°C (if extruder can extrude), and parks front-center at Z=100 for convenient nozzle access. Calls `NW_RETRACT` if available.

## Internal Macros

- `_DEBUG_PRINT_STATE` — Prints current toolhead position, homing state, and coordinate mode to the console. Accepts an optional `MSG` parameter for labeling output.

## Configuration

Override belt parameters for `SETTLE_BELT_TENSION` in your `printer.cfg`:

```ini
[gcode_macro SETTLE_BELT_TENSION]
variable_belt_span_length: 150      # Distance between X/Y idler centers and front idler (mm)
variable_y_calibrated: 120          # Y position where vibrating belt span = belt_span_length (must be within axis limits)
variable_belt_mass_per_meter: 0.00817  # GT2 6mm belt nominal mass (kg/m)
variable_min_tension: 8.90          # Minimum belt tension (N)
variable_rec_tension: 11.12         # Recommended belt tension (N)
variable_max_tension: 13.34         # Maximum belt tension (N)
```

### Calibration Steps

1. Set `variable_belt_span_length` to the desired belt span length, which will be the distance from X/Y idler centers to front idler centers
   - Typical value is 150mm from the Voron docs, but you may need to use a smaller value for smaller printers such as V0.2 and Micron
2. Home the printer, then jog the toolhead along Y until the distance between the X/Y idlers and the front idlers matches your `variable_belt_span_length`. Note the Y coordinate at this position.
3. Set `variable_y_calibrated` to that Y coordinate
4. Run `SETTLE_BELT_TENSION` and note the displayed target frequency
5. Measure actual belt frequency using external tools (microphone with Spectroid app, tension gauge, etc.)
6. Adjust physical belt tension until measured frequency matches the target

> **Important**: `y_calibrated` must be within your printer's Y axis limits. If the macro errors with an out-of-bounds message, you must choose a smaller `belt_span_length` and calibrate `y_calibrated` to match that custom belt span.
> The accuracy of belt tension measurement depends on the exact calibrated position matching your physical belt span.

### Frequency Display

The macro displays a target frequency range calculated from your belt parameters using the physics formula:

$$f = \frac{1}{2L} \sqrt{\frac{T}{m}}$$

Where:
- **f** = frequency (Hz)
- **L** = belt span (m)
- **T** = tension (N)
- **m** = mass per meter (kg/m)

See [shaketune.md](shaketune.md) for the related `SHAKETUNE_EXCITATE_BELTS` macro which shares the same belt span configuration.
