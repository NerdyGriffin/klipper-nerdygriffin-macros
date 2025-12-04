# Nozzle Wiper Configuration (nozzle_wiper.cfg)

The `nozzle_wiper.cfg` provides servo-actuated nozzle cleaning with a purge bucket and brush. All hardware values are configurable via printer-specific overrides.

## Required Hardware Setup

First, define the servo in your `printer.cfg`:

```ini
[servo wipeServo]
pin: gpio29                          # Your servo pin (adjust for your board)
maximum_servo_angle: 180
minimum_pulse_width: 0.0005
maximum_pulse_width: 0.0025
```

## Required Position Calibration

After including `nozzle_wiper.cfg`, override the bucket and brush positions in your `printer.cfg`:

```ini
[gcode_macro NW_BUCKET_POS]
variable_x: 28    # Calibrated X position for bucket center
variable_y: 40    # Calibrated Y position for bucket center
variable_z: 60    # Safe Z height for cleaning operations
```

## Optional: Customize Brush Geometry

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

## Optional: Customize Purge Parameters

```ini
[gcode_macro NW_PURGE]
variable_purge_len: 5          # Amount of filament to purge (mm)
variable_purge_spd: 150        # Purge speed (mm/min)
variable_purge_temp_min: 240   # Minimum nozzle temperature (°C)
variable_purge_ret: 2          # Retract amount after purge (mm)
variable_ooze_dwell: 2         # Dwell time after retract (seconds)
```

## Usage

```gcode
CLEAN_NOZZLE            # Full routine: deploy → purge → wipe → retract
NW_TEST_CLEAN_NOZZLE    # Test macro: heats to 240°C, homes, then cleans (for calibration)
```

**Calibration Note:** The macro intentionally sets bucket positions to `-1000` by default to force calibration. You must override these values in your `printer.cfg` before using the macro.
