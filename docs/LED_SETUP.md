# LED Variables Design (Dict-based)

**Status**: ✅ **IMPLEMENTED** in `macros/status_macros.cfg`

This document describes the hardware-agnostic LED control system using logical group dicts in `_LED_VARS`. It enables shared status/animation macros without hard-coding device names or indices, and is the current standard for all LED configuration in this macro library.

## Goals
- Avoid hard-coded LED names (e.g., `chamber_left`, `bed_light`, `toolhead`).
- Support devices with multiple pixels via per-device indices.
- Keep per-printer customization in a single macro block (`_LED_VARS` in your `printer.cfg`).

## Location
- `_LED_VARS` is defined in `macros/status_macros.cfg` (with a default configuration).
- Copy and override `_LED_VARS` in your `printer.cfg` to customize for your specific hardware.
- All `STATUS_*` macros and helpers (`_SET_LOGO_LEDS`, `_SET_NOZZLE_LEDS`, `_SET_CHAMBER_LEDS`) use this system.
- `HEAT_SOAK` uses `_LED_VARS` for per-printer LED animations.

## Approach: Dicts per Logical Group

Define dicts that map physical LED device names to indices for each logical group. Empty index (empty string) applies the color to the entire device.

### Core Variables

The `_LED_VARS` macro defines three logical LED groups via dicts:

```ini
[gcode_macro _LED_VARS]
description: Adjustable LED settings for status macros (copy to printer.cfg and override as needed).
# Dicts: key = neopixel device name, value = index or comma-string of indices
variable_chamber_map: {}         # LED devices for chamber/enclosure feedback
variable_logo_map: {'toolhead': 1}       # LED devices for status logo (e.g., bed light or toolhead pixel)
variable_nozzle_map: {'toolhead': '2,3'} # LED devices for nozzle status

gcode: # Do not modify this section; variable-only macro
```

**Variable Types:**
- `chamber_map`: Lights up in sequence during `HEAT_SOAK` (red→green progress bar)
- `logo_map`: Fades during `HEAT_SOAK` and displays status color in `STATUS_*` macros
- `nozzle_map`: Always white during printing (via `SET_NOZZLE_LEDS_ON`) and status color otherwise

**Index Values:**
- Empty string `''` or `0`: Apply to the entire device (no INDEX parameter in SET_LED)
- Single integer `1`: Apply to specific LED index
- Comma-separated string `'2,3'`: Apply to multiple indices in sequence

### Helper Macro Pattern

Helper macros (`_SET_LOGO_LEDS`, `_SET_NOZZLE_LEDS`, `_SET_CHAMBER_LEDS`) iterate the dicts and apply colors:

```jinja
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

**Safety Pattern:**
- Always guard with `("neopixel " ~ name) in printer` before calling `SET_LED`
- Gracefully skip devices that don't exist on a given printer
- Empty dicts result in no-op (no errors)

## Heat Soak Animation

The `HEAT_SOAK` macro uses `_LED_VARS` to animate chamber LED progress and display status colors:

**Chamber LEDs (`chamber_map`):**
- Lights up sequentially from red → green as the soak progresses
- Uses device's `chain_count` (total LEDs) if indices are not specified
- If indices are explicitly provided, only those LEDs animate
- Progress bar fills from LED 1 to LED n as time elapses
- Smooth color fade: red (cold) at unlit LEDs → yellow (transition) at current LED → green (warm) at lit LEDs

**Logo LEDs (`logo_map`):**
- Fade from red → green alongside chamber animation (same color scale)
- Provides visual feedback without requiring multiple LED strips
- Useful on toolhead-only printers (animates the toolhead logo pixel)

**Animation Frame Rate:**
- Default: 12 FPS (`variable_frame_rate: 12` in `HEAT_SOAK`)
- Adjustable per printer via override in `printer.cfg`
- Smooth animation without excessive delays

## Printer Override Examples

### Simple Setup: Toolhead LEDs Only
**For single-toolhead printers (V0.3048, V0.3048, or any printer with only toolhead LEDs):**

```ini
# Add to printer.cfg:
[gcode_macro _LED_VARS]
variable_chamber_map: {}
variable_logo_map: {'toolhead': 1}
variable_nozzle_map: {'toolhead': '2,3'}
```

### Complete Setup: Toolhead + Bed + Chamber Strips
**For printers with bed light and chamber LED strips (e.g., V0.3048 with future chamber LEDs):**

```ini
[gcode_macro _LED_VARS]
variable_chamber_map: {'chamber_left': '', 'chamber_right': ''}
variable_logo_map: {'bed_light': '', 'toolhead': 1}
variable_nozzle_map: {'toolhead': '2,3'}
```

### Multi-Segment Chamber Strip
**For chamber strips with individually addressable LEDs (recommended for visual progress):**

```ini
[gcode_macro _LED_VARS]
variable_chamber_map: {'chamber_strip': '1,2,3,4,5,6,7,8'}  # Explicitly define indices for smooth animation
variable_logo_map: {'toolhead': 1}
variable_nozzle_map: {'toolhead': '2,3'}
```

### No Chamber Feedback (Minimal Setup)
**For printers with only status indicators (no chamber animation desired):**

```ini
[gcode_macro _LED_VARS]
variable_chamber_map: {}  # No chamber LEDs; HEAT_SOAK will run without animation
variable_logo_map: {'toolhead': 1}
variable_nozzle_map: {'toolhead': '2,3'}
```

## Configuration Steps

1. **Include `status_macros.cfg`** in your `printer.cfg`:
   ```ini
   [include nerdygriffin-macros/status_macros.cfg]
   ```

2. **Copy the `_LED_VARS` macro** from `macros/status_macros.cfg` to your `printer.cfg`

3. **Edit `_LED_VARS`** in your `printer.cfg` to match your LED hardware:
   - Replace device names with your actual neopixel section names
   - Adjust indices if your LEDs use non-default numbering

4. **Verify** with a test macro:
   ```gcode
   STATUS_HEATING
   STATUS_PRINTING
   STATUS_READY
   ```

## Implementation Status

✅ **Dict-based `_LED_VARS` system is fully implemented:**
- `_LED_VARS` macro defined in `macros/status_macros.cfg`
- `_SET_LOGO_LEDS`, `_SET_NOZZLE_LEDS`, `_SET_CHAMBER_LEDS` iterate dicts and safely skip missing devices
- All `STATUS_*` macros use the dict-based helpers
- `HEAT_SOAK` animates `chamber_map` with device-aware progress bar using `chain_count`

✅ **Old variable names (`variable_led_count`, `variable_*_indices`, etc.) have been replaced** with the dict-based system.

## What This Means for Users

1. **You only need to override `_LED_VARS` in your `printer.cfg`** - no other configuration required
2. **All macros automatically adapt** to your LED configuration - no per-macro changes needed
3. **Safe by design** - missing devices are skipped, extra devices are gracefully handled
4. **Future-proof** - new macros and animations automatically inherit `_LED_VARS` support

## Future Enhancements

Possible extensions to the LED system (not yet implemented):
- **Color palettes**: Add `variable_color_*` dicts (e.g., `ready_color`, `heating_color`) for per-printer color tuning
  - See `stealthburner_leds.cfg` for an example
