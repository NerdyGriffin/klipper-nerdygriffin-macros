# Beeper (beeper.cfg)

The `beeper.cfg` provides tone and melody macros. The beeper requires hardware-specific pin configuration.

## Configuration

Add the beeper pin configuration to your `printer.cfg` **after** including `beeper.cfg`:

```ini
[pwm_cycle_time beeper]
pin: YOUR_PIN_HERE    # Required: set your board's beeper pin
```

### Common Pins by Board

| Board | Pin Examples |
|:------|--------------|
| Raspberry Pi GPIO | gpio23, gpio24, gpio25 |
| BTT Octopus | PE5 |
| BTT SKR Pico | gpio23 |
| BTT SKR | PA8, PB15 |
| RAMPS | ar37 |
| Fysetc Spider | PA15 |

> **Note**:
>
> Replace `YOUR_PIN_HERE` with the appropriate pin for your control board. The beeper is automatically used by various macros for status tones.
