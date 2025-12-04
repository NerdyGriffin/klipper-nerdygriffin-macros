# Klipper-NerdyGriffin-Macros: Future Consolidation Roadmap

## Overview
Analysis of remaining printer-specific configs to identify opportunities for hardware-agnostic consolidation while maintaining printer-specific customization through variables.

---

## ✅ COMPLETED: SETTLE_BELT_TENSION.cfg

### Status: CONSOLIDATED
- **Consolidated**: December 2024 (Pre-documentation)
- **Location**: `macros/maintenance_macros.cfg`
- **Override Pattern**: Per-printer `variable_y_calibrated` in `printer.cfg`
- **Source**: Andrew Ellis Print-Tuning-Guide

### Implementation
Successfully added to `maintenance_macros.cfg` with configurable variable override pattern.

**Approach**: Add to `maintenance_macros.cfg` with configurable variable override

**Implementation Pattern**:
```gcode
[gcode_macro SETTLE_BELT_TENSION]
variable_y_calibrated: 0  # Override in printer.cfg: [gcode_macro SETTLE_BELT_TENSION] variable_y_calibrated: 116
# ... rest of macro
```

**User Configuration** (in printer.cfg):
```gcode
# Override SETTLE_BELT_TENSION calibrated position
[gcode_macro SETTLE_BELT_TENSION]
variable_y_calibrated: 116  # V0: 116, VT: 120
```

**Benefits**:
- Single source of truth for belt settling logic
- Easy per-printer calibration
- Consistent with existing beeper/filament_management pattern
- Reduces 101 lines of duplicate code

**Effort**: LOW - Simple variable override pattern

---

## ✅ COMPLETED: heat_soak.cfg

### Status: CONSOLIDATED
- **Consolidated**: December 2024 (Pre-documentation)
- **Location**: `macros/heat_soak.cfg`
- **Features**: Auto sensor detection, dict-based LED mapping, per-printer overrides
- **LED System**: Implemented with `_LED_VARS` (chamber_map, logo_map, nozzle_map)

### Implementation
Successfully consolidated with conditional logic for sensor detection and hardware-agnostic LED control.

**Approach**: Dynamic sensor detection + optional LED support

**Implementation Pattern**:
```gcode
[gcode_macro HEAT_SOAK]
variable_max_chamber_temp: 60  # Override in printer.cfg
variable_led_count: 10
variable_chamber_sensor_name: ""  # Auto-detect or override
variable_ext_assist_multiplier: 4  # Override for tuning
gcode:
    # Auto-detect chamber sensor
    {% set chamber_sensor_name = chamber_sensor_name if chamber_sensor_name != "" else
        ("temperature_sensor chamber" if "temperature_sensor chamber" in printer else
         "temperature_sensor nitehawk-36" if "temperature_sensor nitehawk-36" in printer else
         none) %}

    {% if chamber_sensor_name %}
        {% if printer[chamber_sensor_name].temperature < target_chamber %}
            # ... heating logic
        {% endif %}
    {% endif %}

    # Optional LED updates - only if LEDs exist
    {% if 'neopixel panel_right' in printer %}
        SET_LED LED=panel_right ...
    {% endif %}
    {% if 'neopixel bed_light' in printer %}
        SET_LED LED=bed_light ...
    {% endif %}
    {% if 'neopixel toolhead' in printer %}
        SET_LED LED=toolhead ...
    {% endif %}
```

**User Configuration** (in printer.cfg):
```gcode
# Override heat soak parameters (optional)
[gcode_macro HEAT_SOAK]
variable_max_chamber_temp: 58  # V0 measured limit
variable_ext_assist_multiplier: 5  # V0 tuning
# variable_chamber_sensor_name: "temperature_sensor chamber"  # Force specific sensor
```

**Benefits**:
- Automatic sensor detection
- Graceful degradation (works with/without chamber sensor)
- LED effects only apply if hardware present
- Per-printer tuning via variables
- Reduces ~112 lines of duplicate code

**Challenges**:
- More complex conditional logic
- Need to test with/without various sensor combinations
- LED logic needs careful testing

**Effort**: MEDIUM - Requires conditional sensor detection and LED handling

---

## ✅ COMPLETED: status_macros.cfg LED Logic

### Status: CONSOLIDATED
- **Consolidated**: December 2024
- **Location**: `macros/status_macros.cfg`
- **LED System**: Dict-based `_LED_VARS` mapping (chamber_map, logo_map, nozzle_map)
- **Benefits**: Hardware-agnostic, supports multiple LED devices per zone

### Implementation
Implemented Option B (Standardized LED Group Variables) with dict-based mapping system. Successfully deployed on both printers with different LED hardware configurations.

**Two Potential Approaches**:

#### Option A: Hardware Detection
```gcode
[gcode_macro STATUS_READY]
gcode:
    {% if 'neopixel toolhead' in printer %}
        SET_LED LED=toolhead RED=0.0 GREEN=0.4 BLUE=0.0
    {% endif %}
    {% if 'neopixel bed_light' in printer %}
        SET_LED LED=bed_light RED=0.0 GREEN=0.4 BLUE=0.0
    {% endif %}
    {% if 'neopixel panel_right' in printer %}
        SET_LED LED=panel_right RED=0.0 GREEN=0.4 BLUE=0.0
    {% endif %}
    # ... etc for all LED hardware
```

#### Option B: Standardized LED Group Variables (RECOMMENDED)
Define LED group mappings in printer.cfg:
```gcode
[gcode_macro _LED_VARS]
variable_nozzle_led: "toolhead"      # LED name for nozzle area
variable_logo_led: ""                # LED name for logo area (bed indicator)
variable_bed_led: "bed_light"        # LED name for bed area
variable_chamber_led: "panel_right"  # LED name for chamber (may need multiple)
variable_chamber_led_left: "panel_left"  # Optional second chamber LED
gcode:  # This macro is just for variables
```
(we will need to add led index to this, since toolheads control multiple neopixels with one gpio pin)

Then macros reference groups:
```gcode
[gcode_macro STATUS_READY]
gcode:
    {% set vars = printer['gcode_macro _LED_VARS'] %}
    {% if vars.nozzle_led and vars.nozzle_led in printer %}
        SET_LED LED={vars.nozzle_led} RED=0.0 GREEN=0.4 BLUE=0.0
    {% endif %}
    {% if vars.logo_led and vars.logo_led in printer %}
        SET_LED LED={vars.logo_led} RED=0.0 GREEN=0.4 BLUE=0.0
    {% endif %}
    # ... etc
```

**Benefits of Option B**:
- Future-proof: Easy to add new LED hardware
- Standardized naming: All printers use same "logical" LED groups
- Flexible mapping: Physical LED names can differ per printer
- Self-documenting: Variables make LED purpose clear
- Enables advanced features: Multi-LED groups (e.g., left+right chamber)

**Current Hardware Mapping**:
```
V0.3048:
  nozzle_led: "toolhead"
  logo_led: ""  # No logo LED
  bed_led: "bed_light"
  chamber_led: "panel_right"
  chamber_led_left: "panel_left"

VT.1548 (Current):
  nozzle_led: "toolhead"
  logo_led: ""
  bed_led: ""  # Planned but not installed
  chamber_led: ""  # Planned but not installed
  chamber_led_left: ""

VT.1548 (Future):
  nozzle_led: "toolhead"
  logo_led: "bed_light"  # Or dedicated logo LED
  bed_led: "bed_light"
  chamber_led: "panel_right"
  chamber_led_left: "panel_left"
```

**Challenges**:
- Many macros to update (~20+ status states in status_macros.cfg)
- Heat soak LED animation needs group-aware logic
- Need to design standardized LED group names across printers
- Transition plan for existing LED-specific code

**Effort**: HIGH - Requires design phase + implementation across multiple files

**Recommendation**:
1. **Phase 4**: Document LED standardization design, get user input on group names
2. **Phase 5**: Implement heat_soak with LED group variables (prototype)
3. **Future**: Apply LED group pattern to status-macros after proving concept

---

### print_macros.cfg
**Reason**: Different workflows (AFC vs CLEAN_NOZZLE, Z_TILT vs bed_screws) [This line needs review]
**Status**: 🔄 PLANNED - Consolidate common patterns while preserving printer-specific workflows

**Consolidation Approach**:
- Extract AFC detection patterns (conditional `AFC_PARK`, `AFC_BRUSH`, tool loading)
- Standardize sensor management (encoder_sensor enable/disable)
- Common state handling (gcode offsets, pressure advance, velocity limits)
- Keep printer-specific: leveling sequence (Z_TILT vs bed_screws), nozzle cleaning method (CLEAN_NOZZLE vs AFC_BRUSH)

**User Note**: Manual changes in progress to align workflows before consolidation

### homing.cfg
**Reason**: Different homing logic, HOME_CURRENT values, probe types [this line needs review]
**Status**: 🔄 PLANNED - Abstract common sensorless current adjustment logic

## NOT RECOMMENDED FOR CONSOLIDATION

### autotune.cfg
**Reason**: Hardware-specific motor tuning (OMC vs LDO steppers)
**Status**: ❌ Keep printer-specific

### KAMP_Settings.cfg
**Reason**: External plugin configuration, printer-specific purge tuning
**Status**: ❌ Keep printer-specific (user agreed)

### TEST_SPEED.cfg
**Reason**: External source (Andrew Ellis), identical copies already
**Status**: ❌ Keep as-is with source attribution

---

## CONSOLIDATION COMPLETE

All priority consolidation targets have been successfully implemented:
- ✅ Phase 4: SETTLE_BELT_TENSION consolidated
- ✅ Phase 5: heat_soak consolidated with sensor auto-detection and LED system
- ✅ LED System: Dict-based `_LED_VARS` implemented in status_macros.cfg

### Current Plugin Status
- **13 consolidated macros** in production
- **Hardware-agnostic design** with per-printer overrides
- **22 deprecated files** on V0-3048
- **19 deprecated files** on VT-1548
- **Both printers operational** with shared plugin

---

## ACHIEVED OUTCOMES (December 2024)

- **Plugin**: 13 consolidated macros operational
- **Code Reduction**: ~2000+ lines of duplicate code eliminated
- **V0-3048 deprecated**: 22 files
- **VT-1548 deprecated**: 19 files
- **Maintenance Reduction**: ~65% (single source updates vs 2 copies)
- **Testing**: Both printers operational, functional testing completed

---

## DECISION MATRIX

| Config | Status | Effort | Risk | Notes |
|--------|--------|--------|------|-------|
| SETTLE_BELT_TENSION | ✅ DONE | LOW | LOW | Consolidated to maintenance_macros.cfg |
| heat_soak | ✅ DONE | MEDIUM | MEDIUM | Sensor auto-detect + _LED_VARS system |
| status_macros | ✅ DONE | HIGH | MEDIUM | Dict-based LED mapping implemented |
| autotune | ❌ KEEP LOCAL | N/A | N/A | Hardware-specific motor tuning |
| print_macros | 🔄 PLANNED | MEDIUM | MEDIUM | Extract common patterns (AFC detection, sensor management, state handling) |
| KAMP_Settings | ❌ KEEP LOCAL | N/A | N/A | External plugin, printer-specific tuning |
| homing | 🔄 PLANNED | MEDIUM | MEDIUM | Abstract sensorless current logic; probe-specific paths remain local |
| TEST_SPEED | ❌ KEEP LOCAL | N/A | N/A | External source (Andrew Ellis), identical copies |

## Future Opportunities

### Potential Enhancements
- **LED Range Syntax**: Support `'1-8'` notation instead of `'1,2,3,4,5,6,7,8'` in _LED_VARS
- **Filament Macro Simplification**: Consider removing temperature parameters if frontends handle it
- **Partial Homing Abstraction**: Extract sensorless homing current adjustment patterns (LOW PRIORITY)
- **Shared Purge Logic**: Re-evaluate after AFC and CLEAN_NOZZLE workflows stabilize (LOW PRIORITY)
