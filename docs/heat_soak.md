# Heat Soak (heat_soak.cfg)

The `HEAT_SOAK` macro provides hardware-agnostic chamber preheating with optional LED animations. It auto-detects chamber temperature sensors and supports per-printer customization.

## Usage

```gcode
HEAT_SOAK [CHAMBER=50] [DURATION=10]  # Heat soak chamber to 50°C for 10 minutes
M191 S50                               # Marlin-style chamber wait (uses HEAT_SOAK)
```

### HEAT_SOAK Parameters

| parameters | default value | description |
|-----------:|---------------|-------------|
| CHAMBER | None | Target chamber temperature in °C. If not specified, calculates target based on bed temperature. |
| DURATION | 0 | Soak duration in minutes (0 = wait until chamber reaches target) |

## Configuration

Override these variables in your `printer.cfg`:

```ini
[gcode_macro HEAT_SOAK]
variable_max_chamber_temp: 58           # Maximum chamber temp achievable via passive heating
variable_ext_assist_multiplier: 5       # Extruder assist temp multiplier (chamber_temp × multiplier, capped at 200°C)
variable_chamber_sensor_name: "chamber" # Explicit sensor name (empty = auto-detect)
variable_frame_rate: 12                 # LED animation frame rate in Hz
```

### Chamber Sensor Auto-Detection

The macro searches for chamber sensors in this order:
1. Explicit `chamber_sensor_name` (if provided)
2. `temperature_sensor chamber`
3. `temperature_sensor nitehawk-36` (toolhead proxy)

### LED Animation

The `HEAT_SOAK` macro uses the `_LED_VARS` dict-based system (see [status_macros.md](status_macros.md)):
- `chamber_map`: Animates chamber/enclosure LEDs with red→green progress bar
- `logo_map`: Fades logo/bed light from red→green alongside chamber animation
- Safe by design: missing devices are automatically skipped

## Examples

### V0 Setup (Measured Limits)

For V0 printers with measured thermal limits and stronger extruder assist:

```ini
[gcode_macro HEAT_SOAK]
variable_max_chamber_temp: 58           # V0 measured limit
variable_ext_assist_multiplier: 5       # Stronger extruder assist for V0
variable_chamber_sensor_name: "chamber" # Explicit sensor name (if available)
```

### Toolhead-Only Temperature Sensing

For printers with toolhead-only sensors:

```ini
[gcode_macro HEAT_SOAK]
variable_chamber_sensor_name: "nitehawk-36"  # Use toolhead as temperature proxy
```
