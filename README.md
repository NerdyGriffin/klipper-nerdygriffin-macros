# klipper-nerdygriffin-macros

Hardware-agnostic Klipper macros for Voron printers with automatic AFC detection and per-printer customization.

## Features

- **🎯 Filament Management** - Smart load/unload/purge with AFC auto-detection
- **🎨 Status & LED Control** - Dict-based LED system adapts to any hardware configuration
- **🔧 Maintenance Helpers** - PID tuning, belt settling, nozzle changes
- **🌡️ Chamber Control** - Auto-detecting heat soak with LED animations
- **📊 Safety Features** - Safe shutdown, config saving, fan preflight checks
- **🔄 Client Integration** - Pause/resume/cancel hooks for Mainsail/Fluidd

### Included Macros

- `auto_pid.cfg` - Automated PID tuning
- `beeper.cfg` - M300 beeper/tone support
- `client_macros.cfg` - Mainsail/Fluidd integration with AFC support
- `filament_management.cfg` - Load/unload/purge operations
- `gcode_features.cfg` - Enables advanced G-code features (force_move, pause/resume, arcs, etc.)
- `heat_soak.cfg` - Chamber preheating with sensor auto-detection
- `homing.cfg` - Sensorless and conditional homing helpers
- `maintenance_macros.cfg` - Belt settling, nozzle changes
- `nozzle_wiper.cfg` - Servo-actuated nozzle purge bucket and brush system
- `print_macros.cfg` - PRINT_START/PRINT_END with AFC, Beacon, and bed mesh support
- `rename_existing.cfg` - Enhanced G-code overrides (M109, M190, M117)
- `save_config.cfg` - Safe SAVE_CONFIG with print-state detection
- `shaketune.cfg` - Shake&Tune wrapper macros
- `shutdown.cfg` - Safe shutdown with conditional cooling
- `status_macros.cfg` - Hardware-agnostic LED status patterns
- `tacho_macros.cfg` - Part cooling fan preflight checks
- `utility_macros.cfg` - Utility helpers (CENTER, DEEP_CLEAN_NOZZLE, etc.)

## Installation

### Automated Installation (Recommended)

```bash
cd ~
git clone https://github.com/NerdyGriffin/klipper-nerdygriffin-macros.git
cd klipper-nerdygriffin-macros
./install.sh
```

The install script will:
- Create symlink in your config directory
- Optionally configure Moonraker's update_manager
- Provide include statements for your `printer.cfg`

### Manual Installation

1. **Clone and create symlink:**
   ```bash
   cd ~
   git clone https://github.com/NerdyGriffin/klipper-nerdygriffin-macros.git
   ln -sf ~/klipper-nerdygriffin-macros/macros ~/printer_data/config/nerdygriffin-macros
   ```

2. **Add to moonraker.conf:**
   ```ini
   [update_manager klipper-nerdygriffin-macros]
   type: git_repo
   path: ~/klipper-nerdygriffin-macros
   origin: https://github.com/NerdyGriffin/klipper-nerdygriffin-macros.git
   primary_branch: main
   is_system_service: False
   managed_services: klipper
   ```

3. **Include in printer.cfg:**
   ```ini
   [include nerdygriffin-macros/auto_pid.cfg]
   [include nerdygriffin-macros/beeper.cfg]              # Optional: Requires pin configuration
   [include nerdygriffin-macros/client_macros.cfg]
   [include nerdygriffin-macros/filament_management.cfg]
   [include nerdygriffin-macros/heat_soak.cfg]
   [include nerdygriffin-macros/maintenance_macros.cfg]
   [include nerdygriffin-macros/nozzle_wiper.cfg]        # Optional: Requires servo hardware
   [include nerdygriffin-macros/print_macros.cfg]        # Optional: PRINT_START/PRINT_END
   [include nerdygriffin-macros/rename_existing.cfg]
   [include nerdygriffin-macros/save_config.cfg]
   [include nerdygriffin-macros/shaketune.cfg]           # Optional: Requires Shake&Tune
   [include nerdygriffin-macros/shutdown.cfg]
   [include nerdygriffin-macros/status_macros.cfg]
   [include nerdygriffin-macros/tacho_macros.cfg]
   [include nerdygriffin-macros/utility_macros.cfg]
   ```

4. **Restart Klipper:**
   ```bash
   sudo systemctl restart klipper
   ```

## Configuration

Most macros work out-of-the-box with sensible defaults. Per-printer customization is done via variable overrides in `printer.cfg`.

**Quick Start - Minimal Configuration:**
```ini
# Client macro integration (required for pause/resume)
[gcode_macro _CLIENT_VARIABLE]
variable_user_pause_macro : "_AFTER_PAUSE"
variable_user_resume_macro: "_BEFORE_RESUME"
variable_user_cancel_macro: "_BEFORE_CANCEL"
gcode:

# LED configuration (required for status_macros.cfg)
[gcode_macro _LED_VARS]
variable_leds: {
    'logo': {'toolhead': 1},
    'nozzle': {'toolhead': '2-3'},
    'chamber': {}
}
gcode:
```

## Hardware Compatibility

### AFC (Armored Filament Changer)
Automatically detects and uses AFC macros when available:
- `AFC_PARK`, `AFC_BRUSH`, `AFC_CUT`

### Voron V0, V2, Trident, etc.
All macros calculate positions dynamically based on configured bed size and axis limits.

### LED Hardware
Dict-based `_LED_VARS` system supports any combination of neopixels across toolhead, logo, chamber, and bed zones.

## Dependencies

**Provided by this plugin:**
- `STATUS_*` macros
- `RESET_STATUS`
- `_AFTER_PAUSE`, `_BEFORE_RESUME`, `_BEFORE_CANCEL`

**Expected from your config:**
- `_CG28` - Conditional homing macro
- `SET_DISPLAY_TEXT` - LCD messages (provided by Mainsail/Klipper)
- `_CLIENT_VARIABLE` - Client variables (optional, see configuration)
- `encoder_sensor` - Filament sensor (optional)

**Common sources:**
- [Mainsail config](https://github.com/mainsail-crew/mainsail-config)
- [KAMP](https://github.com/kyleisah/Klipper-Adaptive-Meshing-Purging)
- [Shake&Tune](https://github.com/Frix-x/klippain-shaketune)

**Minimum Klipper version:** v0.13.0+

## Documentation

| Macro File | Description |
|-------|-------------|
| [auto_pid.cfg](docs/auto_pid.md) | Extruder and bed heater PID tuning |
| [beeper.cfg](docs/beeper.md) | Hardware-specific pin setup for audio feedback |
| [client_macros.cfg](docs/client_macros.md) | Mainsail/Fluidd pause/resume/cancel integration |
| [filament_management.cfg](docs/filament_management.md) | Load, unload, and purge with AFC auto-detect |
| [gcode_features.cfg](docs/gcode_features.md) | Enables advanced G-code features (force_move, pause/resume, arcs, etc.) |
| [heat_soak.cfg](docs/heat_soak.md) | Chamber preheating with LED animations |
| [homing.cfg](docs/homing.md) | Sensorless and conditional homing helpers |
| [maintenance_macros.cfg](docs/maintenance_macros.md) | Belt tension calibration and nozzle change utilities |
| [nozzle_wiper.cfg](docs/nozzle_wiper.md) | Servo-based nozzle cleaning with calibration guide |
| [print_macros.cfg](docs/print_macros.md) | PRINT_START/PRINT_END with hardware detection |
| [rename_existing.cfg](docs/rename_existing.md) | Safe G-code command overrides |
| [save_config.cfg](docs/save_config.md) | Configuration persistence and delayed saves |
| [shaketune.cfg](docs/shaketune.md) | Input shaper analysis wrappers |
| [shutdown.cfg](docs/shutdown.md) | Safe shutdown and host reboot operations |
| [status_macros.cfg](docs/status_macros.md) | LED system setup and customization |
| [tacho_macros.cfg](docs/tacho_macros.md) | Fan tachometer monitoring and pre-flight checks |
| [utility_macros.cfg](docs/utility_macros.md) | Common helper functions and utilities |

## Development

| Document | Description |
|----------|-------------|
| [dev/consolidation_roadmap.md](docs/dev/consolidation_roadmap.md) | Development history and planning |
| [dev/STYLE_GUIDE.md](docs/dev/STYLE_GUIDE.md) | Documentation formatting standards |
| [dev/TODO.md](docs/dev/TODO.md) | Development task tracking |

## Contributing

Contributions are welcome! Please submit a Pull Request.

## License

GNU General Public License v3.0 - See [LICENSE](LICENSE)

## Credits

Created by [NerdyGriffin](https://github.com/NerdyGriffin)

Inspired by:
- [AFC-Klipper-Add-On](https://github.com/ArmoredTurtle/AFC-Klipper-Add-On)
- [Voron Design](https://github.com/VoronDesign)
- [Mainsail](https://github.com/mainsail-crew/mainsail)

## Support

For issues or questions, join the [Voron Discord](https://discord.gg/voron).
