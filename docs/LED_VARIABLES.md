# LED Variables Design (Dict-based)

Standardize, hardware-agnostic LED control using logical group dicts in `_LED_VARS`. This enables shared status/animation macros without hard-coding device names or indices.

## Goals
- Avoid hard-coded LED names (e.g., `chamber_left`, `bed_light`, `toolhead`).
- Support devices with multiple pixels via per-device indices.
- Keep per-printer customization in a single macro block.

## Location
- `_LED_VARS` now lives in `macros/status-macros.cfg` alongside the status helpers and `STATUS_*` macros.
- This reduces includes and keeps LED config near its consumers.

## Approach: Dicts per Logical Group
Define dicts that map physical LED names to indices for each logical group. Empty dict means the group is absent.

Example (inside `macros/status-macros.cfg`):
```ini
[gcode_macro _LED_VARS]
description: Adjustable LED settings for status macros.
# Dicts: key = neopixel device name, value = index or comma-string of indices
variable_chamber_map: {'chamber_left': '', 'chamber_right': ''} # Empty index = whole device
variable_logo_map: {'bed_light': 1, 'toolhead': 1}
variable_nozzle_map: {'toolhead': '2,3'}

gcode:
    # Variable-only macro; no gcode executed.
```

### Helper Macro Pattern
Helpers iterate the dicts, normalize the index value to a list, and set colors conditionally:
```ini
{% set L = printer['gcode_macro _LED_VARS'] %}
{% for name, idx in L.logo_map.items() %}
    {% set idx_str = (idx|string).strip() %}
    {% set indices = idx_str.split(',') if idx_str else [''] %}
    {% for i in indices %}
        {% if ("neopixel " ~ name) in printer %}
            {% if i %}
                SET_LED LED={name} INDEX={{ i|int }} RED={RED} GREEN={GREEN} BLUE={BLUE} WHITE={WHITE}
            {% else %}
                SET_LED LED={name} RED={RED} GREEN={GREEN} BLUE={BLUE} WHITE={WHITE}
            {% endif %}
        {% endif %}
    {% endfor %}
{% endfor %}
```

Notes:
- Accept int or comma-separated string for indices; empty value applies to the whole device.
- Always guard with `("neopixel " ~ name) in printer` before `SET_LED`.

### Heat Soak Animation
- `HEAT_SOAK` uses `chamber_map` to animate per-index progress from red → green.
- If a device in `chamber_map` has no indices, it uses the device’s `chain_count` from the neopixel config as the animation length.
- If indices are provided, the animation length is the number of indices specified.
- `logo_map` devices (e.g., bed light or toolhead logo pixel) are updated with the same fade color for visual feedback.
- No brightness parameterization is introduced; brightness remains as configured per device.

## Printer Override Examples

V0.3048 (toolhead + bed + chamber):
```ini
[gcode_macro _LED_VARS]
variable_chamber_map: {'chamber_left': '', 'chamber_right': ''}
variable_logo_map: {'bed_light': '', 'toolhead': 1}
variable_nozzle_map: {'toolhead': '2,3'}
```

VT.1548 (toolhead only):
```ini
[gcode_macro _LED_VARS]
variable_logo_map: {'toolhead': 3}
variable_nozzle_map: {'toolhead': '1,2'}
```

If chamber strip LEDs are installed:
```ini
[gcode_macro _LED_VARS]
variable_chamber_map: {'panel_left': '', 'panel_right': ''}
variable_logo_map: {'toolhead': 3}
variable_nozzle_map: {'toolhead': '1,2'}
```

## Migration Notes
- Status helpers (`_SET_LOGO_LEDS`, `_SET_NOZZLE_LEDS`, `_SET_CHAMBER_LEDS`) should iterate dicts and avoid hard-coded names.
- Deprecate previous `variable_*_led`, `*_indices`, and adopt `*_map` dict variables.
- Ensure helpers no-op when dicts are empty or devices are absent.
 - Consolidate direct `SET_LED` calls in macros (e.g., `HEAT_SOAK`) to use dict iteration.
 - `HEAT_SOAK` no longer uses `variable_led_count`; animation length is derived from `chain_count` or explicit indices.

## Future Extensions
- Optional palette dicts (e.g., `ready`, `heating`, `printing`) for per-printer color tuning.
- Optional `variable_brightness_max` to cap brightness consistently.
