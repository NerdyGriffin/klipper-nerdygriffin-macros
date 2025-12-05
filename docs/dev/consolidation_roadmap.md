# Consolidation Roadmap

> **Note:** This document tracks development history and future planning. For usage instructions, see the main [README](../../README.md).

## Overview

This plugin consolidates hardware-agnostic Klipper macros that were previously duplicated across multiple printer configurations. The goal is a single source of truth that adapts to different hardware through conditional logic and per-printer variable overrides.

---

## Completed Consolidations

### ✅ SETTLE_BELT_TENSION
- **Location**: `macros/maintenance_macros.cfg`
- **Pattern**: Per-printer `variable_y_calibrated` override
- **Source**: Andrew Ellis Print-Tuning-Guide

### ✅ heat_soak.cfg
- **Location**: `macros/heat_soak.cfg`
- **Features**: Auto sensor detection, dict-based LED mapping, configurable colors
- **Pattern**: `variable_*` overrides for chamber limits and LED behavior

### ✅ status_macros.cfg
- **Location**: `macros/status_macros.cfg`
- **Features**: Dict-based `_LED_VARS` mapping (chamber_map, logo_map, nozzle_map)
- **Pattern**: Hardware-agnostic LED control via logical group dicts

### ✅ print_macros.cfg
- **Location**: `macros/print_macros.cfg`
- **Features**: PRINT_START/PRINT_END with AFC, Beacon, bed_mesh, z_tilt detection
- **Pattern**: Conditional hardware detection at runtime

---

## Not Recommended for Consolidation

| Config | Reason |
|--------|--------|
| autotune.cfg | Hardware-specific motor tuning |
| KAMP_Settings.cfg | External plugin, printer-specific tuning |
| TEST_SPEED.cfg | External source (Andrew Ellis) |
| homing.cfg | Probe types and sensorless tuning vary significantly |

---

## Future Opportunities

- **LED Range Syntax**: Support `'1-8'` notation instead of comma-separated lists
- **Color Palettes**: Per-printer color customization via `variable_color_*` dicts
- **Filament Macro Simplification**: Remove temperature params if frontends handle it
- **Partial Homing Abstraction**: Extract sensorless current adjustment patterns (low priority)
