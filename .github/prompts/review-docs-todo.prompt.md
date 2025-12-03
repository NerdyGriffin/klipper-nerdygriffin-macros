---
description: 'Audit documentation across repos and produce a prioritized TODO list (no edits).'
agent: agent
model: Auto (copilot)
---

Perform a review of the documentation and provide a TODO list of issues and potential improvements.

- Ask for clarifications if any part of the documentation is ambiguous.
- For complex items that may require multiple steps, break them down into sub-tasks or suggest adding them to TODO.md files in the relevant repos.

Return the TODO list in a Markdown format, grouped by priority and issue type.

If we iterate on this prompt, repeat any TODO items from prior runs until resolved.
