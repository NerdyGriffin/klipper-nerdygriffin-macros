# Save Config (save_config.cfg)

The `save_config.cfg` provides utilities for safely saving printer configuration with conditional scheduling.

## Usage

```gcode
SAFE_SAVE_CONFIG                   # Save config with safety checks (immediate)
SET_COMPLETE_SAVE_CONFIG [ENABLE=1] # Enable/disable post-print save
GET_COMPLETE_SAVE_CONFIG           # Check if post-print save is enabled
```

### SET_COMPLETE_SAVE_CONFIG Parameters

| parameters | default value | description |
|-----------:|---------------|-------------|
| ENABLE | 1 | Set to 1 to enable post-print save, 0 to disable |

## Behavior

- `SAFE_SAVE_CONFIG` checks if a job is active, cools extruder to 60°C, then saves
- `SET_COMPLETE_SAVE_CONFIG` schedules automatic save after print completion
- `CONDITIONAL_SAVE_CONFIG` executes the scheduled save (called automatically by `PRINT_END`)

## Internal Macros

These macros are called automatically and should not be called directly:

- `CONDITIONAL_SAVE_CONFIG` - Executes scheduled save if enabled
- `delayed_save_config` - Delayed G-code for deferred save execution
