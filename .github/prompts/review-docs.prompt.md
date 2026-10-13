---
agent: agent
model: Auto (copilot)
description: 'Perform a review of all documentation'
---

Review the user-facing documentation in every repository in this workspace for claims the current configs, macros, and scripts contradict, for references that no longer resolve, and for departures from the style guide in `docs/dev/MARKDOWN_STYLE_GUIDE.md` (macros repo).

- The code is the ground truth; the docs describe it. A finding cites the repo line that contradicts the doc. Never propose editing code to match the docs.
- Flag references to files that are untracked, outside the workspace, or missing from the documentation index, and suggest either tracking the file or removing the reference.
- When two passages disagree, use `git blame` / `git log` to establish which is newer and quote both. If history does not settle it, ask me rather than guess.
- Anything you cannot verify against the repo is a question for me, not a finding.
- Focus on documentation accuracy and clarity; do not suggest implementing features or functionality.

Report in chat: lead with the two or three findings that matter most, then one line per verified finding (`file:line`, what is
wrong, the contradicting evidence or style-guide rule, the proposed edit), then a separate list of open questions. Leave out
personal style preferences the style guide does not cover and content that is redundant but correct. Fewer well-grounded
findings beat a long list. Do not create or edit TODO list files unless explicitly instructed.

Carry forward any unresolved TODO items from earlier runs in this conversation.
