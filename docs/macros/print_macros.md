# Print Start/End Macros (print_macros.cfg)

The `print_macros.cfg` provides hardware-agnostic `PRINT_START` and `PRINT_END` macros that automatically detect your printer's capabilities (AFC, nozzle wiper, Beacon probe, etc.) and adjust behavior accordingly.

## PRINT_START Behavior

- Performs conditional homing via `_CG28`
- Heats bed and extruder to target temperatures
- Optionally performs heat soak if chamber temperature is specified
- Cleans nozzle via `CLEAN_NOZZLE` if available (or `AFC_BRUSH` for AFC systems)
- Performs z-tilt adjustment if configured
- Auto-calibrates or homes Z (Beacon contact mode on first home)
- Generates bed mesh
- Performs smart park (KAMP) and line purge

## PRINT_END Behavior

- Retracts filament
- Parks toolhead (AFC-aware positioning)
- Disables heaters and cooling
- Manages filament sensors (encoder auto-disabled)
- Optionally saves configuration

## Customization

```gcode
PRINT_START BED=100 EXTRUDER=240 CHAMBER=45
```

**Note:** Chamber temperature is optional; omit if not needed.
