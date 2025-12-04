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

### 🎨 Status & LED Management (`status_macros.cfg`)
- **Hardware-agnostic LED control**: Dict-based `_LED_VARS` system adapts to any printer's LED configuration
- **Status macros**: `STATUS_*` macros (HEATING, PRINTING, HOMING, MESHING, etc.) with automatic LED control
- **LED animations**: `HEAT_SOAK` includes animated chamber progress bar and logo fade
- **Zero configuration**: Sensible defaults work out-of-the-box; customize via `_LED_VARS` override in `printer.cfg`

### 🔧 Additional Macros

- **`auto_pid.cfg`** - Automated PID tuning for extruder and bed
- **`beeper.cfg`** - M300 beeper/tone support with sound macros (requires pin configuration)
- **`client_macros.cfg`** - Mainsail/Fluidd pause/resume/cancel hooks with optional AFC integration
- **`heat_soak.cfg`** - Hardware-agnostic chamber preheating with auto-sensor detection, LED animations, and M191 support
- **`maintenance_macros.cfg`** - Maintenance helpers:
  - `NOZZLE_CHANGE_POSITION` - Park for nozzle changes with conditional NW_RETRACT support
  - `SETTLE_BELT_TENSION` - Belt settling routine with configurable calibrated position (Source: Andrew Ellis)
- **`rename_existing.cfg`** - Enhanced G-code overrides (M109, M190, M117, etc.)
- **`save_config.cfg`** - Safe SAVE_CONFIG with extruder cooling and print-state detection (includes delayed_save_config)
- **`shaketune.cfg`** - Shake&Tune wrapper macros with hardware-agnostic positioning and conditional Z_TILT_ADJUST
- **`shutdown.cfg`** - Safe shutdown with conditional cooling (includes delayed_shutdown for timed execution)
- **`tacho_macros.cfg`** - Part cooling fan preflight checks
- **`utility_macros.cfg`** - Utility helpers (macros: DEEP_CLEAN_NOZZLE, CENTER, UNSAFE_LOWER_BED; delayed: ENABLE/DISABLE_ENCODER_SENSOR)

#### Utility Macros (details)
- **DEEP_CLEAN_NOZZLE**: Runs a multi-step nozzle clean with temperature stepping; optionally accepts `TEMP=<start>` to begin at a specific temperature.
- **CENTER**: Moves the toolhead to the calculated bed center using configured axis limits.
- **UNSAFE_LOWER_BED**: Lowers the bed by 10mm without requiring homing; intended for recovery situations only.
- **ENABLE_ENCODER_SENSOR / DISABLE_ENCODER_SENSOR** (delayed): Automatically scheduled helpers to enable the `encoder_sensor` during active printing and disable it on startup/idle; not intended to be called directly.

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
   [include nerdygriffin-macros/heat_soak.cfg]
   [include nerdygriffin-macros/maintenance_macros.cfg]
   [include nerdygriffin-macros/rename_existing.cfg]
   [include nerdygriffin-macros/save_config.cfg]
   [include nerdygriffin-macros/shaketune.cfg]           # Optional: Requires Shake&Tune installed
   [include nerdygriffin-macros/shutdown.cfg]
   [include nerdygriffin-macros/tacho_macros.cfg]
   [include nerdygriffin-macros/utility_macros.cfg]
   ```

4. **Restart Klipper:**
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

### Status Macros & LED Configuration (Required for status_macros.cfg)

The status macros use a hardware-agnostic dict-based LED configuration system (`_LED_VARS`). This allows all printers to use the same macros regardless of their LED hardware.

**Quick Setup (Toolhead LEDs Only):**
Add this to your `printer.cfg` after including `status_macros.cfg`:

```ini
[gcode_macro _LED_VARS]
variable_chamber_map: {}
variable_logo_map: {'toolhead': 1}
variable_nozzle_map: {'toolhead': '2,3'}
gcode:
```

Replace `toolhead` with your actual neopixel device name(s) and adjust indices (1, 2, 3) to match your LED configuration.

**Complete Setup Guide:**
See [`docs/LED_VARIABLES.md`](docs/LED_VARIABLES.md) for:
- Detailed configuration examples for various printer types
- How to use multiple LED devices
- LED animation behavior during `HEAT_SOAK`
- How to add custom LED devices

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
- `STATUS_*` macros - **Provided by `status_macros.cfg`** (or from other LED macro libraries like stealthburner_leds.cfg)
- `RESET_STATUS` - **Provided by `status_macros.cfg`**
- `SET_DISPLAY_TEXT` - For LCD/web interface messages (provided by Mainsail/Klipper)
- `_CLIENT_VARIABLE` - Mainsail/Fluidd client variables (optional, for pause/resume hooks)
- `encoder_sensor` - Filament motion sensor (optional, or modify macro accordingly)

Most of the remaining dependencies are provided by:
- [Mainsail config](https://github.com/mainsail-crew/mainsail-config)
- [Voron Design configs](https://github.com/VoronDesign/Voron-Stealthburner)
- [KAMP (Klipper Adaptive Meshing & Purging)](https://github.com/kyleisah/Klipper-Adaptive-Meshing-Purging)
- [Shake&Tune](https://github.com/Frix-x/klippain-shaketune)

### Compatibility
- Minimum Klipper version: v0.13.0 (tested on stable channel; managed via Moonraker `update_manager`)
- For the latest tuned values (e.g., pressure advance), consult your `printer.cfg` rather than this README.

## Usage

### Status Macros
```gcode
STATUS_HEATING      # Red/orange LEDs, "Heating..." message
STATUS_HOMING       # Cyan LEDs, "Homing..." message
STATUS_LEVELING     # Purple LEDs, "Leveling..." message
STATUS_MESHING      # Lime LEDs, "Meshing..." message
STATUS_CLEANING     # Blue LEDs, "Cleaning..." message
STATUS_PRINTING     # Blue logo, white nozzle, white chamber, no message
STATUS_READY        # Dim white LEDs, no message
STATUS_OFF          # All LEDs off, no message
RESET_STATUS        # Auto-select PRINTING or READY based on printer state
```

All status macros automatically respect your `_LED_VARS` configuration and adapt to your printer's LED setup.

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

### Heat Soak
```gcode
HEAT_SOAK CHAMBER=50 DURATION=10 # Heat soak chamber to 50C for 10 minutes
M191 S50                          # Marlin-style chamber wait (uses HEAT_SOAK to emulate chamber heating)
```

**Delayed G-code (automatic, not called directly):**
- `ENABLE_ENCODER_SENSOR` - Auto-enables filament encoder sensor after delay
- `DISABLE_ENCODER_SENSOR` - Auto-disables filament encoder sensor on startup

Note: The enable/disable helpers are triggered by print lifecycle macros (e.g., `PRINT_START`/`PRINT_END`) or delayed_gcode scheduling within this library; they do not require manual invocation.

### Heat Soak Configuration (optional overrides)

The `HEAT_SOAK` macro provides hardware-agnostic chamber preheating with optional LED animations. It auto-detects chamber temperature sensors and supports per-printer customization.

**Default Variables:**
- `variable_max_chamber_temp: 60` - Maximum chamber temp achievable via passive heating (stock hotend and bed heaters, no additional insulation)
- `variable_ext_assist_multiplier: 4` - Extruder assist temp multiplier (chamber_temp × multiplier, capped at 200°C)
- `variable_chamber_sensor_name: ""` - Explicit sensor name (empty = auto-detect)
- `variable_frame_rate: 12` - LED animation frame rate in Hz (12 FPS default)

**LED Animation:**
- Uses `_LED_VARS` dict-based system (see [`docs/LED_VARIABLES.md`](docs/LED_VARIABLES.md) for full details)
- `chamber_map`: Animates chamber/enclosure LEDs with red→green progress bar
- `logo_map`: Fades logo/bed light from red→green alongside chamber animation
- Safe by design: missing devices are automatically skipped

**Auto-Detection Logic:**
The macro searches for chamber sensors in this order:
1. Explicit `chamber_sensor_name` (if provided)
2. `temperature_sensor chamber`
3. `temperature_sensor nitehawk-36` (toolhead proxy)

**Example Overrides:**

For V0 (measured limits, stronger assist):
```ini
[gcode_macro HEAT_SOAK]
variable_max_chamber_temp: 58           # V0 measured limit
variable_ext_assist_multiplier: 5       # Stronger extruder assist for V0
variable_chamber_sensor_name: "chamber" # Explicit sensor name (if available)
```

For printers with toolhead-only sensors:
```ini
[gcode_macro HEAT_SOAK]
variable_chamber_sensor_name: "nitehawk-36"  # Use toolhead as temperature proxy
```

For custom LED animation speed:
```ini
[gcode_macro HEAT_SOAK]
variable_frame_rate: 8  # Slower animation (8 FPS instead of 12)
```

**LED Configuration:**
See [`docs/LED_VARIABLES.md`](docs/LED_VARIABLES.md) for detailed LED setup examples. Quick setup for toolhead-only:
```ini
[gcode_macro _LED_VARS]
variable_chamber_map: {}
variable_logo_map: {'toolhead': 1}
variable_nozzle_map: {'toolhead': '2,3'}
```

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
