# TODO - klipper-nerdygriffin-macros

## In Progress

### Documentation Review & Updates

- [ ] **rename_existing.cfg & rename_existing.md**: Review and update documentation to match actual command overrides (M18, M84, etc.)
- [ ] **homing.cfg documentation**: Create user documentation for sensorless homing helpers and conditional homing utilities
- [ ] **gcode_features.cfg documentation**: Create user documentation for optional G-code feature enablement
- [ ] **status_macros variable updates**: Verify and document current `variable_leds` dict structure (vs legacy maps)
- [ ] **README macro list**: Add undocumented macros (homing.cfg, gcode_features.cfg) to included macros section and documentation table


## Next

### HEAT_SOAK LED Parametrization

- [ ] **Color palettes**: Add `variable_color_*` dicts (e.g., `ready_color`, `heating_color`) for per-printer color tuning
  - Add inline dict examples for color palettes in `status_macros.md` documentation
  - Pattern:

```
variable_colors: {
        'logo': { # Colors for logo states
            'busy': {'r': 1.0, 'g': 1.0, 'b': 0.0, 'w': 0.0},
            'calibrating_z': {'r': 0.8, 'g': 0.0, 'b': 0.35, 'w': 0.0},
            'cleaning': {'r': 0.0, 'g': 0.02, 'b': 0.5, 'w': 0.0},
            'heating': {'r': 0.3, 'g': 0.18, 'b': 0.0, 'w': 0.0},
            'homing': {'r': 0.0, 'g': 0.6, 'b': 0.2, 'w': 0.0},
            'leveling': {'r': 0.5, 'g': 0.1, 'b': 0.4, 'w': 0.0},
            'meshing': {'r': 0.2, 'g': 1.0, 'b': 0.0, 'w': 0.0},
            'off': {'r': 0.0, 'g': 0.0, 'b': 0.0, 'w': 0.0},
            'party': {'r': 0.0, 'g': 1.0, 'b': 1.0, 'w': 1.0},
            'printing': {'r': 0.0, 'g': 0.0, 'b': 1.0, 'w': 0.0},
            'ready': {'r': 0.01, 'g': 0.01, 'b': 0.01, 'w': 0.1},
        },
        'nozzle': { # Colors for nozzle states
            'heating': {'r': 0.8, 'g': 0.35, 'b': 0.0, 'w': 1.0},
            'off': {'r': 0.0, 'g': 0.0, 'b': 0.0, 'w': 0.0},
            'on': {'r': 0.0, 'g': 0.0, 'b': 0.0, 'w': 1.0},
            'party': {'r': 1.0, 'g': 1.0, 'b': 1.0, 'w': 1.0},
        },
        'chamber': { # Colors for chamber states
            'busy': {'r': 1.0, 'g': 1.0, 'b': 0.0, 'w': 0.0},
            'calibrating_z': {'r': 0.8, 'g': 0.0, 'b': 0.35, 'w': 0.0},
            'cleaning': {'r': 0.0, 'g': 0.02, 'b': 0.5, 'w': 0.0},
            'heating': {'r': 0.3, 'g': 0.18, 'b': 0.0, 'w': 0.0},
            'homing': {'r': 0.0, 'g': 0.6, 'b': 0.2, 'w': 0.0},
            'leveling': {'r': 0.5, 'g': 0.1, 'b': 0.4, 'w': 0.0},
            'meshing': {'r': 0.2, 'g': 1.0, 'b': 0.0, 'w': 0.0},
            'off': {'r': 0.0, 'g': 0.0, 'b': 0.0, 'w': 0.0},
            'on': {'r': 1.0, 'g': 1.0, 'b': 0.5, 'w': 1.0},
            'party': {'r': 0.0, 'g': 1.0, 'b': 1.0, 'w': 1.0},
            'ready': {'r': 0.01, 'g': 0.01, 'b': 0.01, 'w': 0.1},
        },
    }
```

- [ ] Placeholder

## Backlog

### Documentation & Code Quality

- [ ] Revisit Dependencies section in README - consider Required/Optional/Provided labels for clarity

## Brainstorming

- [ ] Potential shared homing helpers (conditional stallguard current adjust)
- [ ] Consistent status display/message patterns (post LED standardization)
- [ ] `homing.cfg` partial abstraction (sensorless current + probe sequencing)
- [ ] Look for additional opportunities to reduce duplicate code by using abstractions or helper macros
- [ ] Monitor and optimize Klipper startup time with plugin includes
  - Measure baseline startup time on both printers
  - Profile config parsing overhead from symlinked macros
  - Consider lazy-loading patterns for optional features if needed
