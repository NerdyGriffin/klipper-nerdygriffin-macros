# Klipper Macro Config File Style Guide

This guide standardizes the structure and formatting of all `.cfg` files in the
`macros/` directory. Following these conventions makes files predictable to read,
maintain, and extend.

## Section Ordering

Sections within a `.cfg` file appear in this strict top-to-bottom order:

1. [File header comment](#1-file-header-comment)
2. [Non-macro config sections](#2-non-macro-config-sections) (if any)
3. [Variable-storage macros](#3-variable-storage-macros-_vars--_settings) (`_*_VARS`)
4. [Public macros](#4-public-macros)
5. [Secondary / compatibility macros](#5-secondary--compatibility-macros)
6. [`[delayed_gcode ...]` sections](#6-delayed_gcode-sections)
7. [Internal helper macros](#7-internal-helper-macros)

Within each group, macros are sorted **alphabetically** by name.

---

## 1. File Header Comment

Every `.cfg` file begins with a comment block immediately before the first section
(no blank line between the header and first `[...]` section):

```ini
# Brief feature description
# Hardware notes or scope (e.g. "Hardware-agnostic implementation")
# Part of klipper-nerdygriffin-macros
```

- 3–6 lines; no author, version, or changelog metadata
- Optional additional line: `# References: <url>` — only when the file is
  substantially derived from external work (e.g. Beacon docs, Ellis guide, Mainsail
  upstream)

---

## 2. Non-Macro Config Sections

Any Klipper config section that is **not** `[gcode_macro ...]` or `[delayed_gcode ...]`
goes at the very top, immediately after the file header comment. These are
hardware/feature declarations, not macros. Examples:

```ini
[force_move]
enable_force_move: True

[pause_resume]

[pwm_cycle_time beeper]
cycle_time: 0.001

[shaketune]
timeout: 300
```

Multiple such sections in one file are sorted **alphabetically** by section name.

---

## 3. Variable-Storage Macros (`_*_VARS` / `_*_SETTINGS`)

Macros whose sole purpose is storing configurable defaults. They appear **without a
section banner**, immediately after any non-macro sections (or the file header if
there are none).

```ini
[gcode_macro _FILAMENT_VARS]
description: Shared persistent variables for filament management operations
variable_extruder_temp: 0
gcode:
    # Intentionally empty - used only for variable storage

[gcode_macro _TOOLHEAD_PARK_VARS]
description: Configurable parking positions for filament operations
# Override these in your printer.cfg to customize parking positions
variable_custom_load_x: None   # X position for load/unload (None = auto: bed center)
variable_custom_load_y: None   # Y position for load/unload (None = auto: front + 10mm)
gcode:
```

**Rules:**

- No section banner before this group — placement and the `_` prefix make their role
  self-identifying
- Multiple `_*_VARS` macros in one file: sorted alphabetically
- `gcode:` block: use a bare `gcode:` line (standard). An informational
  `action_respond_info` message may be added when accidental invocation would otherwise
  be confusing — for example when the macro name pattern resembles a user-callable macro

---

## 4. Public Macros

User-callable macros: `UPPER_CASE` names, no leading underscore.

When the file also contains internal helpers, precede this group with a section banner:

```
#####################################################################
#   [Descriptive Section Label]
#####################################################################
```

Sorted **alphabetically** within this group.

```ini
#####################################################################
#   Public Filament Macros (Expected by Mainsail & KlipperScreen)
#####################################################################

[gcode_macro LOAD_FILAMENT]
...

[gcode_macro PURGE_FILAMENT]
...

[gcode_macro UNLOAD_FILAMENT]
...
```

---

## 5. Secondary / Compatibility Macros

M-code overrides and alias macros that delegate to a primary macro. Still public (no
underscore) but secondary in prominence.

```ini
[gcode_macro M141]
description: Emulate chamber heater using temperature_fan
gcode:
    ...

[gcode_macro M191]
description: Emulate chamber heater using HEAT_SOAK macro
gcode:
    ...
```

These may share the public section banner or carry their own (e.g.
`#   G-code Compatibility`) — use judgment based on how different they feel from the
primary feature macros in the file.

Sorted **alphabetically** within this group.

---

## 6. `[delayed_gcode ...]` Sections

Placed after all public macros, before internal helpers. Sorted **alphabetically** by
the delayed_gcode name.

Use a section banner when mixed with other groups:

```
#####################################################################
#   Filament Sensor Management
#####################################################################

[delayed_gcode DISABLE_ENCODER_SENSOR]
initial_duration: 1
gcode:
    SET_FILAMENT_SENSOR SENSOR=encoder_sensor ENABLE=0

[delayed_gcode ENABLE_ENCODER_SENSOR]
gcode:
    SET_FILAMENT_SENSOR SENSOR=encoder_sensor ENABLE=1
```

---

## 7. Internal Helper Macros

Underscore-prefixed macros not meant to be called directly. Always placed last.
Preceded by a section banner:

```
#####################################################################
#   Helper Macros (Internal Use)
#####################################################################
```

Sorted **alphabetically** within this group. Additional sub-group banners are allowed
when a logical cluster benefits from visual separation:

```
#####################################################################
#   Retraction Helpers
#####################################################################
```

---

## Section Banner Format

```
#####################################################################
#   Label Text Here
#####################################################################
```

- 69 `#` characters on the fence lines (matches mainsail.cfg convention)
- One blank line before the banner block, one blank line after it
- Label text: Title Case, descriptive noun phrase
- Omit entirely for single-section files — banners add no value when there is only
  one group

---

## Naming Conventions

| Macro type                 | Convention          | Examples                              |
| -------------------------- | ------------------- | ------------------------------------- |
| Public macro               | `UPPER_CASE`        | `LOAD_FILAMENT`, `HEAT_SOAK`          |
| Internal helper            | `_UPPER_CASE`       | `_FILAMENT_OPERATION_INIT`, `_CG28`   |
| Variable-storage macro     | `_FEATURE_VARS`     | `_HOME_VARS`, `_BELT_TENSION_VARS`    |
| G-code override / M-code   | `M###`              | `M300`, `M109`, `M600`                |
| System-namespaced public   | `PREFIX_UPPER_CASE` | `SHAKETUNE_COLD`, `NW_DEPLOY`         |

---

## `description:` Field

- **Required** for all public macros
- **Required** for `_*_VARS` macros (explains their purpose as config storage)
- **Recommended** for internal helpers (improves discoverability in Mainsail/Fluidd)
- Single line, imperative mood, starts with a capital letter
- Placed immediately after `[gcode_macro NAME]`, before any `variable_*` lines

```ini
[gcode_macro LOAD_FILAMENT]
description: Loads new filament into toolhead (uses printer.extruder.target)
variable_load_distance: 60
gcode:
    ...
```

---

## `variable_*` Declaration Formatting

- Listed after `description:`, before `gcode:`
- One declaration per line
- Inline `#` comment explaining purpose, units, and fallback behavior
- Values may be aligned across related variables (cosmetic, optional)
- Use `None` (Python `None`) for "not set / fall through to auto-calculation"

```ini
variable_custom_load_x:  None  # X position for load/unload (None = auto: bed center)
variable_custom_load_y:  None  # Y position for load/unload (None = auto: front + 10mm)
variable_purge_distance: 100   # mm of filament to purge after loading
```

---

## Checklist for New `.cfg` Files

- [ ] File header: 3–6 comment lines, no author/version/changelog
- [ ] Non-macro config sections (if any) appear before all macros, sorted alphabetically
- [ ] `_*_VARS` macros appear first, without a banner, sorted alphabetically
- [ ] Public macros next, with section banner if internal helpers also present
- [ ] Secondary / compatibility macros (M-codes, wrappers) after primary public macros
- [ ] `[delayed_gcode ...]` sections after public macros, before helpers
- [ ] Internal helper macros last, with `Helper Macros (Internal Use)` banner
- [ ] All macros within each group are sorted alphabetically
- [ ] `description:` present on all public macros and `_*_VARS` macros
- [ ] All `variable_*` lines have inline `#` comments
- [ ] Section banners omitted for single-section files
