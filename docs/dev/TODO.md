# TODO - klipper-nerdygriffin-macros

## In Progress

### Consolidation Project
- [ ] Consolidate shared macros and configs between VT1548 and V03048 into a custom plugin that can be updated via moonraker
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
- [ ] Update _LED_VARS to accept a range of indices instead of just comma-separated lists
  - e.g. `variable_chamber_map: {'chamber_strip': '1-8'}` instead of `variable_chamber_map: {'chamber_strip': '1,2,3,4,5,6,7,8'}`
  - Priority: High (current syntax works fine, but is tedious for long chains)
- [ ] **Color palettes**: Add `variable_color_*` dicts (e.g., `ready_color`, `heating_color`) for per-printer color tuning
  - Add inline dict examples for color palettes in `status_macros.md` documentation
  - Pattern: `variable_ready_color: {'r': 0.2, 'g': 0.2, 'b': 0.2, 'w': 0.1}`

## Next

### Filament Management
- [ ] Consider removing temperature parameter from LOAD/UNLOAD filament macros
  - Context: latest mainsail/KlipperScreen/AFC versions bypass this or require extruder above min_print_temp before macro runs

## Backlog

### Documentation & Code Quality
- [ ] Ensure all custom config files have appropriate headers and documentation
- [ ] Revisit Dependencies section in README - consider Required/Optional/Provided labels for clarity

## Brainstorming

- [ ] `SET_COMPLETE_SHUTDOWN` default behavior should be `ENABLE=1` so it can be called without parameter to enable post-print shutdown
- [ ] Potential shared homing helpers (conditional stallguard current adjust)
- [ ] Consistent status display/message patterns (post LED standardization)
- [ ] `homing.cfg` partial abstraction (sensorless current + probe sequencing)
- [ ] Monitor and optimize Klipper startup time with plugin includes
  - Measure baseline startup time on both printers
  - Profile config parsing overhead from symlinked macros
  - Consider lazy-loading patterns for optional features if needed
