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

No user-facing macros are defined; these features extend Klipper's built-in G-code support.

## Configuration

No configuration is required. All features are enabled by default when this file is included.

> **Note**:
>
> These features are safe to include on any printer and do not conflict with other macros.
