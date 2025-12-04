# Save Config (save_config.cfg)

The `save_config.cfg` provides utilities for safely saving printer configuration.

## Usage

```gcode
SAVE_CONFIG              # Save configuration immediately
SAVE_CONFIG_DELAYED      # Schedule configuration save (useful to avoid Klipper restart loops)
```

## Delayed Save

Use `SAVE_CONFIG_DELAYED` when making multiple configuration changes that might cause restart loops. It schedules the save to occur after a delay, allowing time for other operations to complete.
