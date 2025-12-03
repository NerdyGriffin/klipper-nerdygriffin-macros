---
description: 'Audit copilot-instructions; report drift and propose diffs.'
agent: agent
model: Auto (copilot)
---

Audit `.github/copilot-instructions.md` across macros and both printers. Verify guidance matches current configs and propose minimal, non-destructive fixes.

- Files: the copilot-instructions in the macros repo and each printer repo.
- Compare with: current configs/macros in each repo (printer.cfg, print_macros, homing, status, and relevant macro files).
- copilot-instructions.md should avoid hard-coded values that may drift; prefer references to macros or config files.

Return the TODO list in a Markdown format, grouped by priority and issue type.

If we iterate on this prompt, repeat any TODO items from prior runs until resolved.
