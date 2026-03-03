# TODO - klipper-nerdygriffin-macros

## Backlog

### STATUS_MACROS LED Parametrization

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

## Next

### Code Quality

- [ ] Update the nozzle_wiper to conditionally use AFC_BRUSH, with a fallback a simplified version of the brush sequence if AFC_BRUSH is not defined. Both versions should wrap the brush in the cooldown logic. The \_NW_BRUSH_VARS should be only used if AFC_BRUSH is not defined, with the same `-1` or `1000` or other defaults the block the macro from running the if the variables are not configured by the user. See `~/github/chirpy2605/voron/V0/NozzleWiper/nozzlewiper.cfg ` and `/mnt/vt-1548/printer_data/config/AFC/` for the existing implementations. [This is the top priority item]
  - `macros/nozzle_wiper.cfg` should be behave like `~/github/chirpy2605/voron/V0/NozzleWiper/nozzlewiper.cfg` if `AFC_BRUSH` is not defined, and like `/mnt/vt-1548/printer_data/config/AFC/nozzle_wiper.cfg` if `AFC_BRUSH` is defined, but keep the brush_loc, bursh_depth, and brush_width variables for users who want to use the simplified version of the brush sequence with the existing variables.
  - Could we use `{% set vars = printer['gcode_macro _AFC_BRUSH_VARS']|default(printer['gcode_macro _NW_BRUSH_VARS']) %}` to conditionally pull variables from whichever macro is defined? Then we don't need complex conditional login in the NW_WIPE macros to check which variable set to use.

- [ ] **Parking velocity**: Resolve `TODO` in `_TOOLHEAD_PARK_LOAD_UNLOAD` — choose an appropriate default velocity for parking moves (currently takes `max` of `recover_velocity` and `toolhead.max_velocity`, which may be too fast)
- [ ] **Consistent status display/message patterns** (post LED standardization)
- [ ] **Look for additional opportunities to reduce duplicate code** by using abstractions or helper macros

### Infrastructure

- [ ] **Setup automatic Prettier formatting** for Markdown files to maintain consistent style in documentation
  - [ ] GitHub Actions workflow to run linting/formatting on push to remote and pull requests
- [ ] **Monitor and optimize Klipper startup time** with plugin includes
  - Measure baseline startup time on both printers
  - Profile config parsing overhead from symlinked macros
  - Consider lazy-loading patterns for optional features if needed

---

## Completed

### Documentation Review & Updates

- [x] **rename_existing.cfg & rename_existing.md**: Review and update documentation to match actual command overrides (M18, M84, etc.)
- [x] **homing.cfg documentation**: Create user documentation for sensorless homing helpers and conditional homing utilities
- [x] **gcode_features.cfg documentation**: Create user documentation for optional G-code feature enablement
- [x] **status_macros variable updates**: Verify and document current `variable_leds` dict structure (vs legacy maps)
- [x] **README macro list**: Add undocumented macros (homing.cfg, gcode_features.cfg) to included macros section and documentation table
- [x] **Revisit Dependencies section in README**: Added Required/Optional/Provided labels for clarity

### Code Quality & Refactoring

- [x] **Potential shared homing helpers**: Conditional StallGuard current adjust
- [x] **`homing.cfg` partial abstraction**: Sensorless current + probe sequencing; added `variable_home_accel` to `_HOME_VARS`
- [x] **Filament management refactor**: Consolidated park macros, ternary position chains, moved `_CG28`/`M104` into `_FILAMENT_OPERATION_INIT`, eliminated `_TOOLHEAD_PARK_Z`

### Documentation Standards

- [x] **`MACRO_STYLE_GUIDE.md`**: Created `.cfg` file structure and ordering standards
- [x] **`MARKDOWN_STYLE_GUIDE.md`**: Renamed from `STYLE_GUIDE.md` to clarify scope
