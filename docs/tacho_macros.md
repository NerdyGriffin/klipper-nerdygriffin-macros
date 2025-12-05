# Tachometer Macros (tacho_macros.cfg)

The `tacho_macros.cfg` provides utilities for monitoring fan tachometer feedback and performing pre-flight checks.

## Usage

```gcode
PREFLIGHT_CHECK    # Pre-print fan test: spins up part fan and verifies RPM
```

This macro will automatically cancel the print if the part cooling fan fails the self-test (RPM < 500).

## Internal Macros

- `PCF_CHECK` - Internal sub-macro called by `PREFLIGHT_CHECK` (do not call directly)
