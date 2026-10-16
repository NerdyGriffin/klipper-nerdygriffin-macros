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
<!-- -->
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

Override brush dimensions and cleaning performance via the shared `_NW_BRUSH_VARS` macro. It uses
the same keys and axis conventions as AFC's `_AFC_BRUSH_VARS`:

```ini
[gcode_macro _NW_BRUSH_VARS]
variable_brush_loc          : 10,40,-1  # Center of the brush (X, Y, Z); Z -1 = no Z move
variable_brush_clean_speed  : 150       # Speed of cleaning moves (mm/s)
variable_brush_clean_accel  : 3000      # Acceleration during cleaning (mm/s²); 0 = keep global accel
variable_brush_width        : 7         # Total width in mm (X direction)
variable_brush_depth        : 35        # Total depth in mm (Y direction)
variable_y_brush            : True      # Brush along Y axis then X (False = X only)
variable_brush_count        : 4         # Number of wipe passes
```

`brush_loc` defaults to `-1,-1,-1`; `NW_WIPE` refuses to run until it is set.

### Optional: Wipe Behavior

Override wipe cycle behavior:

```ini
[gcode_macro NW_WIPE]
variable_enable_hotcold: True   # Wipe while cooling to minimize ooze
variable_clear_margin: 20       # mm past the brush edge when exiting the brush
variable_park_loc: 60,60        # Post-wipe park (X, Y); -1,-1 skips the park
```

After wiping, `NW_WIPE` exits the brush along its long axis (whichever of `brush_width` / `brush_depth`
is larger), heading toward `park_loc` — or toward the bed centre when parking is skipped — then parks
by moving the other axis first, so the toolhead never crosses the servo arm.

### With AFC

When `AFC_BRUSH` is defined, `NW_WIPE` calls it for every sweep (including the hot-to-cold passes)
and takes the brush geometry from `_AFC_BRUSH_VARS`; `_NW_BRUSH_VARS` is not read at all. Servo
deploy/retract, purge, exit and park still come from this file.

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
