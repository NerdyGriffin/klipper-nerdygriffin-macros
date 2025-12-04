# Client Macros (client_macros.cfg)

The client macros require `_CLIENT_VARIABLE` override in your `printer.cfg` to hook into Mainsail/Fluidd pause/resume/cancel:

```ini
[gcode_macro _CLIENT_VARIABLE]
variable_park_at_cancel   : True
variable_user_pause_macro : "_AFTER_PAUSE"    # Hook to plugin macro
variable_user_resume_macro: "_BEFORE_RESUME"  # Hook to plugin macro
variable_user_cancel_macro: "_BEFORE_CANCEL"  # Hook to plugin macro
gcode:
```

**Note:** The `_AFTER_PAUSE`, `_BEFORE_RESUME`, and `_BEFORE_CANCEL` macros from the plugin handle filament sensor management and optional AFC integration. See [mainsail.cfg](https://github.com/mainsail-crew/mainsail-config/blob/master/client.cfg) for all available `_CLIENT_VARIABLE` options.
