# Nevermore Macros (nevermore.cfg)

The `nevermore.cfg` file automates the vent servo of a [Nevermore controller](https://github.com/SanaaHamel/nevermore-controller).
The controller already manages its own fan (print mode, VOC-driven automatic policy and post-print cooldown); these
macros only decide the vent position. Every macro is a no-op when no `[nevermore]` section exists.

## Policy

While automatic control is active the policy is evaluated every `poll_interval` seconds:

- **During a print** (chamber target above 0) temperature alone decides, proportionally: the vent is **closed** at or
  below the target and opens by `kp / 255` per °C above it, so it is **fully open** `255 / kp` °C above the target
  (5.1 °C with the default `kp: 50`). The target is a floor: heat is never vented below it. The servo only moves when
  the position changes by at least `min_step`, except to reach fully open or fully closed. The VOC index is ignored.
- **At idle** (target 0) the VOC index alone decides: **close** when the exhaust VOC index reaches `voc_vent_max`,
  **open** once it falls below `voc_vent_max - voc_max_delta`. Temperature is ignored.

Between the two idle thresholds the vent stays where it is; a vent left partly open by a print is driven fully open
or closed once one of them is crossed.

`kp` uses the same scaling as Klipper's PID gains (`PID_PARAM_BASE`, 255), so it is the same order of magnitude as a
heater or `temperature_fan` `pid_Kp`. There is no integral term, which is why the band sits above the target instead
of below it as in `temperature_fan`. Set `kp: 0` for plain open/closed control: **open** above the target by `temp_max_delta`,
**close** below it by `temp_max_delta`.

The intake sensor sits in the chamber, so it is the chamber temperature. The exhaust sensor sits after the filter, so
it measures the air the vent would actually release; the idle policy falls back to the intake sensor if there is no exhaust sensor.

The chamber target comes from the slicer's `CHAMBER` value via `PRINT_START`, so filament type is implicit: a PLA
print in a closed enclosure (target ~30 °C) opens the vent once the chamber warms up, an ABS print (target 50–60 °C)
never does. The VOC index is relative to a baseline the sensors learn at idle, so it reads high during any print;
gating on it there would keep the vent shut on exactly the low-temperature materials that need the cooling, while
high-temperature materials are already held closed by their chamber target. `PRINT_END` (or a cancel) sets the target back to 0, the idle policy:
the controller filters first and the vent opens once the VOC index drops below `voc_vent_max - voc_max_delta`.

Automatic control starts at boot when `auto_start` is set and runs continuously. The controller reports no servo
position, so the first evaluation after a restart always commands the vent, putting the servo in a known state.

## Usage

```gcode
NEVERMORE_VENT_AUTO CHAMBER=30   # Start automatic control for a 30 °C chamber target
NEVERMORE_VENT_AUTO              # Start automatic control with the idle target (0 °C)
NEVERMORE_VENT_AUTO_OFF          # Stop automatic control, leave the vent as-is
NEVERMORE_OPEN_VENT              # Manual open
NEVERMORE_CLOSE_VENT             # Manual close
NEVERMORE_SET_VENT POSITION=0.5  # Manual position, 0 closed - 1 open
```

`PRINT_START`, `PRINT_END`, `_BEFORE_CANCEL`, `HEAT_SOAK` and `M141` / `M191` call these automatically when the file is included:

- `M141 S<target>` sets the chamber target, the same as `NEVERMORE_VENT_AUTO CHAMBER=<target>`; `M141 S0` returns to the idle policy.
- `HEAT_SOAK` stops automatic control and closes the vent before heating, then resumes automatic control at the
  target that was set before it started. Run on its own at idle it therefore returns to the idle policy; `M191 S<target>`
  sets the target first (via `M141`), so its soak resumes at that target.

## Configuration

Override any variable in `printer.cfg`:

```ini
[gcode_macro _NEVERMORE_VARS]
variable_voc_vent_max: 250        # Idle VOC index ceiling for opening (100 = learned baseline)
variable_voc_max_delta: 5         # Hysteresis below voc_vent_max (VOC index points)
variable_kp: 50                   # Proportional gain during a print (fully open 255 / kp C above target); 0 = open/closed
variable_min_step: 0.1            # Smallest change in vent position (0-1) worth moving the servo for
variable_temp_max_delta: 3        # Hysteresis around the chamber target (C); only used with kp: 0
variable_poll_interval: 30        # Seconds between evaluations
variable_auto_start: True         # Start automatic control at boot
variable_vent_open_percent: 0     # Servo position for open (swap with closed to reverse)
variable_vent_closed_percent: 1   # Servo position for closed
```

`vent_position` (0 closed – 1 open) and `vent_open` (`vent_position > 0`) track the last commanded state; moving the vent by hand or with `NEVERMORE_VENT_SERVO_SET` directly leaves them stale until the next vent macro runs.
