# Git Hooks (git_hooks)

A pre-commit hook that lints and auto-fixes staged Markdown with
[markdownlint-cli2](https://github.com/DavidAnson/markdownlint-cli2), using the
modular step layout adapted from [NerdyGriffin/git-hooks](https://github.com/NerdyGriffin/git-hooks).

## Setup

The hook is a hard dependency on `markdownlint-cli2`, which requires Node.js.
On a fresh host, run both bootstrap scripts:

```bash
# 1. Install the Node toolchain (nvm -> Node LTS -> markdownlint-cli2), no sudo
dev/install-node-tools.sh

# 2. Wire .git/hooks/pre-commit to the tracked runner
dev/install-git-hooks.sh
```

Both scripts are idempotent and safe to re-run after cloning on a new machine
or pulling updates. If you already manage Node yourself, you can skip step 1 and
just ensure `markdownlint-cli2` is on PATH (`npm install -g markdownlint-cli2`).

> **Note**:
>
> Commits happen on the printer host (the source-of-truth checkout), so
> `markdownlint-cli2` must be installed there too. Without it, the hook aborts
> the commit with an install hint. Bypass in a pinch with `git commit --no-verify`.

## What it does

On each commit, for every staged `.md` / `.markdown` file:

1. Runs `markdownlint-cli2 --fix` to auto-fix fixable violations, then re-stages
   the file if it changed.
2. Re-lints and blocks the commit if any non-auto-fixable violations remain.

Files with unstaged changes are linted check-only (no auto-fix) so that
partial-staging workflows are not silently broken.

## Layout

| Path | Role |
| --- | --- |
| `.git-hooks/common.sh` | Shared helpers (`is_binary`, `has_unstaged_changes`) |
| `.git-hooks/step-lint-markdown.sh` | The markdownlint step module (`_init` + per-file function) |
| `.git-hooks/pre-commit` | POSIX-sh runner: sources helpers, runs init, loops the files |
| `dev/install-git-hooks.sh` | Installs the `.git/hooks/pre-commit` stub that execs the runner |
| `.markdownlint-cli2.jsonc` | Lint rules + `gitignore: true` (repo root, auto-discovered) |

The tracked runner in `.git-hooks/pre-commit` does the work; `.git/hooks/pre-commit`
is a generated stub that delegates to it (so the logic stays version-controlled).

## Configuration

Markdown rules live in [`.markdownlint-cli2.jsonc`](../../.markdownlint-cli2.jsonc)
at the repo root (with `gitignore: true`, so gitignored scratch is never linted).
See the
[markdownlint rule reference](https://github.com/DavidAnson/markdownlint/blob/main/doc/Rules.md)
for the full list of rules and options.

## Adding a step

1. Add a `.git-hooks/step-<name>.sh` defining `step_<name>_init` (optional) and
   a per-file `step_<name>` function.
2. Source it and call it from `.git-hooks/pre-commit`.
