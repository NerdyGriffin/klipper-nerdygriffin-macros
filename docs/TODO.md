# TODO - klipper-nerdygriffin-macros

## Future Enhancements

### Performance Optimization
- [ ] Monitor and optimize Klipper startup time with plugin includes
  - Measure baseline startup time on both printers
  - Profile config parsing overhead from symlinked macros
  - Consider lazy-loading patterns for optional features if startup time becomes an issue

## Printer cleanup
- Ensure all custom config files have appropriate headers and documentation

## Consolidation Project
- [ ] Consodiate shared macros and configs between VT1548 and V03048 into a custom plugin that can be updated via moonraker
  - Goal: to reduce duplication and ensure consistency between both printers
  - Can be symlinked into each printer's config directory for easy inclusion, in the style of KAMP
  - [ ] Research best practices for Klipper plugin development

### HEAT_SOAK LED Parametrization
- [x] ~~Make LED names configurable via variables instead of hardcoded~~ **COMPLETED January 2025**
  - ✅ Unified chamber_map, logo_map, and nozzle_map into single animation loop
  - ✅ Added configurable start_color and end_color variables (RGBW dicts)
  - ✅ Fixed COLOR_SCALE to use device_len (works with any chain length)
  - ✅ Single LEDs fade smoothly across entire duration, multi-LED chains show progress bar
  - ✅ All LED zones participate in animation (chamber, logo, nozzle)
- [ ] Update _LED_VARS to accept a range of indices instead of just comma-separated lists
  - e.g. `variable_chamber_map: {'chamber_strip': '1-8'}` instead of `variable_chamber_map: {'chamber_strip': '1,2,3,4,5,6,7,8'}`
  - Priority: High (current comma-separated syntax works fine, but is tedious for long chains)

### Filament Management
- [ ] Consider removing temperature parameter from LOAD/UNLOAD filament macros
  - The latest versions of mainsail, KlipperScreen, or AFC seem to bypass this behavior or require the extruder above min_print_temp before the macro is allowed to run

### Consolidation Reference
- Primary consolidation planning lives in printer config repo: `printer_data/config/docs/consolidation_roadmap.md`.
- Upcoming plugin-impact areas:
  - LED group variable framework (pre-req for status macro migration)
  - Potential shared homing helpers (conditional stallguard current adjust) – deferred
  - Consistent status display/message patterns (post LED standardization)

### Remaining / Deferred Targets
- See `docs/consolidation_roadmap.md` for full analysis and decision matrix.
- Near-term candidate (after LED design): `status_macros.cfg` (requires LED group abstraction first).
- Future design task: LED group variable mapping (`_LED_VARS`) before broad status macro consolidation.
- Re-evaluate `homing.cfg` for partial abstraction (sensorless current + probe sequencing) once other high-value targets complete.
- Re-evaluate `print_macros.cfg` for potential shared purge/start-end logic after AFC and CLEAN_NOZZLE workflows stabilize.
