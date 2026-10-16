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
variable_unload_distance: 96.8  # Adjust for your hotend (default: 100mm)
```

### Filament motion sensor

The shared macros disable the filament motion (encoder) sensor during filament operations,
pauses and idle time, and enable it once a print is running. The sensor is looked up by name
and every call goes through `_SET_MOTION_SENSOR`, which does nothing if the sensor is not
configured. The default is `""` (no sensor), so set the full object name in your `printer.cfg`
to enable it:

```ini
[gcode_macro _FILAMENT_SENSOR_VARS]
variable_motion_sensor: "filament_motion_sensor encoder_sensor"  # default: "" (all sensor calls skipped)
```

### Auto-load on insert

`_AUTO_LOAD_FILAMENT` is a minimal stand-in for AFC's auto-load on printers without a
multi-material unit. Call it from the `insert_gcode` of a toolhead filament sensor:

```ini
[filament_switch_sensor extruder_tool_start]
switch_pin: ^nhk:gpio3
insert_gcode:
    _AUTO_LOAD_FILAMENT
```

When the extruder is at or above `min_extrude_temp` it feeds `load_distance` at
`load_speed` with the toolhead acceleration temporarily capped to `load_accel`, then
confirms against `end_sensor` if that sensor exists. The defaults match AFC's standalone
auto-load. When the extruder is cold it only posts a message. It does nothing while a
print is running, or when AFC is installed. Klipper itself only fires `insert_gcode`
while the printer is idle or paused.

```ini
[gcode_macro _AUTO_LOAD_FILAMENT]
variable_load_distance: 72      # Toolhead sensor to nozzle tip (default: 72mm)
variable_load_speed: 25         # mm/s (default: 25)
variable_load_accel: 5          # mm/s^2 (default: 5)
variable_end_sensor: "filament_switch_sensor extruder_tool_end"  # "" to skip confirmation
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

- `_FILAMENT_OPERATION_INIT` — Common initialization: saves gcode state, disables the motion sensor, determines extruder temperature (with idle-timeout restore), homes if needed, and starts heating
- `_FILAMENT_OPERATION_CLEANUP` — Common cleanup: parks toolhead, re-enables the motion sensor (if it was enabled), restores gcode state, and emits a completion beep
- `_HEAT_AND_PARK` — Parks the toolhead then waits for extruder temperature (`M109`)
- `_SET_MOTION_SENSOR ENABLE=0|1` — Toggles the sensor named in `_FILAMENT_SENSOR_VARS`; silently does nothing if the name is empty or the sensor does not exist. Other files call it guarded on `is defined`, so they work without this file

### Parking helpers

- `_TOOLHEAD_PARK_LOAD_UNLOAD MODE=load|purge` — Resolves park position via the priority chain above and moves there. Z park is skipped when paused or printing.
- `_TOOLHEAD_PARK_PURGE` — Thin wrapper: calls `_TOOLHEAD_PARK_LOAD_UNLOAD MODE=purge`

### Retraction helpers

- `_CONDITIONAL_RETRACT` / `_CONDITIONAL_UNRETRACT` live in [revo.cfg](revo.md); the load, unload and purge macros only update their `needs_unretract` state when that file is included

### Auto-load helpers

- `_AUTO_LOAD_FILAMENT` — Feeds inserted filament to the nozzle when the extruder is hot; intended for a toolhead sensor's `insert_gcode`
- `_AUTO_LOAD_FILAMENT_CHECK` — Reads the end sensor after the feed finishes and reports success or failure

### Delayed G-code Macros

- `ENABLE_ENCODER_SENSOR` — Enables the motion sensor via `_SET_MOTION_SENSOR`
- `DISABLE_ENCODER_SENSOR` — Disables the motion sensor via `_SET_MOTION_SENSOR` (runs 1 second after startup to prevent false triggers)

> **Note**:
>
> `ENABLE_ENCODER_SENSOR` and `DISABLE_ENCODER_SENSOR` are automatically called by `client.cfg` and `print_macros.cfg` at appropriate times. You typically don't need to call them directly unless implementing custom print workflows.
