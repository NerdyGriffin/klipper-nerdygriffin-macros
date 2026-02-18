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

## Configuration

### Filament distances

Override in your `printer.cfg` to match your hotend:

```ini
[gcode_macro LOAD_FILAMENT]
variable_load_distance: 60      # Adjust for your hotend (default: 50mm)
variable_purge_distance: 50     # Increase purge amount (default: 25mm)

[gcode_macro UNLOAD_FILAMENT]
variable_unload_distance: 70    # Adjust for your hotend (default: 50mm)
```

### Parking positions

Park position priority (highest to lowest):

1. `_TOOLHEAD_PARK_VARS` explicit coordinates (if both X and Y are set)
2. `_CLIENT_VARIABLE.use_custom_pos` (Mainsail's park position setting)
3. AFC brush location (if `_AFC_BRUSH_VARS` is defined)
4. Auto-calculated: center X / front Y for load; X=10 / front Y for purge

To set explicit park positions:

```ini
[gcode_macro _TOOLHEAD_PARK_VARS]
variable_custom_load_x: 60.0    # X for load/unload (None = auto: bed center)
variable_custom_load_y: 10.0    # Y for load/unload (None = auto: front + 10mm)
variable_custom_purge_x: 10.0   # X for purge (None = auto: 10mm)
variable_custom_purge_y: 10.0   # Y for purge (None = auto: front + 10mm)
```

Set any coordinate to `None` to fall through to the next priority level.
Z height is automatically calculated as 75% of max Z, rounded down to the nearest 10mm.

> **Note**:
>
> Only override variables that differ from defaults. See the macro definitions in `filament_management.cfg` for all available options and default values.

## Internal Macros

These macros are called automatically and should not be invoked directly:

### Operation lifecycle

- `_FILAMENT_OPERATION_INIT` — Common initialization: saves gcode state, disables encoder sensor, determines extruder temperature (with idle-timeout restore), homes if needed, and starts heating
- `_FILAMENT_OPERATION_CLEANUP` — Common cleanup: parks toolhead, re-enables encoder sensor (if it was enabled), restores gcode state, and emits a completion beep
- `_HEAT_AND_PARK` — Parks the toolhead then waits for extruder temperature (`M109`)

### Parking helpers

- `_TOOLHEAD_PARK_LOAD_UNLOAD MODE=load|purge` — Resolves park position via the priority chain above and moves there. Z park is skipped when paused or printing.
- `_TOOLHEAD_PARK_PURGE` — Thin wrapper: calls `_TOOLHEAD_PARK_LOAD_UNLOAD MODE=purge`

### Retraction helpers

- `_CONDITIONAL_RETRACT` — Retracts filament if the extruder can extrude (temperature is sufficient)
- `_CONDITIONAL_UNRETRACT` — Unretracts filament if a retract was previously recorded

### Delayed G-code Macros

- `ENABLE_ENCODER_SENSOR` — Enables the filament encoder sensor for motion detection
- `DISABLE_ENCODER_SENSOR` — Disables encoder sensor (runs 1 second after startup to prevent false triggers)

> **Note**:
>
> `ENABLE_ENCODER_SENSOR` and `DISABLE_ENCODER_SENSOR` are automatically called by `client.cfg` and `print_macros.cfg` at appropriate times. You typically don't need to call them directly unless implementing custom print workflows.
