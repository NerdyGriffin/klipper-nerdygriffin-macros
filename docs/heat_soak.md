# Heat Soak (heat_soak.cfg)

The `HEAT_SOAK` macro provides hardware-agnostic chamber preheating with optional LED animations. It uses a Nevermore controller as the chamber sensor when one is present, otherwise the sensor named in `_CLIENT_VARIABLE`, and supports per-printer customization.

## Usage

```gcode
HEAT_SOAK [CHAMBER=50] [DURATION=10]  # Heat soak chamber to 50°C for 10 minutes
M191 S50                               # Marlin-style chamber wait (uses HEAT_SOAK)
```

### HEAT_SOAK Parameters

| parameters | default value | description |
| ---: | --- | --- |
| CHAMBER | None | Target chamber temperature in °C. If not specified, calculates target based on bed temperature. |
| DURATION | 5 | Soak duration in minutes (0 = wait until chamber reaches target) |

## Configuration

Override these variables in your `printer.cfg`:

```ini
[gcode_macro HEAT_SOAK]
variable_max_chamber_target: 58           # Maximum chamber temp achievable via passive heating
variable_ext_assist_multiplier: 5       # Extruder assist temp multiplier (chamber_temp × multiplier, capped at 200°C)
variable_frame_rate: 12                 # LED animation frame rate in Hz
```

### Chamber Sensor

1. `[nevermore]` controller, if present — temperature is `intake_temperature`, falling back to `exhaust_temperature`,
   then 0 until the controller reports; waits with `NEVERMORE_TEMPERATURE_WAIT MINIMUM=<target> UNAVAILABLE_TIMEOUT=120`
   (if the Nevermore is not connected within 120 s the wait is skipped). Automatic vent control is stopped and the vent
   closed first (see [nevermore.md](nevermore.md)).
2. Otherwise `_CLIENT_VARIABLE.chamber_sensor` (default `"temperature_sensor chamber"`, see
   [status_macros.md](status_macros.md#chamber-sensor)) — waits with `TEMPERATURE_WAIT` if that object exists

With neither, the chamber wait is skipped and only the soak countdown runs.

`notify_bed_cooled` in `status_macros.cfg` reads the same `_CLIENT_VARIABLE.chamber_sensor` (never the Nevermore
object directly) for its bed-cooled threshold.

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
variable_max_chamber_target: 58           # V0 measured limit
variable_ext_assist_multiplier: 5       # Stronger extruder assist for V0
```

### Toolhead-Only Temperature Sensing

For printers with toolhead-only sensors, point the shared chamber sensor variable at the toolboard sensor:

```ini
[gcode_macro _CLIENT_VARIABLE]
variable_chamber_sensor: "temperature_sensor nitehawk-36"  # Use toolhead as temperature proxy
```
