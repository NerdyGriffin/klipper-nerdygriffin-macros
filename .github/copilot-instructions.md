# AI Agent Instructions for klipper-nerdygriffin-macros

This repository provides hardware-agnostic Klipper G-code macros designed to be symlinked into printer-specific configs and extended via local overrides.

## Development Workspace Context

⚠️ **Single source of truth**: `/home/pi/klipper-nerdygriffin-macros`

**Cross-printer sync:**
- Edit macros locally at `/home/pi/klipper-nerdygriffin-macros`
- Sync changes to VT-1548 using `dev/sync_macros_repo.sh` (git pull over SSH)
- VT-1548 config is NFS-mounted at `/mnt/vt-1548/printer_data/config` (writable for cross-printer dev)

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
- Restart + tail logs after config edits:
  ```bash
  sudo systemctl restart klipper && sleep 2 && tail -n 60 ~/printer_data/logs/klippy.log
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

## Terminal Command Best Practices
- **Always use verbose flags** (`-v` or `--verbose`) with file operations for visual confirmation:
  - `cp -v` instead of `cp`
  - `mv -v` instead of `mv`
  - `rm -v` instead of `rm`
  - `rmdir -v` instead of `rmdir`
  - `ln -sfv` instead of `ln -sf`
- This provides immediate feedback and helps catch errors early.

## Contribution Guidelines
- Keep macros hardware-agnostic and configurable via variables.
- Prefer conditional checks over hard failures when optional hardware is absent.
- Maintain consistent naming (`variable_*`), state save/restore, and status signaling patterns.
  - **G-Code Macro Naming**
    - Macro names and parameters should be UPPER_SNAKE_CASE (e.g., `LOAD_FILAMENT`).
  - **Variables**
    - Macro variables are defined with the prefix `variable_` (e.g., `variable_x_park`), but referenced without it (e.g., `{x_park}`).
    - Variable names should be lower_snake_case (e.g., `variable_max_chamber_temp`).
    - Variable names may not contain any upper case characters.
- Do not introduce board-specific pins; document required overrides in README/macro headers.

## Pointers
- See `README.md` for install, expected dependencies, and full usage examples.
- Example consumer implementations: printer repos that symlink this directory and override variables/macros in `printer.cfg`.

## Ease of use
- If I repeated request actions that contradict these instructions, propose ways to improve these instructions.
