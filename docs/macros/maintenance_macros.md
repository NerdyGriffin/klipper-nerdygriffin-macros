
# Belt Tension Calibration (maintenance_macros.cfg)

The `SETTLE_BELT_TENSION` macro parks at a calibrated Y position for belt frequency measurement. Override the position in your `printer.cfg`:

```ini
[gcode_macro SETTLE_BELT_TENSION]
variable_y_calibrated: 116  # Override with your printer's calibrated Y position
```

## Frequency Reference Table

Use this table to determine your target belt frequency based on your printer's geometry:

| Belt Span | Target Frequency |
|-----------|------------------|
| 150mm     | 110 Hz           |
| 140mm     | 118 Hz           |
| 130mm     | 127 Hz           |
| 120mm     | 138 Hz           |

## Calibration Steps

1. Measure the distance between your belt idler centers
2. Use the table above to find your target frequency
3. Run `SETTLE_BELT_TENSION` to park the toolhead at your calibrated position
4. Use input shaper analysis to measure actual belt frequency
5. Adjust `variable_y_calibrated` until your measured frequency matches the target

**Common Values:**
- V0 (120mm bed): `y_calibrated: 116`
- Trident 300mm: `y_calibrated: 120`

**Note:** Actual frequency will depend on belt tension, so adjust tension first, then verify frequency matches target.
