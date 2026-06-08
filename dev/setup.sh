#!/usr/bin/env bash
# One-shot developer setup for klipper-nerdygriffin-macros.
# Part of klipper-nerdygriffin-macros
#
# Installs everything the git pre-commit hook needs and wires the hook, in a
# single run:
#   1. dev/install-node-tools.sh  — nvm + Node LTS + markdownlint-cli2 (no sudo)
#   2. dev/install-git-hooks.sh   — .git/hooks/pre-commit -> .git-hooks/ runner
#
# Idempotent — safe to re-run after cloning on a new host or pulling updates.
# Developer tool; intentionally NOT part of the user-facing root install.sh.
set -eo pipefail

here=$(cd "$(dirname "$0")" && pwd)

echo "==> [1/2] Node toolchain"
"$here/install-node-tools.sh"

echo
echo "==> [2/2] Git pre-commit hook"
"$here/install-git-hooks.sh"

echo
echo "Setup complete — the markdownlint pre-commit hook is installed and ready."
echo "Open a new shell (or 'source ~/.bashrc') to get nvm/npm on your interactive"
echo "PATH; the hook resolves the nvm-managed tool on its own regardless."
