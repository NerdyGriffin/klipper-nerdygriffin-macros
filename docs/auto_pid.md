# Auto PID Calibration (auto_pid.cfg)

The `auto_pid.cfg` provides convenient macros for tuning PID parameters for your extruder and bed heaters.

## Usage

```gcode
AUTO_PID_CALIBRATE HEATER=extruder TARGET=260    # Calibrate extruder at 260°C
AUTO_PID_CALIBRATE HEATER=heater_bed TARGET=100  # Calibrate bed at 100°C
```

### AUTO_PID_CALIBRATE Parameters

| parameters | default value | description |
|-----------:|---------------|-------------|
| HEATER | extruder | Heater name to calibrate (`extruder` or `heater_bed`) |
| TARGET | 250 | Target temperature in °C for the calibration test |

> **Warning**:
>
> During PID calibration, the heater will cycle multiple times to find optimal parameters. **Keep the printer supervised** and ensure adequate ventilation. Do not leave unattended during this process.
