---
agent: agent
---

Perform a review of all the staged and unstaged changes in all Git repositories within this workspace.

- Provide a summary of the changes
- Identify any potential issues or improvements
- Suggest commit messages for the changes
  - Ensure commit messages are clear, concise, and follow best practices
  - Only describe changes present in the current diff; do not mention adding or removing features unless those features are actually being added or removed in this set of changes.
  - For example:
    - Acceptable: "Refactor filament management macro for clarity", "Fix bug in LOAD_FILAMENT macro", "Add chamber temperature sensor support"
    - Unacceptable: "Add new feature" (if the feature is not present in the diff), "Remove deprecated macro" (if no macro is removed in this diff)
- You may suggest multiple commit messages if the changes can be logically grouped.
  - This will require using `git add` to stage specific files or hunks before committing.
