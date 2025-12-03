# LED Variables Design

This document proposes a standardized, hardware-agnostic way to reference LED groups across printers using variables, enabling shared status and animation macros without hard-coding device names.

## Goals
- Avoid hard-coding LED device names (e.g., `panel_left`, `bed_light`, `toolhead`).
- Allow printers with different LED hardware to reuse the same macros.
- Support devices that expose multiple pixels via a single LED name.

## Approach: `_LED_VARS` Macro
A variable-only macro defines mappings from logical LED groups to physical LED device names and (optionally) pixel indices.

File: `macros/led_variables.cfg`
```ini
[gcode_macro _LED_VARS]
# Logical LED device names (string). Empty = not present
variable_nozzle_led: ""
variable_logo_led: ""           # optional logo indicator
variable_bed_led: ""
variable_chamber_led_right: ""
variable_chamber_led_left: ""

# Optional pixel index mapping for multi-LED devices (comma-separated list)
# Example for a toolhead device with two nozzle pixels: "0,1"
variable_nozzle_led_indices: ""
variable_bed_led_indices: ""
variable_chamber_led_right_indices: ""
variable_chamber_led_left_indices: ""

gcode:
    # This macro is variable-only. No gcode.
```

## Usage Pattern in Other Macros
```ini
[gcode_macro STATUS_READY]
gcode:
    {% set L = printer['gcode_macro _LED_VARS'] %}

    {% if L.nozzle_led and ("neopixel " ~ L.nozzle_led) in printer %}
        SET_LED LED={L.nozzle_led} RED=0.0 GREEN=0.4 BLUE=0.0
    {% endif %}

    {% if L.bed_led and ("neopixel " ~ L.bed_led) in printer %}
        SET_LED LED={L.bed_led} RED=0.0 GREEN=0.4 BLUE=0.0
    {% endif %}

    {% if L.chamber_led_right and ("neopixel " ~ L.chamber_led_right) in printer %}
        SET_LED LED={L.chamber_led_right} RED=0.0 GREEN=0.4 BLUE=0.0
    {% endif %}

    {% if L.chamber_led_left and ("neopixel " ~ L.chamber_led_left) in printer %}
        SET_LED LED={L.chamber_led_left} RED=0.0 GREEN=0.4 BLUE=0.0
    {% endif %}
```

If indices are used (e.g., for per-pixel control):
```ini
{% set idx = (L.nozzle_led_indices or "") | string %}
{% set idx_list = idx.split(',') if idx else [] %}
{% for i in idx_list %}
    SET_LED LED={L.nozzle_led} INDEX={i|int} RED=0.0 GREEN=0.4 BLUE=0.0
{% endfor %}
```

## Example Printer Overrides
V0.3048 (toolhead + bed + chamber panels):
```ini
[gcode_macro _LED_VARS]
variable_nozzle_led: "toolhead"
variable_bed_led: "bed_light"
variable_chamber_led_right: "panel_right"
variable_chamber_led_left: "panel_left"
variable_nozzle_led_indices: "0,1"
```

VT.1548 (toolhead only at present):
```ini
[gcode_macro _LED_VARS]
variable_nozzle_led: "toolhead"
variable_bed_led: ""
variable_chamber_led_right: ""
variable_chamber_led_left: ""
variable_nozzle_led_indices: "0,1"
```

## Migration Notes
- Existing macros that use hard-coded LED names can be refactored to reference `_LED_VARS`.
- Macros should always check that a device exists in `printer` before issuing `SET_LED`/`SET_LED_TEMPLATE`.
- Start with non-critical macros (e.g., heat soak animations) to validate the pattern, then extend to full status macros.

## Future Extensions
- Add color palette variables (e.g., `variable_color_ready`, `variable_color_heating`) if per-printer color customization is desired.
- Introduce `_STATUS_VARS` for pattern-specific tuning (blink rates, brightness caps) if needed later.
