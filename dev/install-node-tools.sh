#!/usr/bin/env bash
# Bootstrap the Node toolchain the git pre-commit hook depends on.
# Part of klipper-nerdygriffin-macros
#
# Installs (user-local, no sudo): nvm -> Node LTS -> markdownlint-cli2.
# Idempotent — safe to re-run; exits early if markdownlint-cli2 is already
# available. This is a developer tool; it is intentionally NOT wired into the
# user-facing root install.sh.
set -euo pipefail

NVM_VERSION="v0.40.1"               # pinned nvm installer release
export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"

load_nvm() { [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"; }

# If nvm is already present, load it so the checks below see node/npm/tools.
load_nvm || true

if command -v markdownlint-cli2 >/dev/null 2>&1; then
    echo "markdownlint-cli2 already installed: $(command -v markdownlint-cli2)"
    echo "  $(markdownlint-cli2 --version 2>&1 | head -1)"
    exit 0
fi

if ! command -v curl >/dev/null 2>&1; then
    echo "ERROR: curl is required to install nvm but was not found in PATH." >&2
    exit 1
fi

# 1. nvm (skip if already installed)
if [ ! -s "$NVM_DIR/nvm.sh" ]; then
    echo "==> Installing nvm $NVM_VERSION (user-local, edits ~/.bashrc) ..."
    curl -fsSL "https://raw.githubusercontent.com/nvm-sh/nvm/$NVM_VERSION/install.sh" | bash
    load_nvm
else
    echo "==> nvm already present at $NVM_DIR"
fi

# 2. Node LTS (skip if a node is already usable)
if ! command -v node >/dev/null 2>&1; then
    echo "==> Installing Node (latest LTS) ..."
    nvm install --lts
    nvm use --lts >/dev/null
fi
echo "    node $(node --version)  /  npm $(npm --version)"

# 3. markdownlint-cli2 (global, into the active nvm Node)
echo "==> Installing markdownlint-cli2 ..."
npm install -g markdownlint-cli2

echo
echo "Installed: $(command -v markdownlint-cli2)"
echo "  $(markdownlint-cli2 --version 2>&1 | head -1)"
echo
echo "Done. Open a new shell (nvm was added to ~/.bashrc), or run:"
echo "  export NVM_DIR=\"\$HOME/.nvm\" && . \"\$NVM_DIR/nvm.sh\""
echo "The git pre-commit hook resolves the nvm-managed tool automatically."
