---
agent: agent
model: Auto (copilot)
description: 'Review AGENTS.md for outdated information and consistency'
---

Audit `AGENTS.md` across the macros repo and both printer repos. Verify guidance matches current configs and propose minimal, non-destructive fixes.

- Files: `AGENTS.md` in the macros repo and each printer repo. It is the vendor-neutral source of truth, surfaced to Claude Code via the `CLAUDE.md` `@AGENTS.md` import and to GitHub Copilot via the `.github/copilot-instructions.md` symlink — review `AGENTS.md`, not the pointers.
- Compare with: current configs/macros in each repo (printer.cfg, print_macros, homing, status, and relevant macro files).
- `AGENTS.md` should avoid hard-coded values that may drift; prefer references to macros or config files.

Return the TODO list in a Markdown format, grouped by priority and issue type. Use numbered lists for easy reference.

If we iterate on this prompt, repeat any TODO items from prior runs until resolved.
