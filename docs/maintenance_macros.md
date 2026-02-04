# Maintenance Macros (maintenance_macros.cfg)

The maintenance macros provide utilities for printer maintenance tasks like belt tension settling and nozzle changes.

## Belt Frequency Reference

Use this table to determine your target belt frequency based on belt span (distance between idler centers):

| Belt Span | Target Frequency |
| --------- | ---------------- |
| 150mm     | 110 Hz           |
| 140mm     | 118 Hz           |
| 130mm     | 127 Hz           |
| 120mm     | 138 Hz           |

## Usage

```gcode
SETTLE_BELT_TENSION    # Run belt settling routine, then park at calibrated position
```

This macro moves the toolhead through its full range of motion, then parks at a pre-calibrated Y position to enable accurate belt tension measurement using external tools.

## Configuration

Override the calibrated Y position in your `printer.cfg`:

```ini
[gcode_macro SETTLE_BELT_TENSION]
variable_y_calibrated: 116  # Your printer's calibrated Y position (default: 120)
```

**Common Values:**

- V0 (120mm bed): `y_calibrated: 116`
- Trident 300mm: `y_calibrated: 120`

## Calibration Steps

1. Measure the distance between your belt idler centers
2. Use the frequency table above to find your target frequency
3. Run `SETTLE_BELT_TENSION` to park the toolhead at your calibrated position
4. Measure actual belt frequency using external tools (microphone with Spectroid app, tension gauge, etc.)
5. Adjust `variable_y_calibrated` until your measured frequency matches the target

> **Note**:
>
> Actual frequency depends on belt tension. Adjust tension first, then verify frequency matches target.
