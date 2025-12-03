---
description: 'Audit copilot-instructions across printers/macros; propose non-destructive patches.'
agent: agent
model: Auto (copilot)
---

Perform an audit and update all `.github/copilot-instructions.md` files across printers and the macros repo, keeping guidance aligned with the current configs.

## Objectives
- Verify architecture, subsystems, and workflows match current configs.
- Flag stale or speculative guidance (hard-coded positions, removed hardware, deprecated notes).
- Propose concise, actionable edits with diffs.

## Repositories & Paths
- Macros repo: `~/printers/v0-3048/klipper-nerdygriffin-macros/.github/copilot-instructions.md`
- V0-3048 config: `~/printers/v0-3048/printer_data/config/.github/copilot-instructions.md`
- VT-1548 config: `~/printers/vt-1548/printer_data/config/.github/copilot-instructions.md`

## Prompt Run Steps (use VS Code Prompts)

1) Read these files:
- ~/printers/v0-3048/klipper-nerdygriffin-macros/.github/copilot-instructions.md
- ~/printers/v0-3048/printer_data/config/.github/copilot-instructions.md
- ~/printers/vt-1548/printer_data/config/.github/copilot-instructions.md

2) Cross-verify against current configs:
- V0-3048: `~/printers/v0-3048/printer_data/config/{printer.cfg,print_macros.cfg,homing.cfg,status-macros.cfg,nozzlewiper.cfg}`
- VT-1548: `~/printers/vt-1548/printer_data/config/{printer.cfg,print_macros.cfg,homing.cfg,status-macros.cfg,beacon.cfg}`
- Macros: `~/printers/v0-3048/klipper-nerdygriffin-macros/{README.md,macros/*.cfg}`

3) Check these topics for drift:
- Parking logic: dynamic vs hard-coded (use `axis_max` math in `PRINT_END`)
- Homing strategy: `_CG28`, sensorless XY currents, Z endstop vs Beacon
- Start/End flow: `CLEAN_NOZZLE` vs `AFC_BRUSH`, KAMP `SMART_PARK` + `LINE_PURGE`
- Status LEDs: bed/toolhead/panel actual hardware vs placeholders
- Temperature management: standby temps, heat soak targets and sensors
- External dependencies: `nerdygriffin-macros`, `KAMP`, AFC presence and conditional checks
- Hardware notes: beeper pins, chamber sensor names, motion limits

4) Produce a concise report:
- Findings per file (bulleted), with exact code references (file + section)
- Proposed patch diffs for each outdated section (do not apply automatically)
- No generic advice; only repo-specific corrections

5) Do not apply patches automatically; propose diffs and await confirmation.

Output format:
- Summary per file
- Patches in unified diff blocks
- Checklist of remaining questions

## Run Tips
- After edits:
  - `sudo systemctl restart klipper`
  - `tail -f ~/printer_data/logs/klippy.log`
- Test macros via HTTP:
  - `curl -s -X POST "http://localhost:7125/printer/gcode/script?script=PRINT_START%20EXTRUDER=240%20BED=110"`
- Keep edits minimal and aligned with existing patterns:
  - Avoid editing symlinked `nerdygriffin-macros/` and `KAMP/` in-place within printer configs; update source repos or override locally after includes.
