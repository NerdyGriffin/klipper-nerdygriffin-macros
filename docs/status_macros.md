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

The `_LED_VARS` macro defines three logical LED groups via dicts:

```ini
[gcode_macro _LED_VARS]
# Dicts: key = neopixel device name, value = index or comma-string of indices
variable_chamber_map: {}                    # LEDs for chamber/enclosure feedback
variable_logo_map: {'toolhead': 1}          # LEDs for status logo (bed light or toolhead pixel)
variable_nozzle_map: {'toolhead': '2,3'}    # LEDs for nozzle status
```

**LED Groups:**
- `chamber_map`: Lights up in sequence during `HEAT_SOAK` (red→green progress bar)
- `logo_map`: Fades during `HEAT_SOAK` and displays status color in `STATUS_*` macros
- `nozzle_map`: White during printing, status color otherwise

**Index Values:**
- Empty string `''` or `0`: Apply to entire device (no INDEX parameter)
- Single integer `1`: Apply to specific LED index
- Comma-separated string `'2,3'`: Apply to multiple indices

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
variable_logo_map: {'toolhead': 1}
variable_nozzle_map: {'toolhead': '2,3'}
```

**Note:** Only override variables that differ from defaults. Since `variable_chamber_map` defaults to `{}`, it's omitted here.

### Simple Setup: Toolhead LEDs Only (With Chamber Animation)

For single-toolhead printers (V0.3048 or any printer with only toolhead LEDs):

```ini
[gcode_macro _LED_VARS]
variable_logo_map: {'toolhead': 1}
variable_nozzle_map: {'toolhead': '2,3'}
```

**Note:** This is identical to the minimal setup. Chamber animation uses the `logo_map` for visual feedback on toolhead-only printers.

### Intermediate Setup: Toolhead + Bed + Chamber Strips

For printers with bed light and chamber LED strips (e.g., V0 with future chamber LEDs):

```ini
[gcode_macro _LED_VARS]
variable_chamber_map: {'chamber_left': '', 'chamber_right': ''}
variable_logo_map: {'bed_light': '', 'toolhead': 1}
variable_nozzle_map: {'toolhead': '2,3'}
```

### Advanced Setup: Multi-Segment Chamber Strip

For chamber strips with individually addressable LEDs (recommended for visual progress):

```ini
[gcode_macro _LED_VARS]
variable_chamber_map: {'chamber_strip': '1,2,3,4,5,6,7,8'}
variable_logo_map: {'toolhead': 1}
variable_nozzle_map: {'toolhead': '2,3'}
```

## Internal Macros

These helper macros are called by status macros and should not be called directly:

- `_SET_LOGO_LEDS` - Sets color on all devices in `logo_map`
- `_SET_NOZZLE_LEDS` - Sets color on all devices in `nozzle_map`
- `_SET_CHAMBER_LEDS` - Sets color on all devices in `chamber_map`
- `SET_NOZZLE_LEDS_ON` / `SET_NOZZLE_LEDS_OFF` - Convenience wrappers for nozzle LEDs

> **Note**:
>
> All helper macros safely skip missing devices. Empty dicts result in no-op (no errors).
