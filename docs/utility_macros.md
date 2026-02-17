# Utility Macros (utility_macros.cfg)

The `utility_macros.cfg` provides helper macros for common operations like deep cleaning, centering, and emergency bed lowering.

## Usage

```gcode
DEEP_CLEAN_NOZZLE [TEMP=260]     # Deep clean with temperature stepping
CENTER                           # Move toolhead to bed center
UNSAFE_LOWER_BED                 # Emergency: lower bed 10mm without homing
```

### DEEP_CLEAN_NOZZLE Parameters

| parameters | default value | description |
|-----------:|---------------|-------------|
| TEMP | max_temp - 20°C | Starting temperature for cleaning cycle |

The macro steps down temperature in 20°C increments, cleaning at each step until reaching 160°C. It automatically uses `AFC_BRUSH` if available, otherwise falls back to `CLEAN_NOZZLE`.

## Internal Macros

These macros are called automatically by other macros and should not be called directly:

> **Note**:
>
> `_CONDITIONAL_RETRACT` and `_CONDITIONAL_UNRETRACT` are defined in `filament_management.cfg`, not `utility_macros.cfg`. They are listed here because `utility_macros.cfg` macros call them when available.

### Delayed G-code Macros

The following delayed G-code macros manage the encoder sensor state:

- `ENABLE_ENCODER_SENSOR` - Enables the filament encoder sensor for motion detection
- `DISABLE_ENCODER_SENSOR` - Disables encoder sensor (runs 1 second after startup to prevent false triggers)

> **Note**:
>
> These macros are automatically called by `filament_management.cfg`, `client_macros.cfg`, and `print_macros.cfg` at appropriate times. You typically don't need to call them directly unless implementing custom print workflows.
