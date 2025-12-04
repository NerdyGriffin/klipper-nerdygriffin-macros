
# Status Macros & LED Configuration (status_macros.cfg)

The status macros use a hardware-agnostic dict-based LED configuration system (`_LED_VARS`). This allows all printers to use the same macros regardless of their LED hardware.

## Quick Setup (Toolhead LEDs Only)

Add this to your `printer.cfg` after including `status_macros.cfg`:

```ini
[gcode_macro _LED_VARS]
variable_chamber_map: {}
variable_logo_map: {'toolhead': 1}
variable_nozzle_map: {'toolhead': '2,3'}
gcode:
```

Replace `toolhead` with your actual neopixel device name(s) and adjust indices (1, 2, 3) to match your LED configuration.

## Complete LED Setup

See [`LED_SETUP.md`](LED_SETUP.md) for:
- Detailed configuration examples for various printer types
- How to use multiple LED devices
- LED animation behavior during `HEAT_SOAK`
- How to add custom LED devices
