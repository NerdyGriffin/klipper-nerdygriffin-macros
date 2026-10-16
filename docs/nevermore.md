# Nevermore Macros (nevermore.cfg)

The `nevermore.cfg` file automates the vent servo of a [Nevermore controller](https://github.com/SanaaHamel/nevermore-controller).
The controller already manages its own fan (print mode, VOC-driven automatic policy and post-print cooldown); these
macros only decide whether the vent is open or closed. Every macro is a no-op when no `[nevermore]` section exists.

## Policy

While automatic control is active the policy is evaluated every `poll_interval` seconds:

- **Open** when the intake temperature exceeds the chamber target by `margin` **and** the higher of the intake/exhaust VOC index is below `voc_vent_max`.
- **Close** when the intake temperature drops below the target by `margin` **or** the VOC index reaches `voc_vent_max`.

The chamber target comes from the slicer's `CHAMBER` value via `PRINT_START`, so filament type is implicit: a PLA
print in a closed enclosure (target ~30 °C) opens the vent once the chamber warms up, an ABS print (target 50–60 °C)
never does. `PRINT_END` (or a cancel) sets the target back to 0, the idle policy: the chamber is always above 0 °C, so
the controller filters first and the vent opens once the VOC index drops below `voc_vent_max`.

Automatic control starts at boot when `auto_start` is set and runs continuously. The controller reports no servo
position, so the first evaluation after a restart always commands the vent, putting the servo in a known state.

## Usage

```gcode
NEVERMORE_VENT_AUTO CHAMBER=30   # Start automatic control for a 30 °C chamber target
NEVERMORE_VENT_AUTO              # Start automatic control with the idle target (0 °C)
NEVERMORE_VENT_AUTO_OFF          # Stop automatic control, leave the vent as-is
NEVERMORE_OPEN_VENT              # Manual open
NEVERMORE_CLOSE_VENT             # Manual close
```

`PRINT_START`, `PRINT_END`, `_BEFORE_CANCEL` and `HEAT_SOAK` call these automatically when the file is included (`HEAT_SOAK` stops automatic control and closes the vent before heating).

## Configuration

Override any variable in `printer.cfg`:

```ini
[gcode_macro _NEVERMORE_VARS]
variable_voc_vent_max: 150        # VOC index ceiling for opening (100 = learned baseline)
variable_margin: 3                # Hysteresis around the chamber target (C)
variable_poll_interval: 30        # Seconds between evaluations
variable_auto_start: True         # Start automatic control at boot
variable_vent_open_percent: 0     # Servo position for open (swap with closed to reverse)
variable_vent_closed_percent: 1   # Servo position for closed
```

`vent_open` tracks the last commanded state; moving the vent by hand or with `NEVERMORE_VENT_SERVO_SET` directly leaves it stale until the next open/close macro runs.
