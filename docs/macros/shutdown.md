# Shutdown & Reboot (shutdown.cfg)

The `shutdown.cfg` provides macros for safe shutdown and reboot operations.

## Usage

```gcode
SHUTDOWN          # Safely shut down the printer
REBOOT_HOST       # Reboot the host system
```

**Note:** These macros perform cleanup operations before shutdown to ensure safe state.
