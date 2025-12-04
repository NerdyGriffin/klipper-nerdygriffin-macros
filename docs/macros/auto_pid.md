# Auto PID Calibration (auto_pid.cfg)

The `auto_pid.cfg` provides convenient macros for tuning PID parameters for your extruder and bed heaters.

### Usage

```gcode
AUTO_PID_CALIBRATE HEATER=extruder TARGET=260    # Calibrate extruder at 260°C
AUTO_PID_CALIBRATE HEATER=heater_bed TARGET=100  # Calibrate bed at 100°C
```

**Note:** During PID calibration, the heater will cycle multiple times to find optimal parameters. Keep the printer supervised and ensure adequate ventilation.
