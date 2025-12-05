# Filament Management (filament_management.cfg)

The filament management macros provide hardware-agnostic loading, unloading, and purging operations with automatic AFC (Automated Filament Control) detection and safe parking.

## Usage

```gcode
LOAD_FILAMENT           # Load filament into hotend
UNLOAD_FILAMENT         # Unload filament from hotend
PURGE_FILAMENT          # Purge a small amount of filament
```

> **Note**:
>
> Temperature is automatically determined from `printer.extruder.target`. Set target temperature via your frontend (Mainsail/Fluidd) or KlipperScreen before calling these macros.

These macros automatically detect AFC hardware and use appropriate parking positions.

## Configuration

To customize shared parking positions for all filament macros:

```ini
[gcode_macro _FILAMENT_PARK_PARAMS]
variable_load_x: 60.0    # X position for load/unload (None = auto: bed center)
variable_load_y: 10.0    # Y position for load/unload (None = auto: front + 10mm)
variable_purge_x: 10.0   # X position for purge (None = auto: 10mm)
variable_purge_y: 10.0   # Y position for purge (None = auto: front + 10mm)
```

Set any coordinate to `None` to use automatic calculation based on your bed size. Z height is automatically calculated as 75% of max Z, rounded down to the nearest 10mm.

To adjust filament distances for your specific hotend:

```ini
[gcode_macro LOAD_FILAMENT]
variable_load_distance: 50      # Adjust for your hotend (default: 60mm)
variable_purge_distance: 150    # Increase purge amount (default: 100mm)

[gcode_macro UNLOAD_FILAMENT]
variable_unload_distance: 70    # Adjust for your hotend (default: 65mm)
```

> **Note**:
>
> Only override variables that differ from defaults. See the macro definitions in `filament_management.cfg` for all available options and default values.
