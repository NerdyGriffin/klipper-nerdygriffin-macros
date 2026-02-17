# Optional G-Code Features (gcode_features.cfg)

Enables useful Klipper features for advanced G-code support and compatibility.

## Usage

These sections are enabled automatically when you include `gcode_features.cfg`:

- `FORCE_MOVE` and `SET_KINEMATIC_POSITION` for manual toolhead moves and position setting
- `PAUSE`/`RESUME`/`CANCEL_PRINT` for filament changes and macro pause/resume
- `FIRMWARE_RETRACTION` (G10/G11) for hardware-independent retraction
- `GCODE_ARCS` (G2/G3) for arc moves
- `RESPOND` (M118) for console messages
- `EXCLUDE_OBJECT` for object exclusion during print

### Macros

```gcode
UNSAFE_LOWER_BED [DISTANCE=10]    # Lower the bed without homing (uses SET_KINEMATIC_POSITION)
```

- `UNSAFE_LOWER_BED` — Emergency recovery macro. Bypasses homing by faking Z=0 with `SET_KINEMATIC_POSITION`, then lowers the bed by `DISTANCE` mm and disables motors. Use when the printer is in an unknown state and you need to clear the nozzle from the bed.

| parameters | default value | description |
|-----------:|---------------|-------------|
| DISTANCE | 10 | Distance to lower the bed (mm) |

## Configuration

No configuration is required. All features are enabled by default when this file is included.

> **Note**:
>
> These features are safe to include on any printer and do not conflict with other macros.
