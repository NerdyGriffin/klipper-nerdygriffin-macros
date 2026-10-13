---
agent: agent
model: Auto (copilot)
description: 'Review AGENTS.md for outdated information and consistency'
---

Audit `AGENTS.md` in the macros repo and both printer repos for claims the current configs contradict, and propose minimal, non-destructive fixes.

- `AGENTS.md` is the vendor-neutral source of truth for agent guidance, surfaced to Claude Code via the `CLAUDE.md` `@AGENTS.md` import and to GitHub Copilot via the `.github/copilot-instructions.md` symlink. Review `AGENTS.md`, not the pointers.
- The `.cfg` files, macros, and scripts are the ground truth; `AGENTS.md` describes them. A finding is a claim in `AGENTS.md` that a specific line in the repo contradicts today, and it cites that line. Never propose editing a config to match the docs.
- When two passages disagree, use `git blame` / `git log` to establish which is newer and quote both. If history does not settle it, ask me rather than guess; do not infer which side is current from wording or level of detail.
- `AGENTS.md` should avoid hard-coded values that may drift; prefer references to macros or config files.
- Anything you cannot verify against the repo is a question for me, not a finding.

Report: lead with the two or three findings that matter most, then one line per verified finding (`AGENTS.md:line`, what is wrong,
the contradicting evidence, the proposed edit), then a separate list of open questions. Leave out style preferences and content
that is redundant but correct. Fewer well-grounded findings beat a long list.

Carry forward any unresolved TODO items from earlier runs in this conversation.
