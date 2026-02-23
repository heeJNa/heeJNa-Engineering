#!/bin/bash
# =============================================================================
# Quality Gate Hook - General (범용)
# =============================================================================
# Stop Hook: 파일 확장자를 자동 감지하여 적절한 린트 도구 실행
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

# Kill switch
if [ "${CLAUDE_SKIP_QUALITY_GATE:-0}" = "1" ]; then
  exit 0
fi

# Git 저장소 확인
if ! git rev-parse --is-inside-work-tree &>/dev/null; then
  exit 0
fi

# ---------------------------------------------------------------------------
# Timeout helper (macOS 호환)
# ---------------------------------------------------------------------------
run_with_timeout() {
  local secs="$1"; shift
  if command -v timeout &>/dev/null; then
    timeout "${secs}s" "$@"
  elif command -v gtimeout &>/dev/null; then
    gtimeout "${secs}s" "$@"
  else
    "$@" &
    local pid=$!
    ( sleep "$secs"; kill "$pid" 2>/dev/null ) &
    local watchdog=$!
    wait "$pid" 2>/dev/null; local rc=$?
    kill "$watchdog" 2>/dev/null; wait "$watchdog" 2>/dev/null
    return $rc
  fi
}

# 변경된 파일 감지
CHANGED_FILES=$(git diff --name-only HEAD 2>/dev/null || git diff --name-only 2>/dev/null || echo "")
if [ -z "$CHANGED_FILES" ]; then
  exit 0
fi

ERRORS=""

# 존재하는 파일만 필터링하는 함수
filter_existing() {
  local result=""
  while IFS= read -r f; do
    [ -f "$f" ] && result="$result $f"
  done <<< "$1"
  echo "$result"
}

# -----------------------------------------------------------------------------
# JavaScript/TypeScript 검사
# -----------------------------------------------------------------------------
JS_FILES=$(echo "$CHANGED_FILES" | grep -E '\.(ts|tsx|js|jsx|vue|svelte)$' || true)
if [ -n "$JS_FILES" ]; then
  EXISTING=$(filter_existing "$JS_FILES")
  if [ -n "$EXISTING" ] && command -v npx &>/dev/null; then
    LINT_OUT=$(run_with_timeout 30 npx eslint --quiet $EXISTING 2>&1) || {
      [ $? -ne 124 ] && ERRORS="${ERRORS}\n[ESLint]\n${LINT_OUT}\n"
    }
  fi
fi

# -----------------------------------------------------------------------------
# Python 검사
# -----------------------------------------------------------------------------
PY_FILES=$(echo "$CHANGED_FILES" | grep -E '\.py$' || true)
if [ -n "$PY_FILES" ]; then
  EXISTING=$(filter_existing "$PY_FILES")
  if [ -n "$EXISTING" ]; then
    if command -v ruff &>/dev/null; then
      RUFF_OUT=$(run_with_timeout 30 ruff check $EXISTING 2>&1) || {
        [ $? -ne 124 ] && ERRORS="${ERRORS}\n[Ruff]\n${RUFF_OUT}\n"
      }
    fi
  fi
fi

# -----------------------------------------------------------------------------
# Go 검사
# -----------------------------------------------------------------------------
GO_FILES=$(echo "$CHANGED_FILES" | grep -E '\.go$' || true)
if [ -n "$GO_FILES" ]; then
  if command -v go &>/dev/null; then
    GO_OUT=$(run_with_timeout 30 go vet ./... 2>&1) || {
      [ $? -ne 124 ] && ERRORS="${ERRORS}\n[go vet]\n${GO_OUT}\n"
    }
  fi
fi

# -----------------------------------------------------------------------------
# Rust 검사
# -----------------------------------------------------------------------------
RS_FILES=$(echo "$CHANGED_FILES" | grep -E '\.rs$' || true)
if [ -n "$RS_FILES" ]; then
  if command -v cargo &>/dev/null; then
    RS_OUT=$(run_with_timeout 60 cargo clippy --quiet 2>&1) || {
      [ $? -ne 124 ] && ERRORS="${ERRORS}\n[Clippy]\n${RS_OUT}\n"
    }
  fi
fi

# -----------------------------------------------------------------------------
# 결과 처리
# -----------------------------------------------------------------------------
if [ -n "$ERRORS" ]; then
  echo -e "\n[Quality Gate] 에러 발견:\n${ERRORS}" >&2
  echo -e "건너뛰려면: CLAUDE_SKIP_QUALITY_GATE=1" >&2
  exit 2
fi

exit 0
