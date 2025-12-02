# AI Agent Instructions for klipper-nerdygriffin-macros

This repository provides hardware-agnostic Klipper G-code macros designed to be symlinked into printer-specific configs and extended via local overrides.

## NFS Mount Architecture (CRITICAL)

⚠️ **NEVER edit `/home/pi/printers/vt-1548/klipper-nerdygriffin-macros`** - This is a read-only NFS mount of the remote VT-1548's macros repo, visible for comparison only.

**Single source of truth for macros edits:**
- Local path: `/home/pi/printers/v0-3048/klipper-nerdygriffin-macros` (same as `/home/pi/klipper-nerdygriffin-macros`)
- This is the ONLY location to edit macro files
- After editing, sync to VT-1548 using `dev/sync_macros_repo.sh`

**Mounted paths visible in workspace:**
- `/home/pi/printers/v0-3048/klipper-nerdygriffin-macros` → **WRITABLE** (local bind mount)
- `/home/pi/printers/vt-1548/klipper-nerdygriffin-macros` → **READ-ONLY** (NFS mount for reference)

If asked to update macros, apply edits ONLY to the v0-3048 path.

## Architecture & Intent
- Core macros live in `macros/*.cfg` and avoid printer-specific pins/geometry.
- Intended usage: create a symlink in printer configs (e.g., `ln -sf ~/klipper-nerdygriffin-macros/macros ~/printer_data/config/nerdygriffin-macros`) and include files from `printer.cfg`.
- Consumers override behavior by redefining macro variables or small wrapper macros in their own configs (never edit the symlinked directory in a printer repo).
- External systems often referenced but not provided here: `STATUS_*` LED macros, `_CG28` conditional homing, `_CLIENT_VARIABLE`, filament sensors, AFC macros.

## Key Files & Groups
- `macros/filament_management.cfg`: LOAD/UNLOAD/PURGE with AFC auto-detect and safe parking.
- `macros/client_macros.cfg`: Pause/Resume/Cancel hooks for Mainsail/Fluidd with optional AFC handling.
- `macros/heat_soak.cfg`: Chamber preheat via bed+hotend assist, sensor auto-detect, optional LED animations.
- `macros/auto_pid.cfg`: PID helpers for extruder/bed.
- `macros/maintenance_macros.cfg`: Nozzle change, belt settling (`SETTLE_BELT_TENSION`).
- `macros/rename_existing.cfg`: Safe overrides (M109/M190/M117...).
- `macros/save_config.cfg`: Safe SAVE_CONFIG with delayed variant.
- `macros/shaketune.cfg`: Shake&Tune wrapper (optional dependency installed elsewhere).
- `macros/shutdown.cfg`, `macros/tacho_macros.cfg`, `macros/utility_macros.cfg`: Safety, fan preflight, helpers.
- `install.sh`: Creates symlink, optional Moonraker update_manager entry.
- Other files will be added over time.

## Macro Development Patterns
- Conditional hardware calls: check for macro existence before use, e.g. `{% if printer['gcode_macro AFC_BRUSH'] is defined %} AFC_BRUSH {% endif %}`.
- Preserve user state: `SAVE_GCODE_STATE` then `RESTORE_GCODE_STATE` (use `MOVE=1` when appropriate).
- Conditional homing: call `_CG28` instead of raw `G28` when safe.
- Status signaling: call `STATUS_*`/`RESET_STATUS` around long-running or critical ops.
- Delayed actions: use `[delayed_gcode ...]` with `UPDATE_DELAYED_GCODE` to schedule/cancel.
- Printer overrides: expose behavior via `variable_*` and document typical overrides in macro headers.

## Integration & Overrides (Examples)
- Include in `printer.cfg`:
  ```ini
  [include nerdygriffin-macros/filament_management.cfg]
  [include nerdygriffin-macros/heat_soak.cfg]
  [include nerdygriffin-macros/client_macros.cfg]
  ```
- Override variables locally (do not edit this repo):
  ```ini
  [gcode_macro HEAT_SOAK]
  variable_max_chamber_temp: 60
  variable_chamber_sensor_name: "nitehawk-36"

  [gcode_macro SETTLE_BELT_TENSION]
  variable_y_calibrated: 116
  ```
- Hardware pin overrides (after include):
  ```ini
  [pwm_cycle_time beeper]
  pin: PE5
  ```

## External Dependencies & Expectations
- Provided externally by printer configs or other repos:
  - `_CG28`, `STATUS_*`, `RESET_STATUS`, `_CLIENT_VARIABLE`
  - Filament sensors (e.g., `encoder_sensor`)
  - AFC macros (`AFC_PARK`, `AFC_BRUSH`, `AFC_CUT`) if multi-material is installed
  - Shake&Tune install for `shaketune.cfg` use

## Common Workflows
- Install and link:
  ```bash
  cd ~/klipper-nerdygriffin-macros
  ./install.sh
  ```
- Add Moonraker update manager (optional) per README, then restart Klipper:
  ```bash
  sudo systemctl restart klipper
  ```
- Test a macro from console or HTTP:
  ```bash
  curl -s -X POST "http://localhost:7125/printer/gcode/script?script=LOAD_FILAMENT"
  ```
- Debug config issues:
  ```bash
  tail -f ~/printer_data/logs/klippy.log
  ```

## Contribution Guidelines
- Keep macros hardware-agnostic and configurable via variables.
- Prefer conditional checks over hard failures when optional hardware is absent.
- Maintain consistent naming (`variable_*`), state save/restore, and status signaling patterns.
- Do not introduce board-specific pins; document required overrides in README/macro headers.

## Pointers
- See `README.md` for install, expected dependencies, and full usage examples.
- Example consumer implementations: printer repos that symlink this directory and override variables/macros in `printer.cfg`.
