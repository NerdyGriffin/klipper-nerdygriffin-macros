# Revo Cold Nozzle Swap Retract (revo.cfg)

Opt-in large end-of-print retract for E3D Revo hotends, so the nozzle assembly can be unscrewed cold without first reheating and unloading.

## Dependencies

- **Required**: Mainsail/Fluidd client config (`mainsail.cfg` / `fluidd.cfg`) for `_CLIENT_EXTRUDE` / `_CLIENT_RETRACT` (unguarded)
- **Optional**: `print_macros.cfg`, `filament_management.cfg` and `nozzle_wiper.cfg` call these helpers only when `revo.cfg` is included
- **Optional**: KAMP `_KAMP_Settings.tip_distance` is kept in sync when KAMP is present

## Usage

Include the file only on printers with a Revo hotend:

```ini
[include nerdygriffin-macros/revo.cfg]
```

Once included, `PRINT_END` (non-AFC) pulls the filament back by `_CLIENT_VARIABLE.retract` after parking, and `PRINT_START` (non-Beacon) and `NW_PURGE` push it back by `_CLIENT_VARIABLE.unretract` before purging.
`LOAD_FILAMENT`, `PURGE_FILAMENT` and `_AUTO_LOAD_FILAMENT` clear the pending unretract; `UNLOAD_FILAMENT` sets it.

A Revo nozzle threads into the heatsink, so the filament must be clear of the whole hot and cold side before the hotend cools. Set the retract length to cover that path:

```ini
[gcode_macro _CLIENT_VARIABLE]
variable_retract   : 30.0
variable_unretract : 30.0
```

This also makes `PAUSE` and `CANCEL_PRINT` leave the filament in the same state, so a nozzle can be swapped after either without reheating.

> **Warning**:
>
> Do not include this file on hotends with a conventional nozzle. Pulling a molten tip
> that far up a long melt zone lets it freeze as a swollen plug above the heatbreak,
> which jams the next load with PLA, HTPLA and PETG. Without `revo.cfg`, `PRINT_END`
> leaves only the small `G10` firmware retract.

## Internal Macros

- `_CONDITIONAL_RETRACT [LENGTH=<mm>]` — Retracts if the extruder is hot enough, records that an unretract is pending, and sets KAMP `tip_distance` to the retract length
- `_CONDITIONAL_UNRETRACT [LENGTH=<mm>]` — Unretracts once if a retract is pending and the extruder is hot enough, then resets KAMP `tip_distance` to 0
