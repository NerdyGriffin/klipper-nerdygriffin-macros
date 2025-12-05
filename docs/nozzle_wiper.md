# Nozzle Wiper (nozzle_wiper.cfg)

The `nozzle_wiper.cfg` provides servo-actuated nozzle cleaning with a purge bucket and brush. All hardware values are configurable via printer-specific overrides.

## Usage

```gcode
CLEAN_NOZZLE            # Full routine: deploy → purge → wipe → retract
NW_PURGE                # Purge filament only (no wipe)
NW_WIPE                 # Wipe nozzle only (no purge)
NW_TEST_CLEAN_NOZZLE    # Test macro: heats to 240°C, homes, then cleans (for calibration)
```

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

Override brush dimensions and wiping behavior:

```ini
[gcode_macro NW_WIPE]
variable_brush_start: 65       # Y position where brush begins
variable_brush_length: 45      # Length of brush in Y direction
variable_brush_front: 11       # X position of brush front edge
variable_brush_depth: 6        # Depth of brush in X direction
variable_brush_segments: 20    # Number of wipe segments (higher = smoother)

variable_enable_hotcold: True  # Wipe while cooling to minimize ooze
variable_wipe_qty_min: 4       # Minimum wipes before checking temperature
variable_wipe_qty_max: 128     # Maximum wipes before stopping
variable_scrub_temp_min: 150   # Stop wiping when cooled to this temp (°C)
variable_prep_spd_xy: 30000    # Travel speed (mm/min)
variable_wipe_spd_xy: 30000    # Wiping speed (mm/min)
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
