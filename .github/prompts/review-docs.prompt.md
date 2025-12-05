---
agent: agent
model: Auto (copilot)
description: 'Perform a review of all documentation'
---

Perform a review of the documentation and provide a TODO list of issues and potential improvements.

- Scope: All repositories in this workspace
- Avoid referring to files that are not tracked in version control, not included in the documentation index, or outside the current workspace.
  - If documentation references such files, flag the reference and suggest either adding the file to tracking or removing the reference.
- Ask for clarifications if any part of the documentation is ambiguous.
- Do not suggest changes to implement features or functionality; focus solely on documentation quality and clarity.

Return the TODO list in a Markdown format in the chat, grouped by priority and issue type. Use numbered lists for easy reference. Do not create or edit TODO list files unless explicitly instructed.

If we iterate on this prompt, repeat any TODO items from prior runs until resolved.
