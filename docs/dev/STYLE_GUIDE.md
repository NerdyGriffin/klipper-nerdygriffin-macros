# Documentation Style Guide

This guide standardizes documentation format across all macro documentation files in this repository. Each documentation file corresponds to a `.cfg` file that may contain one or more related macros.

## File Structure

Each documentation file documents a config file (`.cfg`) that may contain multiple related macros. Use this structure:

```
# [Feature Name] ([config_file.cfg])

[One-sentence description of what the config file provides]

## Usage

[How to call the user-facing macro(s), with example gcode commands]

### [MACRO_NAME] Parameters (only if macro accepts parameters)

[Parameter table for this specific macro]

### [ANOTHER_MACRO] Parameters (if file has multiple user-facing macros)

[Parameter table for another macro]

[Optional: Warning/Note blockquote if applicable]

## Internal Macros (only if file has helper macros)

[Brief description of helper macros that users typically don't call directly]

## Configuration (only if macros have configurable variables)

[General pattern showing how to override/customize variables in printer.cfg]

[Optional: Default variables list with explanations]

## Examples (as needed)

[Specific configuration examples for different use cases]
```

**Note:** Sections are optional based on the file's contents:
- Omit `### [MACRO_NAME] Parameters` if no macros accept user-facing parameters
- Omit `## Internal Macros` if file has no helper/internal macros
- Omit `## Configuration` if macros have no configurable variables
- Omit `## Examples` if all details are covered in Usage or Configuration
- Keep documentation minimal to reduce maintenance burden as the project evolves

## File Heading Format

- **File heading**: `# [Feature Name] ([config_file.cfg])`
  - Example: `# Heat Soak Configuration (heat_soak.cfg)`
  - The feature name should describe the overall purpose, not a single macro
- **Brief intro paragraph** immediately after heading (1-2 sentences describing what the file provides)

## Usage Section

The `## Usage` section should contain:

1. **Example gcode calls** in a gcode code block showing typical usage of all user-facing macros
   ```gcode
   MACRO_NAME PARAM1=value PARAM2=value
   ANOTHER_MACRO                          # If file has multiple macros
   MACRO_WITH_OPTIONAL_PARAM [OPTIONAL_PARAM1=default_value] # Use linux style [] for optional stuff in command examples
   ```

2. **Parameter tables** for each macro that accepts parameters:
   - Use `### MACRO_NAME Parameters` as the subsection heading
   - Column 1: `Parameters` (right-aligned)
   - Column 2: `Default Value` (left-aligned)
   - Column 3: `Description` (left-aligned)
   - **CRITICAL**: All descriptions must start with a **capitalized letter**
   - If a macro has no parameters, omit its parameter subsection entirely

3. **Parameter table example**:
   ```markdown
   ### HEAT_SOAK Parameters

   | parameters | default value | description |
   |-----------:|---------------|-------------|
   | CHAMBER | None | Target chamber temperature in °C. If not specified, the macro calculates a target based on bed temperature. |
   | DURATION | 0 | Soak duration in minutes (0 = wait until chamber reaches target) |
   ```

## Internal Macros Section

If a config file contains helper macros that users typically don't call directly, document them in an `## Internal Macros` section:

```markdown
## Internal Macros

These macros are called automatically by other macros and should not be called directly:

- `_HELPER_MACRO` - Brief description of what it does
- `_ANOTHER_HELPER` - Another brief description

### Delayed G-code Macros

The following delayed G-code macros manage automatic timing:

- `ENABLE_SOMETHING` - Enables feature after delay
- `DISABLE_SOMETHING` - Disables feature (runs at startup to prevent false triggers)
```

> **Note**:
>
> Internal macros use an underscore prefix (`_MACRO_NAME`) by convention. Delayed G-code macros are defined with `[delayed_gcode NAME]` sections.

## Configuration Section

The `## Configuration` section should contain:

1. **General override pattern** showing how to customize macros in `printer.cfg`
   - Use `ini` code blocks for Klipper config syntax
   - Show the `[gcode_macro MACRO_NAME]` section with `variable_*` overrides
   - Include inline comments explaining what each variable does
   - **Only show variables that differ from defaults** (omit default values)
   - **Omit the `gcode:` line** from config override examples
   - For files with multiple macros, group related overrides logically

2. **Shared configuration macros** (if applicable)
   - Some files use a dedicated `[gcode_macro _*_VARS]` or `[gcode_macro _*_SETTINGS]` macro for shared variables
   - Document these separately from per-macro variables

3. **Default variables list** (if file has many configurable variables)
   - List all available variables with their default values
   - Explain what each variable controls
   - Use backticks for variable names

4. **Configuration format**:
   ```markdown
   ## Configuration

   To customize shared settings for all filament macros:

   ```ini
   [gcode_macro _FILAMENT_PARK_PARAMS]
   variable_load_x: 60.0    # Custom X position for load/unload
   variable_load_y: 10.0    # Custom Y position for load/unload
   ```

   To customize individual macro behavior:

   ```ini
   [gcode_macro LOAD_FILAMENT]
   variable_load_distance: 50  # Adjust for your hotend
   ```

   Default variables (override in printer.cfg):
   - `variable_param1: default1` - Explanation of what this controls
   - `variable_param2: default2` - Another explanation
   ```

## Examples Section

The `## Examples` section should contain:

1. **Multiple specific use cases** showing different printer setups or complexity levels
   - Use descriptive subsection headings (e.g., "### For V0", "### Advanced Setup")
   - Use `ini` code blocks for Klipper config syntax
   - Show complete `[gcode_macro MACRO_NAME]` sections with relevant variables
   - **Only show variables that differ from defaults**
   - Include contextual explanations for why each example is useful

2. **Auto-detection logic explanations** (if applicable)
   - Explain what hardware/features the macro automatically detects
   - Show how the macro behaves when optional hardware is present vs. absent

3. **Example format**:
   ```markdown
   ### For V0 (Small Chamber)

   For Voron V0 with limited chamber heating, reduce the max target:

   ```ini
   [gcode_macro HEAT_SOAK]
   variable_max_chamber_target: 58  # V0 chambers struggle above 58°C
   ```

   ### Advanced Setup with Multiple Sensors

   ```ini
   [gcode_macro MY_MACRO]
   variable_sensor_primary: "chamber"
   variable_sensor_backup: "nitehawk-36"
   ```
   ```

## Code Block Standards

- **Gcode examples**: Use ` ```gcode ` blocks
  - Show actual G-code macro calls that users would execute
  - Include comments explaining what each line does

- **Configuration examples**: Use ` ```ini ` blocks
  - Show Klipper config syntax (INI format)
  - Include inline comments with `#`

- **Bash/terminal commands**: Use ` ```bash ` blocks
  - Include the command and expected output

## Capitalization Rules

### Parameter Table Descriptions
- **ALWAYS start with a capital letter** (first letter of description)
- Examples:
  - ✅ "Target bed temperature in °C"
  - ❌ "target bed temperature in °C"
  - ✅ "Heater name to calibrate (extruder or heater_bed)"
  - ❌ "heater name to calibrate (extruder or heater_bed)"

### Section Headings
- Use title case for `## Usage`, `## Examples`, `## Configuration`
- Use descriptive names for subsections: `### Simple Setup`, `### Advanced Setup`, `### For V0 (Ender 3)`

### Inline Code
- Use backticks for: variable names, macro names, file names, config section names
  - ✅ `variable_max_chamber_target`, `HEAT_SOAK`, `printer.cfg`, `[gcode_macro]`

## Blockquote Standards

Use blockquotes for important notes:

```markdown
> **Note**:
>
> This is an important note or clarification.

> **Warning**:
>
> This is a warning about potential issues or dangers.
```

## Cross-References

Link to other documentation using relative paths:

```markdown
[See status_macros.md for complete LED configuration](./macros/status_macros.md)
[Check heat_soak.md for chamber sensor setup](./macros/heat_soak.md)
```

## Common Patterns

### Conditional Hardware
When documenting hardware-agnostic macros that auto-detect features:

```markdown
The macro automatically detects:
1. AFC (Automated Filament Control) - if available
2. CLEAN_NOZZLE macro - if available
3. Beacon probe - if available

It gracefully handles missing features without errors.
```

### Variables vs Parameters
- **Parameters**: Values passed to a macro when called (e.g., `CHAMBER=50` in `HEAT_SOAK CHAMBER=50`)
- **Variables**: Configurable values defined in `[gcode_macro]` sections in printer.cfg
- **Shared Variables**: Variables in a dedicated config macro (e.g., `_FILAMENT_PARK_PARAMS`) that affect multiple user-facing macros

Document parameters in parameter tables under `## Usage`, and document variables in `## Configuration`.

### Default Variables List
If a config file has many configurable variables, you may include a list:

```markdown
## Configuration

Default variables (override in printer.cfg):
- `variable_max_chamber_target: 60` - Maximum chamber temp achievable
- `variable_ext_assist_multiplier: 4` - Extruder assist multiplier
- `variable_chamber_sensor_name: ""` - Explicit sensor name (empty = auto-detect)
```

## Table Alignment

Use left-aligned text for readability:

```markdown
| parameters | default value | description |
|-----------:|---------------|-------------|
| PARAM1     | value1        | Description here |
```

- Column 1: `----------:` (right-align)
- Column 2: `-----------` (left-align)
- Column 3: `-----------` (left-align)

## Checklist for New Documentation

- [ ] File heading includes config filename in parentheses
- [ ] Brief 1-2 sentence intro describing what the config file provides
- [ ] `## Usage` section with gcode examples for all user-facing macros
- [ ] Parameter subsections for each macro that accepts parameters
- [ ] `## Internal Macros` section if file has helper or delayed_gcode macros
- [ ] `## Configuration` section if macros have overridable variables
- [ ] `## Examples` section with `printer.cfg` config snippets (if helpful)
- [ ] All variable names use backticks
- [ ] All macro names use UPPER_CASE and backticks
- [ ] Cross-references use relative paths
- [ ] Important notes/warnings in blockquotes
- [ ] Code blocks use correct language (`gcode`, `ini`, `bash`)
- [ ] All links are functional (test with markdown preview)

## Questions?

When documenting a new config file, ask:
1. Which macros are user-facing vs. internal helpers?
2. What parameters does each user-facing macro accept?
3. What variables can the user override in printer.cfg?
4. Are there shared configuration macros (e.g., `_*_VARS`) for common settings?
5. What hardware dependencies or conditions apply?
6. Are there delayed_gcode macros that need documentation?
7. Should any macros cross-reference other documentation files?
