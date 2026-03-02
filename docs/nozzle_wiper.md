# Nozzle Wiper (nozzle_wiper.cfg)

The `nozzle_wiper.cfg` provides enhanced support for Chirpy's [Nozzle Wiper v2](https://github.com/chirpy2605/voron/tree/main/V0/NozzleWiper), a servo-actuated nozzle cleaning with a purge bucket and brush. All hardware values are configurable via printer-specific overrides.

## Usage

```gcode
NW_CLEAN_NOZZLE         # Full routine: deploy → purge → wipe → retract
NW_PURGE                # Purge filament only (no wipe)
NW_WIPE                 # Wipe nozzle only (no purge)
NW_DEPLOY               # Deploy servo arm only (extend to cleaning position)
NW_RETRACT              # Retract servo arm only (stow after cleaning)
NW_TEST_CLEAN_NOZZLE    # Test macro: heats to 240°C, homes, then cleans (for calibration)
```

> **Note**:
>
> `CLEAN_NOZZLE` is a compatibility alias that delegates to `NW_CLEAN_NOZZLE`. It exists so that `PRINT_START` (and other systems) can call `CLEAN_NOZZLE` as a generic entry point — AFC systems can shadow it with `AFC_BRUSH`, while non-AFC printers with `nozzle_wiper.cfg` get the full wiper routine automatically.

> **Warning**:
>
> **Bucket positions MUST be calibrated before use.** The macro intentionally sets bucket positions to `-1000` by default to force calibration. You must override these values in your `printer.cfg` before the macro will function correctly.

## Configuration

### Required: Servo Hardware

Define the servo in your `printer.cfg`:

```ini
[servo wipeServo]
pin: gpio29                          # Your servo pin (adjust for your board)
maximum_servo_angle: 180
minimum_pulse_width: 0.0005
maximum_pulse_width: 0.0025
```

### Required: Bucket Position

After including `nozzle_wiper.cfg`, override the bucket positions:

```ini
[gcode_macro NW_BUCKET_POS]
variable_x: 28    # Calibrated X position for bucket center
variable_y: 40    # Calibrated Y position for bucket center
variable_z: 60    # Safe Z height for cleaning operations
```

### Optional: Brush Geometry

Override brush dimensions and cleaning performance via the shared `_NW_BRUSH_VARS` macro:

```ini
[gcode_macro _NW_BRUSH_VARS]
variable_brush_loc          : 10,38     # Position of the center of the brush (X, Y)
variable_brush_clean_speed  : 30000     # Speed of cleaning moves (mm/min)
variable_brush_clean_accel  : 3000      # Acceleration during cleaning (mm/s²)
variable_brush_width        : 35        # Total width in mm (Y direction)
variable_brush_depth        : 7         # Total depth in mm (X direction)
variable_brush_segments     : 20        # Wipe segments per pass (higher = smoother)
```

### Optional: Wipe Behavior

Override wipe cycle behavior:

```ini
[gcode_macro NW_WIPE]
variable_enable_hotcold: True   # Wipe while cooling to minimize ooze
```

### Optional: Purge Parameters

```ini
[gcode_macro NW_PURGE]
variable_purge_len: 5          # Amount of filament to purge (mm)
variable_purge_spd: 150        # Purge speed (mm/min)
variable_purge_temp_min: 240   # Minimum nozzle temperature (°C)
variable_purge_ret: 2          # Retract amount after purge (mm)
variable_ooze_dwell: 2         # Dwell time after retract (seconds)
```

### Calibration Steps

1. The macro intentionally sets bucket positions to `-1000` by default to force calibration
2. Use `NW_TEST_CLEAN_NOZZLE` to test your setup after adding initial position estimates
3. Adjust bucket and brush positions until the nozzle correctly reaches all positions
4. Verify positions are correct and the nozzle cleans without collisions
