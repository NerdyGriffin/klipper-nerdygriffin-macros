# Shutdown & Reboot (shutdown.cfg)

The `shutdown.cfg` provides macros for safe shutdown and reboot operations with conditional shutdown and reboot scheduling.

## Usage

```gcode
SHUTDOWN                          # Immediate shutdown (plays tone first)
REBOOT                            # Immediate reboot (plays tone first)
SAFE_SHUTDOWN                     # Shutdown with safety checks (blocks during print)
SET_COMPLETE_SHUTDOWN [ENABLE=1]  # Enable/disable post-print shutdown
GET_COMPLETE_SHUTDOWN             # Check if post-print shutdown is enabled
SET_COMPLETE_REBOOT [ENABLE=1]    # Enable/disable post-print reboot
GET_COMPLETE_REBOOT               # Check if post-print reboot is enabled
```

### SET_COMPLETE_SHUTDOWN Parameters

| parameters | default value | description |
| ---: | --- | --- |
| ENABLE | 1 | Set to 1 to enable post-print shutdown, 0 to disable |

### SET_COMPLETE_REBOOT Parameters

| parameters | default value | description |
| ---: | --- | --- |
| ENABLE | 1 | Set to 1 to enable post-print reboot, 0 to disable |

## Behavior

- `SAFE_SHUTDOWN` checks if a job is active, cools extruder to 60°C, then shuts down
- `SET_COMPLETE_SHUTDOWN` schedules automatic shutdown after print completion
- `SET_COMPLETE_REBOOT` schedules automatic reboot after print completion
- `CONDITIONAL_SHUTDOWN` executes the scheduled shutdown (called automatically by `PRINT_END`)
- `CONDITIONAL_REBOOT` executes the scheduled reboot the same way, after cooling the extruder to 60°C
- If both are scheduled, the shutdown takes precedence and the reboot is skipped

## Internal Macros

These macros are called automatically and should not be called directly:

- `CONDITIONAL_SHUTDOWN` - Executes scheduled shutdown if enabled
- `CONDITIONAL_REBOOT` - Executes scheduled reboot if enabled and no shutdown is scheduled
- `delayed_shutdown` - Delayed G-code for deferred shutdown or reboot execution
