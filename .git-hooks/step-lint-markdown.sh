# Step: lint and auto-fix Markdown with markdownlint-cli2.
# Part of klipper-nerdygriffin-macros
#
# Auto-fixes fixable rule violations, re-stages the result, then blocks the
# commit on any remaining (non-auto-fixable) violations. Files with unstaged
# changes are linted check-only (no auto-fix) so partial-staging isn't broken.
# Config: .markdownlint-cli2.jsonc at the repo root (auto-discovered by cli2).

# Verify markdownlint-cli2 is on PATH. Called once before the file loop;
# returns non-zero to abort the commit if the tool is missing.
step_lint_markdown_init() {
    if ! command -v markdownlint-cli2 >/dev/null 2>&1; then
        echo "ERROR: markdownlint-cli2 is required for Markdown linting but was not found in PATH." >&2
        echo "       Install it with: npm install -g markdownlint-cli2" >&2
        echo "       Or bypass with:  git commit --no-verify" >&2
        return 1
    fi
}

# Lint a single staged Markdown file. Auto-fixes and re-stages when the file
# has no unstaged changes; otherwise lints check-only. Returns non-zero when
# unfixable violations remain.
step_lint_markdown() {
    file=$1
    case "$file" in
        *.md | *.markdown) ;;
        *) return 0 ;;
    esac

    if has_unstaged_changes "$file"; then
        echo "Skipping Markdown auto-fix for $file because it has unstaged changes."
    else
        # Auto-fix fixable violations, then re-stage if the file changed.
        markdownlint-cli2 --fix "$file" >/dev/null 2>&1 || true
        if ! git diff --quiet -- "$file"; then
            git add -- "$file"
            if [ "${md_announced:-0}" -eq 0 ]; then
                echo "Auto-fixed (markdownlint-cli2 --fix):"
                md_announced=1
            fi
            echo "  $file"
        fi
    fi

    # Residual check: any remaining violation blocks the commit.
    if ! lint_out=$(markdownlint-cli2 "$file" 2>&1); then
        if [ "${md_blocked:-0}" -eq 0 ]; then
            echo "" >&2
            echo "ERROR: Markdown lint violations (not auto-fixable) detected:" >&2
            echo "       Fix them, or bypass with 'git commit --no-verify'." >&2
            echo "" >&2
            md_blocked=1
        fi
        echo "$lint_out" | sed 's/^/    /' >&2
        echo "" >&2
        return 1
    fi
}
