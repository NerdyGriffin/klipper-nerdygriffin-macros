# TODO - klipper-nerdygriffin-macros

## Future Enhancements

### HEAT_SOAK LED Parametrization
- [ ] Make LED names configurable via variables instead of hardcoded
  - Current hardcoded: `panel_right`, `panel_left`, `bed_light`, `toolhead`
  - Proposed: Add variables like `variable_panel_right_led`, `variable_panel_left_led`, `variable_bed_led`, `variable_toolhead_led`
  - Allow empty strings to skip non-existent LEDs
  - Priority: Medium (current gating with `enable_chamber_leds` is acceptable workaround)
