# Status Macros & LED Configuration (status_macros.cfg)

The status macros use a hardware-agnostic dict-based LED configuration system (`_LED_VARS`) to control printer status indicators. This allows all printers to use the same macros regardless of their LED hardware.

## Usage

```gcode
STATUS_HEATING      # Red/orange LEDs, "Heating..." message
STATUS_HOMING       # Cyan LEDs, "Homing..." message
STATUS_LEVELING     # Purple LEDs, "Leveling..." message
STATUS_MESHING      # Lime LEDs, "Meshing..." message
STATUS_CLEANING     # Blue LEDs, "Cleaning..." message
STATUS_PRINTING     # Blue logo, white nozzle, white chamber
STATUS_READY        # Dim white LEDs
STATUS_OFF          # All LEDs off
RESET_STATUS        # Auto-select PRINTING or READY based on printer state
```

Status macros are automatically called by other plugin macros. These macros have no parameters.

## Configuration

The `_LED_VARS` macro defines LED groups via a single nested dict:

```ini
[gcode_macro _LED_VARS]
# Nested dict: {'group_name': {'neopixel_name': 'index_spec', ...}, ...}
variable_leds: {
        'logo': {'toolhead': 1},
        'nozzle': {'toolhead': '2-3'},
        'chamber': {}
    }
```

**LED Groups:**
- `chamber`: Lights up in sequence during `HEAT_SOAK` (red→green progress bar)
- `logo`: Fades during `HEAT_SOAK` and displays status color in `STATUS_*` macros
- `nozzle`: White during printing, status color otherwise

**Index Values:**
- Empty string `''` or `0`: Apply to entire device (no INDEX parameter)
- Single integer `1`: Apply to specific LED index
- Comma-separated string `'2,3'`: Apply to multiple indices
- Range notation `'1-8'`: Apply to indices 1 through 8
- Mixed format `'1-3,5,7-10'`: Combine ranges and individual indices

**Custom Groups:**
You can define additional groups beyond logo/nozzle/chamber. Use them with `_SET_LEDS MAP=your_group`.

### Configuration Steps

1. **Include `status_macros.cfg`** in your `printer.cfg`:
   ```ini
   [include nerdygriffin-macros/status_macros.cfg]
   ```

2. **Override `_LED_VARS`** in your `printer.cfg` to match your LED hardware

3. **Verify** with test macros:
   ```gcode
   STATUS_HEATING
   STATUS_PRINTING
   STATUS_READY
   ```

## Examples

### Minimal Setup: Toolhead LEDs Only (No Chamber Animation)

For printers with only status indicators (no chamber animation desired):

```ini
[gcode_macro _LED_VARS]
variable_leds: {
        'logo': {'toolhead': 1},
        'nozzle': {'toolhead': '2-3'},
        'chamber': {}
    }
```

### Intermediate Setup: Toolhead + Bed + Chamber Strips

For printers with bed light and chamber LED strips:

```ini
[gcode_macro _LED_VARS]
variable_leds: {
        'logo': {'bed_light': '', 'toolhead': 1},
        'nozzle': {'toolhead': '2-3'},
        'chamber': {'chamber_left': '', 'chamber_right': ''}
    }
```

### Advanced Setup: Multi-Segment Chamber Strip

For chamber strips with individually addressable LEDs (recommended for visual progress):

```ini
[gcode_macro _LED_VARS]
variable_leds: {
        'logo': {'toolhead': 1},
        'nozzle': {'toolhead': '2-3'},
        'chamber': {'chamber_strip': '1-8'}
    }
```

### Custom Groups

You can add custom LED groups for special purposes:

```ini
[gcode_macro _LED_VARS]
variable_leds: {
        'logo': {'toolhead': 1},
        'nozzle': {'toolhead': '2-3'},
        'chamber': {},
        'accent': {'panel_left': '1-4', 'panel_right': '1-4'}
    }
```

Use custom groups with: `_SET_LEDS MAP=accent RED=0.5 GREEN=0 BLUE=1`

## Internal Macros

These helper macros are called by status macros and should not be called directly:

- `_SET_LEDS MAP=<group>` - Sets color on all devices in the specified group
- `SET_NOZZLE_LEDS_ON` / `SET_CHAMBER_LEDS_ON` - Convenience wrappers for common LED states

> **Note**:
>
> All helper macros safely skip missing devices. Empty dicts result in no-op (no errors).
