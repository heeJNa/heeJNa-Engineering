#!/usr/bin/env bash
# =============================================================================
# quality-gate.sh - Claude Code Global Stop Hook (Fallback)
# =============================================================================
# Global fallback hook that delegates to project-level quality gates.
#
# Strategy:
#   1. If a project-level quality-gate.sh exists → defer to it (exit 0)
#   2. If no project hook → try the project's own lint script (npm run lint, etc.)
#   3. Never assumes specific tools (ESLint, Ruff, etc.)
#
# Project-level hooks (in project-templates/) handle tool-specific checks.
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
# Defer to project-level hook if it exists
# ---------------------------------------------------------------------------
# Project-level hooks have tool-specific checks (ESLint, Ruff, nuxi, etc.)
# If one exists, this global hook should not duplicate or conflict with it.
PROJECT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
if [[ -f "${PROJECT_ROOT}/.claude/hooks/quality-gate.sh" ]]; then
  exit 0
fi

# ---------------------------------------------------------------------------
# Constants & Helpers
# ---------------------------------------------------------------------------
readonly TOOL_TIMEOUT=30
readonly EXIT_CODE_ERRORS=2

command_exists() {
  command -v "$1" &>/dev/null
}

run_with_timeout() {
  local secs="$1"
  shift

  if command_exists timeout; then
    timeout "${secs}s" "$@"
  elif command_exists gtimeout; then
    gtimeout "${secs}s" "$@"
  else
    "$@" &
    local pid=$!
    ( sleep "$secs"; kill "$pid" 2>/dev/null ) &
    local watchdog=$!
    wait "$pid" 2>/dev/null
    local rc=$?
    kill "$watchdog" 2>/dev/null
    wait "$watchdog" 2>/dev/null
    return $rc
  fi
}

# ---------------------------------------------------------------------------
# Main - Generic lint via project's own scripts
# ---------------------------------------------------------------------------

# Exit silently if not in a git repo
if ! git rev-parse --is-inside-work-tree &>/dev/null; then
  exit 0
fi

# Check if there are any changes
if git rev-parse HEAD &>/dev/null; then
  changed=$(git diff --name-only HEAD 2>/dev/null)
else
  empty_tree=$(git hash-object -t tree /dev/null)
  changed=$(git diff --name-only "$empty_tree" 2>/dev/null)
fi
untracked=$(git ls-files --others --exclude-standard 2>/dev/null)

if [[ -z "$changed" && -z "$untracked" ]]; then
  exit 0
fi

# ---------------------------------------------------------------------------
# Try the project's own lint script (tool-agnostic)
# ---------------------------------------------------------------------------
has_errors=0
error_output=""

# Node.js projects: use "npm run lint" if defined in package.json
if [[ -f "${PROJECT_ROOT}/package.json" ]] && command_exists jq; then
  if jq -e '.scripts.lint' "${PROJECT_ROOT}/package.json" &>/dev/null; then
    lint_result=""
    lint_result=$(cd "$PROJECT_ROOT" && run_with_timeout "$TOOL_TIMEOUT" \
      npm run lint --silent 2>&1) || {
      rc=$?
      if [[ $rc -ne 124 && $rc -ne 137 ]]; then
        has_errors=1
        error_output+="
=== Lint Errors (npm run lint) ===
${lint_result}
"
      fi
    }
  fi
fi

# Python projects: use "make lint" or pyproject.toml scripts if available
if [[ -f "${PROJECT_ROOT}/Makefile" ]] && grep -q '^lint:' "${PROJECT_ROOT}/Makefile"; then
  lint_result=""
  lint_result=$(cd "$PROJECT_ROOT" && run_with_timeout "$TOOL_TIMEOUT" \
    make lint 2>&1) || {
    rc=$?
    if [[ $rc -ne 124 && $rc -ne 137 ]]; then
      has_errors=1
      error_output+="
=== Lint Errors (make lint) ===
${lint_result}
"
    fi
  }
fi

# ---------------------------------------------------------------------------
# No lint script found
# ---------------------------------------------------------------------------
if [[ $has_errors -eq 0 && -z "$error_output" ]]; then
  # Check if we actually ran any lint command
  ran_lint=false
  [[ -f "${PROJECT_ROOT}/package.json" ]] && command_exists jq && \
    jq -e '.scripts.lint' "${PROJECT_ROOT}/package.json" &>/dev/null && ran_lint=true
  [[ -f "${PROJECT_ROOT}/Makefile" ]] && grep -q '^lint:' "${PROJECT_ROOT}/Makefile" && ran_lint=true

  if [[ "$ran_lint" == "false" ]]; then
    echo "[quality-gate] No project-level quality gate found." >&2
    echo "  Recommended: ./install.sh $(pwd) --template <nuxt4|vue3|fastapi|general>" >&2
    exit 0
  fi
fi

# ---------------------------------------------------------------------------
# Report results
# ---------------------------------------------------------------------------
if [[ $has_errors -ne 0 ]]; then
  echo "$error_output" >&2
  echo "" >&2
  echo "[quality-gate] Lint errors detected. Please fix them." >&2
  exit $EXIT_CODE_ERRORS
fi

exit 0
