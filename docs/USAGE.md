# Usage Guide

Common workflows and macro usage examples for klipper-nerdygriffin-macros.

---

## Status Macros

```gcode
STATUS_HEATING      # Red/orange LEDs, "Heating..." message
STATUS_HOMING       # Cyan LEDs, "Homing..." message
STATUS_LEVELING     # Purple LEDs, "Leveling..." message
STATUS_MESHING      # Lime LEDs, "Meshing..." message
STATUS_CLEANING     # Blue LEDs, "Cleaning..." message
STATUS_PRINTING     # Blue logo, white nozzle, white chamber, no message
STATUS_READY        # Dim white LEDs, no message
STATUS_OFF          # All LEDs off, no message
RESET_STATUS        # Auto-select PRINTING or READY based on printer state
```

All status macros automatically respect your `_LED_VARS` configuration and adapt to your printer's LED setup.

---

## Filament Operations

```gcode
LOAD_FILAMENT                    # Load with default temp
LOAD_FILAMENT TEMP=240           # Load at specific temp
UNLOAD_FILAMENT                  # Unload with default temp
UNLOAD_FILAMENT TEMP=240         # Unload at specific temp
PURGE_FILAMENT                   # Purge 100mm
PURGE_FILAMENT TEMP=230 SPEED=200  # Custom purge
```

---

## PID Calibration

```gcode
AUTO_PID_CALIBRATE HEATER=extruder TARGET=260
AUTO_PID_CALIBRATE HEATER=heater_bed TARGET=100
```

---

## Shutdown Operations

```gcode
SHUTDOWN                         # Immediate shutdown
SAFE_SHUTDOWN                    # Shutdown with safety checks
SET_COMPLETE_SHUTDOWN ENABLE=1   # Enable post-print shutdown
CONDITIONAL_SHUTDOWN             # Shutdown if enabled
```

---

## Preflight Check

```gcode
PREFLIGHT_CHECK                  # Check part cooling fan before print
```

---

## Utility Macros

```gcode
DEEP_CLEAN_NOZZLE                # Deep clean with temp stepping
DEEP_CLEAN_NOZZLE TEMP=280       # Start cleaning from specific temp
CENTER                           # Move toolhead to bed center
UNSAFE_LOWER_BED                 # Emergency: lower bed 10mm without homing
```

---

## Heat Soak

```gcode
HEAT_SOAK CHAMBER=50 DURATION=10 # Heat soak chamber to 50C for 10 minutes
M191 S50                          # Marlin-style chamber wait (uses HEAT_SOAK)
```

---

## Safe Config Saving

```gcode
SAFE_SAVE_CONFIG                 # Save config with safety checks
SET_COMPLETE_SAVE_CONFIG ENABLE=1  # Enable post-print save
CONDITIONAL_SAVE_CONFIG          # Save if enabled (called automatically)
```

---

## Belt Tension Settling

```gcode
SETTLE_BELT_TENSION              # Run belt settling routine at default speeds
SETTLE_BELT_TENSION SPEED=400    # Custom speed
SETTLE_BELT_TENSION ITERATIONS=3 # More iterations for extra settling
```

---

## Automatic Features (Not Called Directly)

These features are triggered automatically by print lifecycle events:

- `ENABLE_ENCODER_SENSOR` - Auto-enables filament encoder sensor after delay
- `DISABLE_ENCODER_SENSOR` - Auto-disables filament encoder sensor on startup
- `_AFTER_PAUSE` - Triggered by Mainsail/Fluidd PAUSE command
- `_BEFORE_RESUME` - Triggered by Mainsail/Fluidd RESUME command
- `_BEFORE_CANCEL` - Triggered by Mainsail/Fluidd CANCEL_PRINT command
