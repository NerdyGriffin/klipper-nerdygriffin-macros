# COMPLETED TASKS - klipper-nerdygriffin-macros

### Consolidation Project

- [x] Consolidate shared macros and configs between VT1548 and V03048 into a custom plugin that can be updated via moonraker
  - Goal: reduce duplication and ensure consistency between both printers
  - Deliverable: plugin that can be symlinked into each printer's config (like KAMP)
  - Status tracking and detailed planning: see [`docs/dev/consolidation_roadmap.md`](consolidation_roadmap.md)

### HEAT_SOAK LED Parametrization

- [x] ~~Make LED names configurable via variables instead of hardcoded~~ **COMPLETED January 2025**
  - ✅ Unified chamber_map, logo_map, and nozzle_map into single animation loop
  - ✅ Added configurable start_color and end_color variables (RGBW dicts)
  - ✅ Fixed COLOR_SCALE to use device_len (works with any chain length)
  - ✅ Single LEDs fade smoothly across entire duration, multi-LED chains show progress bar
  - ✅ All LED zones participate in animation (chamber, logo, nozzle)
- [x] ~~Update \_LED_VARS to accept a range of indices instead of just comma-separated lists~~ **COMPLETED December 2025**
  - ✅ Supports `'1-8'` range notation
  - ✅ Supports mixed format `'1-3,5,7-10'`
  - ✅ Refactored to single nested `variable_leds` dict (supports custom groups)
  - ✅ Consolidated `_SET_LOGO_LEDS`, `_SET_NOZZLE_LEDS`, `_SET_CHAMBER_LEDS` into unified `_SET_LEDS MAP=<group>`
  - ✅ Updated status_macros.cfg, heat_soak.cfg, and docs

### Filament Management

- [x] Remove temperature parameter from LOAD/UNLOAD filament macros
  - Context: latest mainsail/KlipperScreen/AFC versions bypass this or require extruder above min_print_temp before macro runs
  - Completion Date: December 4, 2025

## Documentation & Code Quality

- [x] Ensure all custom config files have appropriate headers and documentation
  - Added comprehensive headers to: auto_pid.cfg, gcode_features.cfg, print_macros.cfg, rename_existing.cfg, save_config.cfg
  - All 16 macro files now have clear descriptions of their purpose, features, and usage
  - Completion Date: December 26, 2025
