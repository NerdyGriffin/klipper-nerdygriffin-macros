# klipper-nerdygriffin-macros

A collection of hardware-agnostic Klipper macros designed for Voron printers, with automatic AFC (Armored Filament Changer) detection and fallback support.

## Features

### 🎯 Filament Management (`filament_management.cfg`)
- **Hardware-agnostic parking**: Automatically uses AFC brush location if available, falls back to calculated positions
- **Conditional AFC support**: Detects and uses AFC_BRUSH, AFC_PARK, and AFC_CUT when available
- **Smart filament operations**:
  - `LOAD_FILAMENT` - Load filament with automatic heating and parking
  - `UNLOAD_FILAMENT` - Unload with optional cutting support (AFC)
  - `PURGE_FILAMENT` - Purge at a safe location
- **Unified cleanup**: Consistent sensor management and state restoration

### 🔧 Additional Macros

- **`auto_pid.cfg`** - Automated PID tuning for extruder and bed
- **`beeper.cfg`** - M300 beeper/tone support with sound macros (requires pin configuration)
- **`client_macros.cfg`** - Mainsail/Fluidd pause/resume/cancel hooks with optional AFC integration
- **`maintenance_macros.cfg`** - Maintenance helpers:
  - `NOZZLE_CHANGE_POSITION` - Park for nozzle changes with conditional NW_RETRACT support
  - `SETTLE_BELT_TENSION` - Belt settling routine with configurable calibrated position (Source: Andrew Ellis)
- **`rename_existing.cfg`** - Enhanced G-code overrides (M109, M190, M117, etc.)
- **`save_config.cfg`** - Safe SAVE_CONFIG with extruder cooling and print-state detection (includes delayed_save_config)
- **`shaketune.cfg`** - Shake&Tune wrapper macros with hardware-agnostic positioning and conditional Z_TILT_ADJUST
- **`shutdown.cfg`** - Safe shutdown with conditional cooling (includes delayed_shutdown for timed execution)
- **`tacho_macros.cfg`** - Part cooling fan preflight checks
- **`utility_macros.cfg`** - Utility helpers (macros: DEEP_CLEAN_NOZZLE, CENTER, UNSAFE_LOWER_BED; delayed: ENABLE/DISABLE_ENCODER_SENSOR)

## Installation

### Method 1: Automated Installation (Recommended)

1. **Clone and run the install script:**
   ```bash
   cd ~
   git clone https://github.com/NerdyGriffin/klipper-nerdygriffin-macros.git
   cd klipper-nerdygriffin-macros
   ./install.sh
   ```
   > **Note:**
   > The install script will create the symlink and optionally configure Moonraker's update_manager. It will detect your config directory automatically.

2. **Follow the on-screen instructions** to add the macros to your `printer.cfg`

3. **Restart Klipper and Moonraker**

### Method 2: Moonraker Auto-Update (Manual Setup)

1. **Clone the repository and create symlink:**
   ```bash
   cd ~
   git clone https://github.com/NerdyGriffin/klipper-nerdygriffin-macros.git
   ln -sf ~/klipper-nerdygriffin-macros/macros ~/printer_data/config/nerdygriffin-macros
   ```
   > **Note:**
   > This will clone the repository to your home directory and create a symbolic link in your config folder for easy access. If you have an older Klipper setup, your config path may be different (e.g., `~/klipper_config/`).

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
   [include nerdygriffin-macros/maintenance_macros.cfg]
   [include nerdygriffin-macros/rename_existing.cfg]
   [include nerdygriffin-macros/save_config.cfg]
   [include nerdygriffin-macros/shaketune.cfg]           # Optional: Requires Shake&Tune installed
   [include nerdygriffin-macros/shutdown.cfg]
   [include nerdygriffin-macros/tacho_macros.cfg]
   [include nerdygriffin-macros/utility_macros.cfg]
   ```

5. **Restart Klipper:**
   ```bash
   sudo systemctl restart klipper
   ```

### Method 3: Manual Installation

1. **Clone the repository and create symlink:**
   ```bash
   cd ~
   git clone https://github.com/NerdyGriffin/klipper-nerdygriffin-macros.git
   ln -sf ~/klipper-nerdygriffin-macros/macros ~/printer_data/config/nerdygriffin-macros
   ```

2. **Include in printer.cfg** (same as above)

3. **Restart Klipper**

## Configuration

### Client Macros Configuration (Required for client_macros.cfg)

The client macros require `_CLIENT_VARIABLE` override in your `printer.cfg` to hook into Mainsail/Fluidd pause/resume/cancel:

```ini
[gcode_macro _CLIENT_VARIABLE]
variable_custom_park_x    : 5.0
variable_custom_park_y    : 5.0
variable_retract          : 30.0
variable_unretract        : 30.0
variable_speed_hop        : 150.0
variable_speed_move       : 1000.0
variable_park_at_cancel   : True
variable_use_fw_retract   : False
variable_user_pause_macro : "_AFTER_PAUSE"    # Hook to plugin macro
variable_user_resume_macro: "_BEFORE_RESUME"  # Hook to plugin macro
variable_user_cancel_macro: "_BEFORE_CANCEL"  # Hook to plugin macro
gcode:
```

**Note:** The `_AFTER_PAUSE`, `_BEFORE_RESUME`, and `_BEFORE_CANCEL` macros from the plugin handle filament sensor management and optional AFC integration. See [mainsail.cfg](https://github.com/mainsail-crew/mainsail-config/blob/master/client.cfg) for all available `_CLIENT_VARIABLE` options.

### Beeper Pin Configuration (Required for beeper.cfg)

The beeper requires hardware-specific pin configuration. Add this to your `printer.cfg` **after** including `beeper.cfg`:

```ini
[pwm_cycle_time beeper]
pin: YOUR_PIN_HERE    # Examples below

# Common pins by board:
#   Raspberry Pi GPIO: gpio23, gpio24, gpio25
#   BTT Octopus:       PE5
#   BTT SKR:           PA8, PB15
#   RAMPS:             ar37
#   Fysetc Spider:     PA15
```

### Customizing Filament Parking Positions

The filament macros automatically detect AFC hardware and use appropriate parking positions. For non-AFC setups, you can customize the parking positions:

```ini
[gcode_macro _FILAMENT_PARK_PARAMS]
variable_load_x: 60.0          # X position for load/unload (None = auto: bed center)
variable_load_y: 10.0          # Y position for load/unload (None = auto: front + 10mm)
variable_purge_x: 10.0         # X position for purge (None = auto: 10mm)
variable_purge_y: 10.0         # Y position for purge (None = auto: front + 10mm)
```

**Note:** Set any coordinate to `None` to use automatic calculation based on your bed size. Z height is automatically calculated as 75% of max Z, rounded down to the nearest 10mm.

### Customizing Filament Distances

Override macro variables in your `printer.cfg`:

```ini
# Example: Adjust for your specific hotend
[gcode_macro LOAD_FILAMENT]
variable_load_distance: 60      # Distance to load (default: 60mm)
variable_purge_distance: 100    # Distance to purge (default: 100mm)

[gcode_macro UNLOAD_FILAMENT]
variable_unload_distance: 65    # Distance to unload (default: 65mm)
variable_purge_distance: 12.45  # Purge before unload (default: 12.45mm)
```

### Customizing Belt Tension Calibration Position

The `SETTLE_BELT_TENSION` macro parks at a calibrated Y position for belt frequency measurement. Override the position in your `printer.cfg`:

```ini
# Override calibrated Y position for belt tension measurement
[gcode_macro SETTLE_BELT_TENSION]
variable_y_calibrated: 116  # The Y position that results in exactly 130mm between idler centers
                            # Common values: 116 (V0 120mm bed), 120 (Trident 300mm bed)
                            # Measure your actual belt span and adjust accordingly
```

**Note:** The Y calibrated position depends on your specific printer geometry and desired belt span for frequency measurement. See the macro comments for frequency targets at different belt lengths.

## Hardware Compatibility

### AFC (Armored Filament Changer)
If AFC is installed, the macros automatically detect and use:
- `AFC_PARK` - For parking operations
- `AFC_BRUSH` - For nozzle cleaning
- `AFC_CUT` - For filament cutting during unload

### Non-AFC Printers
Macros automatically fall back to:
- Calculated center/front positions for parking
- Skip brushing operations gracefully
- Standard purge-based unload

### Voron V0, V2, Trident, etc.
All macros calculate positions dynamically based on your printer's configured bed size and axis limits.

## Dependencies

These macros expect the following to be defined in your config:

- `_CG28` - Conditional homing macro
- `STATUS_*` macros - For status LED updates (e.g., from stealthburner_leds.cfg)
- `RESET_STATUS` - Reset status LEDs
- `SET_DISPLAY_TEXT` - For LCD/web interface messages
- `_CLIENT_VARIABLE` - Mainsail/Fluidd client variables
- `encoder_sensor` - Filament motion sensor (or modify macro accordingly)

Most of these are provided by:
- [Mainsail config](https://github.com/mainsail-crew/mainsail-config)
- [Voron Design configs](https://github.com/VoronDesign/Voron-Stealthburner)

## Usage

### Filament Operations
```gcode
LOAD_FILAMENT                    # Load with default temp
LOAD_FILAMENT TEMP=240           # Load at specific temp
UNLOAD_FILAMENT                  # Unload with default temp
UNLOAD_FILAMENT TEMP=240         # Unload at specific temp
PURGE_FILAMENT                   # Purge 100mm
PURGE_FILAMENT TEMP=230 SPEED=200  # Custom purge
```

### PID Calibration
```gcode
AUTO_PID_CALIBRATE HEATER=extruder TARGET=260
AUTO_PID_CALIBRATE HEATER=heater_bed TARGET=100
```

### Shutdown Operations
```gcode
SHUTDOWN                         # Immediate shutdown
SAFE_SHUTDOWN                    # Shutdown with safety checks
SET_COMPLETE_SHUTDOWN ENABLE=1   # Enable post-print shutdown
CONDITIONAL_SHUTDOWN             # Shutdown if enabled
```

### Preflight Check
```gcode
PREFLIGHT_CHECK                  # Check part cooling fan before print
```

### Utility Macros
```gcode
DEEP_CLEAN_NOZZLE                # Deep clean with temp stepping
DEEP_CLEAN_NOZZLE TEMP=280       # Start cleaning from specific temp
CENTER                           # Move toolhead to bed center
UNSAFE_LOWER_BED                 # Emergency: lower bed 10mm without homing
```

**Delayed G-code (automatic, not called directly):**
- `ENABLE_ENCODER_SENSOR` - Auto-enables filament encoder sensor after delay
- `DISABLE_ENCODER_SENSOR` - Auto-disables filament encoder sensor on startup

### Safe Config Saving
```gcode
SAFE_SAVE_CONFIG                 # Save config with safety checks
SET_COMPLETE_SAVE_CONFIG ENABLE=1  # Enable post-print save
CONDITIONAL_SAVE_CONFIG          # Save if enabled (called automatically)
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

GNU General Public License v3.0 - See LICENSE file for details

## Credits

Created by [NerdyGriffin](https://github.com/NerdyGriffin) for use with Voron 3D printers.

Inspired by and compatible with:
- [AFC-Klipper-Add-On](https://github.com/ArmoredTurtle/AFC-Klipper-Add-On)
- [Voron Design](https://github.com/VoronDesign)
- [Mainsail](https://github.com/mainsail-crew/mainsail)
- [Klicky-Probe](https://github.com/jlas1/Klicky-Probe)

## Support

For issues or questions:
- Open an issue on [GitHub](https://github.com/NerdyGriffin/klipper-nerdygriffin-macros/issues)
- Join the [Voron Discord](https://discord.gg/voron)
