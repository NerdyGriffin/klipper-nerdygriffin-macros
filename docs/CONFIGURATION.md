# Configuration Guide

Detailed configuration instructions for klipper-nerdygriffin-macros.

---

## Client Macros (client_macros.cfg)

The client macros require `_CLIENT_VARIABLE` override in your `printer.cfg` to hook into Mainsail/Fluidd pause/resume/cancel:

```ini
[gcode_macro _CLIENT_VARIABLE]
variable_park_at_cancel   : True
variable_user_pause_macro : "_AFTER_PAUSE"    # Hook to plugin macro
variable_user_resume_macro: "_BEFORE_RESUME"  # Hook to plugin macro
variable_user_cancel_macro: "_BEFORE_CANCEL"  # Hook to plugin macro
gcode:
```

**Note:** The `_AFTER_PAUSE`, `_BEFORE_RESUME`, and `_BEFORE_CANCEL` macros from the plugin handle filament sensor management and optional AFC integration. See [mainsail.cfg](https://github.com/mainsail-crew/mainsail-config/blob/master/client.cfg) for all available `_CLIENT_VARIABLE` options.

---

## Beeper Configuration (beeper.cfg)

The beeper requires hardware-specific pin configuration. Add this to your `printer.cfg` **after** including `beeper.cfg`:

```ini
[pwm_cycle_time beeper]
pin: YOUR_PIN_HERE    # Examples below

# Common pins by board:
#   Raspberry Pi GPIO: gpio23, gpio24, gpio25
#   BTT Octopus:       PE5
#   BTT SKR:           PA8, PB15
#   RAMPS:             ar37
#   Fysetc Spider:     PA15
```

---

## Status Macros & LED Configuration (status_macros.cfg)

The status macros use a hardware-agnostic dict-based LED configuration system (`_LED_VARS`). This allows all printers to use the same macros regardless of their LED hardware.

### Quick Setup (Toolhead LEDs Only)

Add this to your `printer.cfg` after including `status_macros.cfg`:

```ini
[gcode_macro _LED_VARS]
variable_chamber_map: {}
variable_logo_map: {'toolhead': 1}
variable_nozzle_map: {'toolhead': '2,3'}
gcode:
```

Replace `toolhead` with your actual neopixel device name(s) and adjust indices (1, 2, 3) to match your LED configuration.

### Complete LED Setup

See [`LED_SETUP.md`](LED_SETUP.md) for:
- Detailed configuration examples for various printer types
- How to use multiple LED devices
- LED animation behavior during `HEAT_SOAK`
- How to add custom LED devices

---

## Filament Management Configuration

### Customizing Parking Positions

The filament macros automatically detect AFC hardware and use appropriate parking positions. For non-AFC setups, you can customize the parking positions:

```ini
[gcode_macro _FILAMENT_PARK_PARAMS]
variable_load_x: 60.0          # X position for load/unload (None = auto: bed center)
variable_load_y: 10.0          # Y position for load/unload (None = auto: front + 10mm)
variable_purge_x: 10.0         # X position for purge (None = auto: 10mm)
variable_purge_y: 10.0         # Y position for purge (None = auto: front + 10mm)
```

**Note:** Set any coordinate to `None` to use automatic calculation based on your bed size. Z height is automatically calculated as 75% of max Z, rounded down to the nearest 10mm.

### Customizing Filament Distances

Override macro variables in your `printer.cfg`:

```ini
# Example: Adjust for your specific hotend
[gcode_macro LOAD_FILAMENT]
variable_load_distance: 60      # Distance to load (default: 60mm)
variable_purge_distance: 100    # Distance to purge (default: 100mm)

[gcode_macro UNLOAD_FILAMENT]
variable_unload_distance: 65    # Distance to unload (default: 65mm)
variable_purge_distance: 12.45  # Purge before unload (default: 12.45mm)
```

---

## Belt Tension Calibration (maintenance_macros.cfg)

The `SETTLE_BELT_TENSION` macro parks at a calibrated Y position for belt frequency measurement. Override the position in your `printer.cfg`:

```ini
# Override calibrated Y position for belt tension measurement
[gcode_macro SETTLE_BELT_TENSION]
variable_y_calibrated: 116  # The Y position that results in exactly 130mm between idler centers
                            # Common values: 116 (V0 120mm bed), 120 (Trident 300mm bed)
                            # Measure your actual belt span and adjust accordingly
```

**Note:** The Y calibrated position depends on your specific printer geometry and desired belt span for frequency measurement. See the macro comments for frequency targets at different belt lengths.

---

## Heat Soak Configuration (heat_soak.cfg)

The `HEAT_SOAK` macro provides hardware-agnostic chamber preheating with optional LED animations. It auto-detects chamber temperature sensors and supports per-printer customization.

### Default Variables

- `variable_max_chamber_temp: 60` - Maximum chamber temp achievable via passive heating
- `variable_ext_assist_multiplier: 4` - Extruder assist temp multiplier (chamber_temp × multiplier, capped at 200°C)
- `variable_chamber_sensor_name: ""` - Explicit sensor name (empty = auto-detect)
- `variable_frame_rate: 12` - LED animation frame rate in Hz

### Auto-Detection Logic

The macro searches for chamber sensors in this order:
1. Explicit `chamber_sensor_name` (if provided)
2. `temperature_sensor chamber`
3. `temperature_sensor nitehawk-36` (toolhead proxy)

### Example Overrides

For V0 (measured limits, stronger assist):
```ini
[gcode_macro HEAT_SOAK]
variable_max_chamber_temp: 58           # V0 measured limit
variable_ext_assist_multiplier: 5       # Stronger extruder assist for V0
variable_chamber_sensor_name: "chamber" # Explicit sensor name (if available)
```

For printers with toolhead-only sensors:
```ini
[gcode_macro HEAT_SOAK]
variable_chamber_sensor_name: "nitehawk-36"  # Use toolhead as temperature proxy
```

For custom LED animation speed:
```ini
[gcode_macro HEAT_SOAK]
variable_frame_rate: 8  # Slower animation (8 FPS instead of 12)
```

### LED Animation

- Uses `_LED_VARS` dict-based system (see [`LED_SETUP.md`](LED_SETUP.md))
- `chamber_map`: Animates chamber/enclosure LEDs with red→green progress bar
- `logo_map`: Fades logo/bed light from red→green alongside chamber animation
- Safe by design: missing devices are automatically skipped

---

## Nozzle Wiper Configuration (nozzle_wiper.cfg)

The `nozzle_wiper.cfg` provides servo-actuated nozzle cleaning with a purge bucket and brush. All hardware values are configurable via printer-specific overrides.

### Required Hardware Setup

First, define the servo in your `printer.cfg`:

```ini
[servo wipeServo]
pin: gpio29                          # Your servo pin (adjust for your board)
maximum_servo_angle: 180
minimum_pulse_width: 0.0005
maximum_pulse_width: 0.0025
```

### Required Position Calibration

After including `nozzle_wiper.cfg`, override the bucket and brush positions in your `printer.cfg`:

```ini
[gcode_macro NW_BUCKET_POS]
variable_x: 28    # Calibrated X position for bucket center
variable_y: 40    # Calibrated Y position for bucket center
variable_z: 60    # Safe Z height for cleaning operations
```

### Optional: Customize Brush Geometry

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

### Optional: Customize Purge Parameters

```ini
[gcode_macro NW_PURGE]
variable_purge_len: 5          # Amount of filament to purge (mm)
variable_purge_spd: 150        # Purge speed (mm/min)
variable_purge_temp_min: 240   # Minimum nozzle temperature (°C)
variable_purge_ret: 2          # Retract amount after purge (mm)
variable_ooze_dwell: 2         # Dwell time after retract (seconds)
```

### Usage

```gcode
CLEAN_NOZZLE            # Full routine: deploy → purge → wipe → retract
NW_TEST_CLEAN_NOZZLE    # Test macro: heats to 240°C, homes, then cleans (for calibration)
```

**Calibration Note:** The macro intentionally sets bucket positions to `-1000` by default to force calibration. You must override these values in your `printer.cfg` before using the macro.
