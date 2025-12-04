# Filament Management Configuration

## Customizing Parking Positions

The filament macros automatically detect AFC hardware and use appropriate parking positions. For non-AFC setups, you can customize the parking positions:

```ini
[gcode_macro _FILAMENT_PARK_PARAMS]
variable_load_x: 60.0          # X position for load/unload (None = auto: bed center)
variable_load_y: 10.0          # Y position for load/unload (None = auto: front + 10mm)
variable_purge_x: 10.0         # X position for purge (None = auto: 10mm)
variable_purge_y: 10.0         # Y position for purge (None = auto: front + 10mm)
```

**Note:** Set any coordinate to `None` to use automatic calculation based on your bed size. Z height is automatically calculated as 75% of max Z, rounded down to the nearest 10mm.

## Customizing Filament Distances

Override macro variables in your `printer.cfg`:

```ini
# Example: Adjust for your specific hotend
[gcode_macro LOAD_FILAMENT]
variable_load_distance: 60      # Distance to load (default: 60mm)
variable_purge_distance: 100    # Distance to purge (default: 100mm)

[gcode_macro UNLOAD_FILAMENT]
variable_unload_distance: 65    # Distance to unload (default: 65mm)
variable_purge_distance: 12.45  # Purge before unload (default: 12.45mm)
```
