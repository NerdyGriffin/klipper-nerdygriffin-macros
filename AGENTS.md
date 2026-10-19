# AI Agent Instructions for klipper-nerdygriffin-macros

This repository provides hardware-agnostic Klipper G-code macros designed to be symlinked into printer-specific configs and extended via local overrides.

## Development Workspace Context

⚠️ **Single source of truth**: `/home/pi/klipper-nerdygriffin-macros`

**Cross-printer sync:**

- Edit macros locally at `/home/pi/klipper-nerdygriffin-macros`
- Sync changes to the other host using `dev/sync_macros_repo.sh` (git pull over SSH); see `dev/README.md` for the full script table
- Each host keeps a read-only git clone of the *other* printer's config at `$PEER_CONFIG_CLONE`
  (default `~/Klipper-Config-<repo>`), refreshed by `dev/sync_peer_config.sh`
- Claude Code auto-memory (`~/.claude/projects/<slug>/memory/`) is replicated between the hosts by
  `dev/sync_claude_memory.sh` (git, cron + session hooks); history lives in `~/.claude/memory-sync/`

**`dev/` is tracked.** Host-specific values (peer hostname, SSH target, addresses) live only in
`dev/.env`, which is git-ignored; see `dev/.env.example` and `dev/README.md`. `dev/copilot/` is
ignored scratch space. `.github/prompts/` holds tracked Copilot prompt files; `.github/tmp/` is
git-ignored, host-local scratch. `.claude/skills/` holds tracked Claude Code skills (they must read
host-specific values from `dev/.env` via `dev/env.sh`, never hard-code them); the rest of `.claude/`
is git-ignored. This repo is public: never put a hostname, IP, or FQDN in a tracked
file (the tracked `klipper-nerdygriffin-macros.code-workspace` and `docs/dev/TODO.md` are known
exceptions), and stage files by explicit path rather than `git add -A`.

## Architecture & Intent

- Core macros live in `macros/*.cfg` and avoid printer-specific pins/geometry.
- Intended usage: create a symlink in printer configs (e.g., `ln -sfv ~/klipper-nerdygriffin-macros/macros ~/printer_data/config/nerdygriffin-macros`) and include files from `printer.cfg`.
- Consumers override behavior by redefining macro variables or small wrapper macros in their own configs (never edit the symlinked directory in a printer repo).
- External systems often referenced but not provided here: Mainsail/Fluidd `PAUSE`/`RESUME`/`CANCEL_PRINT` and `_CLIENT_VARIABLE` (`client.cfg` only overlays the user hook keys), filament sensors, AFC, KAMP, Shake&Tune, Beacon.

## Key Files & Groups

- `macros/print_macros.cfg`: `PRINT_START` / `PRINT_END` — the print lifecycle. `PRINT_START` starts with `CLEAR_PAUSE` to clear stale pause state.
- `macros/status_macros.cfg`: `STATUS_*` / `RESET_STATUS` LED states; zone config in `_LED_VARS`; `_SET_LEDS_BY_NAME` helper; `notify_bed_cooled`/`notify_bed_heated` delayed_gcodes.
- `macros/filament_management.cfg`: LOAD/UNLOAD/PURGE with AFC auto-detect and safe parking; `_AUTO_LOAD_FILAMENT` (toolhead-sensor `insert_gcode`), `_PAUSE_IF_PRINTING` (sensor `runout_gcode`), `ENABLE_`/`DISABLE_ENCODER_SENSOR` delayed_gcodes.
- `macros/client.cfg`: Pause/Resume/Cancel hooks for Mainsail/Fluidd with optional AFC handling; `[delayed_gcode NOZZLE_STANDBY_COOLDOWN]` prolonged-pause hotend standby (armed by `_AFTER_PAUSE` only during a print, cancelled by `_BEFORE_RESUME`/`_BEFORE_CANCEL`); an idle-time PAUSE is cleared instead.
- `macros/heat_soak.cfg`: Chamber preheat via bed+hotend assist, sensor auto-detect, optional LED animations.
- `macros/homing.cfg`: Sensorless and conditional homing helpers with edge clearance and current management.
- `macros/idle_timeout.cfg`: `[idle_timeout]` behavior (sensor teardown, AFC-aware); also cancels `NOZZLE_STANDBY_COOLDOWN`.
- `macros/auto_pid.cfg`: PID helpers for extruder/bed.
- `macros/belt_tension.cfg`: `SETTLE_BELT_TENSION` + `_BELT_TENSION_VARS`.
- `macros/maintenance_macros.cfg`: `DEEP_CLEAN_NOZZLE`, `NOZZLE_CHANGE_POSITION`, `_DEBUG_PRINT_STATE`.
- `macros/nozzle_wiper.cfg`: `NW_CLEAN_NOZZLE`, deploy/retract; needs a local `[servo ...]` and `NW_BUCKET_POS` override.
- `macros/squiggly_purge.cfg`: `SQUIGGLY_PURGE` prime-line alternative.
- `macros/beeper.cfg`: `M300` and chimes; needs a local `[pwm_cycle_time beeper]` pin override.
- `macros/gcode_features.cfg`: Enables advanced G-code features (force_move, pause/resume, firmware retraction, arcs, etc.).
- `macros/rename_existing.cfg`: Safe overrides (M109/M190/M117...); `SET_DISPLAY_TEXT` wrapper cancels any pending `clear_display` before setting text (needs `[display_status]`).
- `macros/save_config.cfg`: Safe SAVE_CONFIG with delayed variant.
- `macros/shaketune.cfg`: Shake&Tune wrapper (optional dependency installed elsewhere).
- `macros/shutdown.cfg` (`SHUTDOWN`/`REBOOT`, `SAFE_SHUTDOWN`), `macros/tacho_macros.cfg` (`PCF_CHECK`/`PREFLIGHT_CHECK` fan preflight), `macros/positioning_macros.cfg` (`CENTER`).
- `install.sh`: Creates symlink, optional Moonraker update_manager entry.

## Macro Development Patterns

- Conditional hardware calls: check for macro existence before use, e.g. `{% if printer['gcode_macro AFC_BRUSH'] is defined %} AFC_BRUSH {% endif %}`.
- Preserve user state: `SAVE_GCODE_STATE` then `RESTORE_GCODE_STATE` (use `MOVE=1` when appropriate).
- Conditional homing: call `_CG28` instead of raw `G28` when safe.
- Status signaling: call `STATUS_*`/`RESET_STATUS` around long-running or critical ops.
- Delayed actions: use `[delayed_gcode ...]` with `UPDATE_DELAYED_GCODE` to schedule/cancel.
- Printer overrides: expose behavior via `variable_*` and document typical overrides in macro headers.
- Never call bare `PAUSE` from a sensor `runout_gcode`; use `_PAUSE_IF_PRINTING` (`macros/filament_management.cfg`).
- Every macro file header declares its dependencies as `# - Requires [include x.cfg]` / `# - Optional: ...` lines per `docs/dev/MACRO_STYLE_GUIDE.md`.
- Run `dev/setup.sh` once per host to install the markdownlint pre-commit hook (config in `.markdownlint-cli2.jsonc`).

## Integration & Overrides (Examples)

- Include in `printer.cfg`:

  ```ini
  [include nerdygriffin-macros/filament_management.cfg]
  [include nerdygriffin-macros/heat_soak.cfg]
  [include nerdygriffin-macros/client.cfg]
  ```

- Override variables locally (do not edit this repo). Re-declare the macro that *owns* the variable —
  note `y_calibrated` lives on `_BELT_TENSION_VARS`, not on `SETTLE_BELT_TENSION`. Values below are
  illustrative only; every one is printer-specific:

  ```ini
  [gcode_macro HEAT_SOAK]
  variable_max_chamber_target: 45        # ceiling your chamber can actually reach (default in heat_soak.cfg header)
  variable_chamber_sensor_name: ""       # empty = auto-detect Nevermore, then `chamber`, then `nitehawk-36`

  [gcode_macro _BELT_TENSION_VARS]
  variable_y_calibrated: 110             # Y where belt span == belt_span_length (default in belt_tension.cfg header)
  ```

- Hardware pin overrides (after include) — pin names are board-specific:

  ```ini
  [pwm_cycle_time beeper]
  pin: <your board's beeper pin>
  ```

## External Dependencies & Expectations

For a comprehensive list of dependencies and compatibility requirements, see [README.md#dependencies](README.md#dependencies).

**Developer reference — file locations within this plugin:**

- `STATUS_*` macros → `macros/status_macros.cfg`
- `RESET_STATUS` → `macros/status_macros.cfg`
- `_AFTER_PAUSE`, `_BEFORE_RESUME`, `_BEFORE_CANCEL`, `[delayed_gcode NOZZLE_STANDBY_COOLDOWN]` → `macros/client.cfg`
  - delayed_gcode objects have no `get_status`, so `NOZZLE_STANDBY_COOLDOWN` cannot be probed with `is defined`; guard on `{% if printer['gcode_macro _AFTER_PAUSE'] is defined %}` instead (see `macros/idle_timeout.cfg`).

**Key conditional integrations (auto-detected):**

- AFC macros (`AFC_PARK`, `AFC_BRUSH`, `AFC_CUT`) — check with `{% if printer['gcode_macro AFC_PARK'] is defined %}`
- Filament motion sensor — never call `SET_FILAMENT_SENSOR SENSOR=encoder_sensor` directly
  - Use `_SET_MOTION_SENSOR ENABLE=0|1` (`macros/filament_management.cfg`); it reads the name from `_FILAMENT_SENSOR_VARS.motion_sensor` (default `""`; each printer sets it in its overrides file) and no-ops if the sensor is missing
  - Outside that file, guard the call with `{% if printer['gcode_macro _SET_MOTION_SENSOR'] is defined %}`
  - To read its state use `printer[sensor] is defined and printer[sensor].enabled` with the same variable
- Shake&Tune — check with `{% if 'shaketune' in printer %}` (`macros/shaketune.cfg` defines `[shaketune]`)

## Common Workflows

- Install and link:

  ```bash
  cd ~/klipper-nerdygriffin-macros
  ./install.sh
  ```

- Restart + tail logs after config edits:

  ```bash
  curl -s -X POST "http://localhost:7125/printer/gcode/script?script=FIRMWARE_RESTART" && sleep 2 && tail -n 60 ~/printer_data/logs/klippy.log
  ```

- Moonraker update manager (optional): `./install.sh` offers to append the repo-root `moonraker.conf` snippet to `~/printer_data/config/moonraker.conf`; then restart Moonraker:

  ```bash
  sudo systemctl restart moonraker
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
    - Variable names should be lower_snake_case (e.g., `variable_max_chamber_target`).
    - Variable names may not contain any upper case characters.
- Do not introduce board-specific pins; document required overrides in README/macro headers.

## Documentation Structure

- `README.md` - User-facing overview, installation, and feature list
- `docs/` - One page per macro file; the index is the Documentation table in `README.md`
- `docs/auto_pid.md`, `docs/beeper.md`, `docs/client.md`, etc. - Individual macro configuration documentation
- `docs/status_macros.md` - LED system setup and configuration
- `docs/DEPENDENCIES.md` - Cross-file macro dependency map
- `docs/dev/GIT_HOOKS.md` - Pre-commit hook (markdownlint) setup and behavior
- `docs/dev/TODO.md`, `docs/dev/COMPLETE.md` - Open and completed development tasks
- `docs/dev/MARKDOWN_STYLE_GUIDE.md` - Documentation (Markdown) style and formatting standards
- `docs/dev/MACRO_STYLE_GUIDE.md` - Klipper macro `.cfg` file structure and ordering standards

## Pointers

- Example consumer implementations: printer repos that symlink this directory and override variables/macros in `printer.cfg`.
- This plugin is in active development; Large scale refactoring is allowed and encouraged to improve maintainability and usability. Do not worry about breaking changes.

## Ease of use

- If I repeated request actions that contradict these instructions, propose ways to improve these instructions.
- **Important:** This file (`AGENTS.md`) is the vendor-neutral source of truth for AI-agent guidance —
  surfaced to Claude Code via `CLAUDE.md` (`@AGENTS.md` import) and to GitHub Copilot via the
  `.github/copilot-instructions.md` symlink. Edit `AGENTS.md`, not the pointers. Do not reference it
  from user-facing docs (README.md, docs/*.md); those must be self-contained.
