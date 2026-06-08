# Shared helpers for pre-commit step modules.
# Part of klipper-nerdygriffin-macros
#
# Sourced by the .git-hooks/pre-commit runner. Functions here should be
# side-effect-free and POSIX-portable (sh, not bash).
# Adapted from NerdyGriffin/git-hooks.

# Returns 0 if the given file is binary per `file --mime-encoding`.
is_binary() {
    file --mime-encoding -- "$1" 2>/dev/null | grep -q binary
}

# Returns 0 if the given file has unstaged changes (working tree differs from
# the index). Step modules should skip auto-fixing when this is true, to avoid
# silently re-staging unrelated hunks alongside the staged change.
has_unstaged_changes() {
    ! git diff --quiet -- "$1"
}
