# Filament Sensors (filament_sensors.cfg)

The `filament_sensors.cfg` file defines the two sensors of a
[BTT SFS V2.0](https://github.com/bigtreetech/smart-filament-detection-module):

- `[filament_switch_sensor switch_sensor]` — the filament-presence microswitch. It only reports
  (`M117` plus `RESET_STATUS`) and never pauses.
- `[filament_motion_sensor encoder_sensor]` — the encoder wheel, for flow and clog detection.
  When it stops seeing motion it pauses via `_PAUSE_IF_PRINTING`, but only while `switch_sensor`
  still sees filament (a jam). If the switch is clear, the spool tail has left the unit, so it
  only posts a message and lets the tail run on to a toolhead sensor.

The toolhead switch (e.g. `extruder_tool_start`) is expected to own the runout pause. Neither
sensor here pauses on a plain runout.

## Configuration

The shared file leaves out `switch_pin`; Klipper refuses to start until you set both. Add them
to the overrides file you include **after** `filament_sensors.cfg`:

```ini
[filament_switch_sensor switch_sensor]
switch_pin: ^YOUR_SWITCH_PIN

[filament_motion_sensor encoder_sensor]
switch_pin: YOUR_ENCODER_PIN
```

Point the shared macros at the encoder so they enable it during prints and disable it during
filament operations, pauses and idle time (see [filament_management.md](filament_management.md)):

```ini
[gcode_macro _FILAMENT_SENSOR_VARS]
variable_motion_sensor: "filament_motion_sensor encoder_sensor"
```

Any other option (e.g. `detection_length`, default `20`) can be overridden the same way.

## Dependencies

- `filament_management.cfg` — `_PAUSE_IF_PRINTING`
- `status_macros.cfg` — `RESET_STATUS`
