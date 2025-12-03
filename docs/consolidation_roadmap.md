# Klipper-NerdyGriffin-Macros: Future Consolidation Roadmap

## Overview
Analysis of remaining printer-specific configs to identify opportunities for hardware-agnostic consolidation while maintaining printer-specific customization through variables.

---

## PRIORITY 1: SETTLE_BELT_TENSION.cfg

### Current Status
- **Nearly identical** between printers
- **Only difference**: `variable_y_calibrated` (116 vs 120)
- **Source**: Andrew Ellis Print-Tuning-Guide
- **Category**: Maintenance macro (similar to NOZZLE_CHANGE_POSITION)

### Consolidation Strategy
✅ **READY TO CONSOLIDATE**

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

## PRIORITY 2: heat_soak.cfg

### Current Status
- **Core logic identical**, different sensors and LED hardware
- **Key differences**:
  - V0: `temperature_sensor chamber` (dedicated sensor)
  - VT: `temperature_sensor nitehawk-36` (toolhead as proxy)
  - V0: Has `panel_right`, `panel_left`, `bed_light` LEDs (active)
  - VT: LED code commented out (no panel LEDs)
  - Minor tuning differences: `max_chamber_temp` (58 vs 60), `ext_assist_temp` multiplier (5 vs 4)

### Consolidation Strategy
✅ **CONSOLIDATABLE WITH CONDITIONAL LOGIC**

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

## PRIORITY 3: status-macros.cfg & heat_soak.cfg LED Logic

### Current Status
- **Very similar structure**, different LED hardware
- **V0**: Has `panel_right`, `panel_left`, `bed_light` neopixels (active)
- **VT**: Only `toolhead` neopixel (bed/panel hardware planned but commented out)
- **Core status colors/patterns identical**
- **User's Long-term Goal**: Standardize LED logic across all printers

### Consolidation Strategy
⚠️ **DEFER UNTIL LED STANDARDIZATION DESIGN COMPLETE**

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
- Many macros to update (~20+ status states in status-macros.cfg)
- Heat soak LED animation needs group-aware logic
- Need to design standardized LED group names across printers
- Transition plan for existing LED-specific code

**Effort**: HIGH - Requires design phase + implementation across multiple files

**Recommendation**:
1. **Phase 4**: Document LED standardization design, get user input on group names
2. **Phase 5**: Implement heat_soak with LED group variables (prototype)
3. **Future**: Apply LED group pattern to status-macros after proving concept

---

## NOT RECOMMENDED FOR CONSOLIDATION

### autotune.cfg
**Reason**: Hardware-specific motor tuning (OMC vs LDO steppers)
**Status**: ❌ Keep printer-specific

### print_macros.cfg
**Reason**: Different workflows (AFC vs CLEAN_NOZZLE, Z_TILT vs bed_screws)
**Status**: ❌ Keep printer-specific (user agreed)

### KAMP_Settings.cfg
**Reason**: External plugin configuration, printer-specific purge tuning
**Status**: ❌ Keep printer-specific (user agreed)

### homing.cfg
**Reason**: Different homing logic, HOME_CURRENT values, probe types
**Status**: ❌ Keep printer-specific

### TEST_SPEED.cfg
**Reason**: External source (Andrew Ellis), identical copies already
**Status**: ❌ Keep as-is with source attribution

---

## RECOMMENDED ACTION PLAN

### Phase 4 (Immediate - Low Effort)
1. **Add SETTLE_BELT_TENSION to maintenance_macros.cfg**
   - Add macro with default `variable_y_calibrated: 120`
   - Document override pattern in README
   - Update both printer configs to override variable
   - Deprecate local copies
   - Test on both printers
   - **Estimated Time**: 30 minutes
   - **Risk**: LOW

### Phase 5 (Near-term - Medium Effort)
2. **Consolidate heat_soak.cfg**
   - Implement sensor auto-detection
   - Add conditional LED updates
   - Add tunable variables (max_chamber_temp, ext_assist_multiplier)
   - Comprehensive testing with different sensor configs
   - Deprecate local copies
   - **Estimated Time**: 2-3 hours
   - **Risk**: MEDIUM (sensor detection logic, LED timing)

### Future Consideration
3. **status-macros.cfg** - Evaluate after gaining more experience with conditional LED patterns from heat_soak consolidation

---

## EXPECTED OUTCOMES

### After Phase 4
- **Plugin**: 12 macros (added SETTLE_BELT_TENSION)
- **Code Reduction**: ~101 lines eliminated
- **V0 deprecated/**: 12 files
- **VT deprecated/**: 12 files

### After Phase 5
- **Plugin**: 13 macros (added heat_soak)
- **Code Reduction**: ~213 lines eliminated total
- **V0 deprecated/**: 13 files
- **VT deprecated/**: 13 files

---

## DECISION MATRIX

| Config | Consolidate? | Effort | Risk | Priority | Notes |
|--------|-------------|--------|------|----------|-------|
| SETTLE_BELT_TENSION | ✅ YES | LOW | LOW | 1 | Simple variable override |
| heat_soak | ✅ YES | MEDIUM | MEDIUM | 2 | Sensor auto-detect + conditional LEDs |
| status-macros | ⚠️ MAYBE | HIGH | HIGH | 3 | Defer until Phase 5 complete |
| autotune | ❌ NO | N/A | N/A | N/A | Hardware-specific motors |
| print_macros | ❌ NO | N/A | N/A | N/A | Different workflows |
| KAMP_Settings | ❌ NO | N/A | N/A | N/A | External plugin config |
| homing | ❌ NO | N/A | N/A | N/A | Different logic/hardware |
| TEST_SPEED | ❌ NO | N/A | N/A | N/A | External source |
