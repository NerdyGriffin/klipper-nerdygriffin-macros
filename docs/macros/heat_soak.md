# Heat Soak Configuration (heat_soak.cfg)

The `HEAT_SOAK` macro provides hardware-agnostic chamber preheating with optional LED animations. It auto-detects chamber temperature sensors and supports per-printer customization.

## Default Variables

- `variable_max_chamber_temp: 60` - Maximum chamber temp achievable via passive heating
- `variable_ext_assist_multiplier: 4` - Extruder assist temp multiplier (chamber_temp × multiplier, capped at 200°C)
- `variable_chamber_sensor_name: ""` - Explicit sensor name (empty = auto-detect)
- `variable_frame_rate: 12` - LED animation frame rate in Hz

## Auto-Detection Logic

The macro searches for chamber sensors in this order:
1. Explicit `chamber_sensor_name` (if provided)
2. `temperature_sensor chamber`
3. `temperature_sensor nitehawk-36` (toolhead proxy)

## Example Overrides

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

## LED Animation

- Uses `_LED_VARS` dict-based system (see [`LED_SETUP.md`](../LED_SETUP.md))
- `chamber_map`: Animates chamber/enclosure LEDs with red→green progress bar
- `logo_map`: Fades logo/bed light from red→green alongside chamber animation
- Safe by design: missing devices are automatically skipped
