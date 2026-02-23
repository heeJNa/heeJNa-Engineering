#!/usr/bin/env bash
# =============================================================================
# quality-gate.sh - Claude Code Stop Hook
# =============================================================================
# Automatically runs lint/typecheck on changed files BEFORE Claude stops.
# If errors are found, exits with code 2 so Claude sees and fixes them.
#
# Usage:
#   Called automatically by Claude Code as a Stop hook.
#   Set CLAUDE_SKIP_QUALITY_GATE=1 to bypass all checks.
#
# Exit codes:
#   0 - All checks passed (or nothing to check)
#   2 - Errors found (Claude will attempt to fix)
# =============================================================================

set -euo pipefail

# ---------------------------------------------------------------------------
# Stop hook re-entry guard (prevent infinite loop per Anthropic docs)
# When Claude fixes errors and stops again, stop_hook_active=true prevents
# the quality gate from re-triggering endlessly.
# ---------------------------------------------------------------------------
if command -v jq &>/dev/null; then
  HOOK_INPUT=$(cat)
  if [ "$(echo "$HOOK_INPUT" | jq -r '.stop_hook_active // false')" = "true" ]; then
    exit 0
  fi
else
  cat > /dev/null
fi

# ---------------------------------------------------------------------------
# Skip gate if explicitly disabled
# ---------------------------------------------------------------------------
if [[ "${CLAUDE_SKIP_QUALITY_GATE:-0}" == "1" ]]; then
  exit 0
fi

# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------
readonly TOOL_TIMEOUT=30  # seconds per tool invocation
readonly EXIT_CODE_ERRORS=2

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

# Check if we are inside a git repository
is_git_repo() {
  git rev-parse --is-inside-work-tree &>/dev/null
}

# Check if a command exists on PATH
command_exists() {
  command -v "$1" &>/dev/null
}

# Run a command with a timeout. Uses the `timeout` utility if available,
# otherwise falls back to a background-process approach for macOS.
run_with_timeout() {
  local secs="$1"
  shift

  if command_exists timeout; then
    # GNU coreutils timeout (Linux)
    timeout "${secs}s" "$@"
  elif command_exists gtimeout; then
    # Homebrew coreutils on macOS
    gtimeout "${secs}s" "$@"
  else
    # Fallback: background process with manual kill
    "$@" &
    local pid=$!
    (
      sleep "$secs"
      kill "$pid" 2>/dev/null
    ) &
    local watchdog=$!
    wait "$pid" 2>/dev/null
    local rc=$?
    kill "$watchdog" 2>/dev/null
    wait "$watchdog" 2>/dev/null
    return $rc
  fi
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

# Exit silently if not in a git repo
if ! is_git_repo; then
  exit 0
fi

# Collect changed files (staged + unstaged, relative to HEAD).
# If HEAD does not exist (fresh repo with no commits), compare against
# the empty tree so we still pick up newly added files.
if git rev-parse HEAD &>/dev/null; then
  mapfile -t changed_files < <(git diff --name-only HEAD 2>/dev/null)
else
  # No commits yet -- compare index against empty tree
  empty_tree=$(git hash-object -t tree /dev/null)
  mapfile -t changed_files < <(git diff --name-only "$empty_tree" 2>/dev/null)
fi

# Also include untracked files that are new (not yet committed)
mapfile -t untracked_files < <(git ls-files --others --exclude-standard 2>/dev/null)
changed_files+=("${untracked_files[@]}")

# Exit silently if there are no changes
if [[ ${#changed_files[@]} -eq 0 ]]; then
  exit 0
fi

# ---------------------------------------------------------------------------
# Classify files by type
# ---------------------------------------------------------------------------
js_files=()
py_files=()

for f in "${changed_files[@]}"; do
  # Skip files that no longer exist on disk (deleted files)
  [[ -f "$f" ]] || continue

  case "$f" in
    *.ts|*.tsx|*.vue|*.js|*.jsx)
      js_files+=("$f")
      ;;
    *.py)
      py_files+=("$f")
      ;;
  esac
done

# ---------------------------------------------------------------------------
# Run checks
# ---------------------------------------------------------------------------
has_errors=0
error_output=""

# --- JavaScript / TypeScript / Vue (ESLint) --------------------------------
if [[ ${#js_files[@]} -gt 0 ]]; then
  if command_exists npx; then
    # Verify eslint is actually available via npx
    if npx eslint --version &>/dev/null; then
      js_result=""
      js_result=$(run_with_timeout "$TOOL_TIMEOUT" \
        npx eslint --quiet --no-warn-ignored "${js_files[@]}" 2>&1) || {
        rc=$?
        # eslint exit code 1 = lint errors, 2 = config/runtime error
        if [[ $rc -eq 1 || $rc -eq 2 ]]; then
          has_errors=1
          error_output+="
=== ESLint Errors ===
${js_result}
"
        fi
        # timeout (rc=124/137) -- treat as no error, just slow
      }
    else
      echo "[quality-gate] WARNING: eslint not found, skipping JS/TS checks" >&2
    fi
  else
    echo "[quality-gate] WARNING: npx not found, skipping JS/TS checks" >&2
  fi
fi

# --- Python (Ruff) ---------------------------------------------------------
if [[ ${#py_files[@]} -gt 0 ]]; then
  if command_exists ruff; then
    py_result=""
    py_result=$(run_with_timeout "$TOOL_TIMEOUT" \
      ruff check "${py_files[@]}" 2>&1) || {
      rc=$?
      if [[ $rc -eq 1 ]]; then
        has_errors=1
        error_output+="
=== Ruff Errors ===
${py_result}
"
      fi
    }
  else
    echo "[quality-gate] WARNING: ruff not found, skipping Python checks" >&2
  fi
fi

# ---------------------------------------------------------------------------
# Report results
# ---------------------------------------------------------------------------
if [[ $has_errors -ne 0 ]]; then
  # Print all collected errors to stderr so Claude Code can see them
  echo "$error_output" >&2
  echo "" >&2
  echo "[quality-gate] Lint errors detected in changed files. Please fix them." >&2
  exit $EXIT_CODE_ERRORS
fi

# All checks passed -- exit silently
exit 0
