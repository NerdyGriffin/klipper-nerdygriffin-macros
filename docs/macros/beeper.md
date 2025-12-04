# Beeper Configuration (beeper.cfg)

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
