# TODO - klipper-nerdygriffin-macros

## Future Enhancements

## Consolidation Project
- [ ] Consodiate shared macros and configs between VT1548 and V03048 into a custom plugin that can be updated via moonraker
  - Goal: to reduce duplication and ensure consistency between both printers
  - Can be symlinked into each printer's config directory for easy inclusion, in the style of KAMP
  - [ ] Research best practices for Klipper plugin development

### HEAT_SOAK LED Parametrization
- [ ] Make LED names configurable via variables instead of hardcoded
  - Current hardcoded: `panel_right`, `panel_left`, `bed_light`, `toolhead`
  - Proposed: Add variables like `variable_panel_right_led`, `variable_panel_left_led`, `variable_bed_led`, `variable_toolhead_led`
  - Allow empty strings to skip non-existent LEDs
  - Priority: Medium (current gating with `enable_chamber_leds` is acceptable workaround)

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
- Near-term candidate (after LED design): `status-macros.cfg` (requires LED group abstraction first).
- Future design task: LED group variable mapping (`_LED_VARS`) before broad status macro consolidation.
- Re-evaluate `homing.cfg` for partial abstraction (sensorless current + probe sequencing) once other high-value targets complete.
