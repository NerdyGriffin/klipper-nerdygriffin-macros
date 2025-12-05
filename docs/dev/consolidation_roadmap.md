# Klipper-NerdyGriffin-Macros: Future Consolidation Roadmap

> **Note:** This document is for internal development tracking and planning. End users should refer to the main [README](../README.md) and [README](README.md) guides.

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
- **Refactored**: December 2025 (Unified LED animation with configurable colors)
- **Location**: `macros/heat_soak.cfg`
- **Features**: Auto sensor detection, dict-based LED mapping, configurable colors, per-printer overrides
- **LED System**: Unified animation for chamber_map, logo_map, and nozzle_map with RGBW color interpolation

### Implementation
Successfully consolidated with conditional logic for sensor detection and hardware-agnostic LED control.

**December 2025 Enhancement**:
- Unified all LED zones (chamber, logo, nozzle) into single animation loop
- Added `variable_start_color` and `variable_end_color` (RGBW dicts) for customizable fade colors
- Fixed COLOR_SCALE calculation to use `device_len` instead of hardcoded `10`
- Single LEDs fade smoothly across entire timer duration (no more 10-loop repetition)
- Multi-LED chains display proper progress bar with per-segment color fade
- Explicit WHITE=0.0 support for RGBW LED strips

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

## ✅ COMPLETED: print_macros.cfg

### Status: CONSOLIDATED
- **Consolidated**: January 2025
- **Location**: `macros/print_macros.cfg`
- **Features**: Hardware-agnostic PRINT_START/PRINT_END with AFC, Beacon, bed_mesh, z_tilt support
- **Pattern**: Conditional logic for all printer-specific hardware

### Implementation
Successfully consolidated with conditional detection of AFC, CLEAN_NOZZLE, Beacon probe, bed_mesh, and z_tilt. Both printers now use identical macros from the plugin repo.

**Implementation Pattern**:
```gcode
[gcode_macro PRINT_START]
gcode:
    # AFC vs CLEAN_NOZZLE detection
    {% if printer['gcode_macro AFC_BRUSH'] is defined %}
        AFC_BRUSH
    {% elif printer['gcode_macro CLEAN_NOZZLE'] is defined %}
        CLEAN_NOZZLE
    {% endif %}

    # Beacon vs standard Z homing
    {% if 'beacon' in printer %}
        G28 Z METHOD=CONTACT CALIBRATE=1
    {% else %}
        G28 Z
    {% endif %}

    # Conditional bed leveling
    {% if 'z_tilt' in printer %}
        Z_TILT_ADJUST
    {% endif %}

    # Conditional bed mesh
    {% if 'bed_mesh' in printer %}
        BED_MESH_CLEAR
        BED_MESH_CALIBRATE
    {% endif %}
```

**Key Features**:
- Optimized PRINT_END parking (Y-only initial move, conditional X)
- AFC silicone pad parking vs non-AFC corner parking with retract
- Beacon thermal offset management (+0.07mm during print, removed after)
- _CLIENT_EXTRUDE conditional (non-AFC only for first layer prime)
- Configurable HEAT_SOAK (2 min default, 15 min for high-temp prints)

**Benefits**:
- Single source of truth for print start/end logic
- Automatically adapts to available hardware
- Supports both AFC and non-AFC workflows
- Works with Beacon or standard probes
- Reduces 161 lines of duplicate code

**Effort**: COMPLETED

### homing.cfg
**Reason**: Different homing logic, HOME_CURRENT values, probe types
**Status**: 🔄 PLANNED - Abstract common sensorless current adjustment logic

**Consolidation Approach**:
- Extract `_CG28` conditional homing wrapper
- Common sensorless current adjustment pattern with per-printer variables
- Standardize fan/LED handling during homing
- Keep printer-specific: HOME_CURRENT values, Z probe offsets, endstop positions

**Challenges**:
- Beacon vs Klicky vs endstop-based Z homing
- Sensorless tuning varies per printer/motor combination
- Current adjustment timing sensitive to motor type

**Effort**: MEDIUM - Requires careful testing to avoid homing failures

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
