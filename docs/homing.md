# Homing Utilities (homing.cfg)

Provides hardware-agnostic homing helpers for sensorless homing, edge clearance, and conditional homing logic.

## Usage

```gcode
_CG28                  # Home only if not already homed
_HOME_PRE_AXIS AXIS=X  # Pre-homing setup for X (adjusts current, fans, etc.)
_HOME_POST_AXIS AXIS=X # Post-homing restore for X
TEST_SENSORLESS_HOME_X TEST_SGTHRS=255  # Test sensorless X homing sensitivity
TEST_SENSORLESS_HOME_Y TEST_SGTHRS=255  # Test sensorless Y homing sensitivity
```

### \_HOME_PRE_AXIS Parameters

| parameters | default value | description                             |
| ---------: | ------------- | --------------------------------------- |
|       AXIS | None          | Axis to prepare for homing (X, Y, or Z) |

### \_HOME_POST_AXIS Parameters

| parameters | default value | description                               |
| ---------: | ------------- | ----------------------------------------- |
|       AXIS | None          | Axis to restore after homing (X, Y, or Z) |

### TEST_SENSORLESS_HOME_X / Y Parameters

|  parameters | default value | description                                     |
| ----------: | ------------- | ----------------------------------------------- |
| TEST_SGTHRS | 255           | StallGuard threshold for sensorless homing test |

## Internal Macros

- `_HOME_EDGE_CLEARANCE` - Moves toolhead away from edges before homing
- `_HOME_VARS` - Stores shared homing variables (e.g., current)

## Configuration

Override homing current in your `printer.cfg`:

```ini
[gcode_macro _HOME_VARS]
variable_home_current: 0.7  # Set sensorless homing current (default: 0.7A)
```

## Examples

### Sensorless Homing Tuning

```gcode
TEST_SENSORLESS_HOME_X TEST_SGTHRS=220
TEST_SENSORLESS_HOME_Y TEST_SGTHRS=210
```

> **Note**:
>
> These macros are helpers for advanced homing and tuning workflows. Most users only need `_CG28` for safe, conditional homing.
