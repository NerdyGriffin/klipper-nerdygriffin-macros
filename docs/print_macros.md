# Print Start/End Macros (print_macros.cfg)

The `print_macros.cfg` provides hardware-agnostic `PRINT_START` and `PRINT_END` macros that automatically detect your printer's capabilities (AFC, nozzle wiper, Beacon probe, etc.) and adjust behavior accordingly.

## Usage

```gcode
PRINT_START BED=100 EXTRUDER=240 [CHAMBER=45]
PRINT_END
```

### PRINT_START Parameters

| parameters | default value | description |
|-----------:|---------------|-------------|
| BED | 60 | Target bed temperature in °C |
| EXTRUDER | 200 | Target extruder temperature in °C |
| CHAMBER | None | Target chamber temperature in °C (optional, auto-calculated from bed temp if omitted) |

## PRINT_START Behavior

- Performs conditional homing via `_CG28`
- Heats bed and extruder to target temperatures
- Performs heat soak (calculates a chamber temperature target based on the bed temp if a chamber temp is not specified)
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

## Configuration

These macros use status LEDs and heat soak features. See:
- [status_macros.md](status_macros.md) - LED configuration
- [heat_soak.md](heat_soak.md) - Chamber preheating options
