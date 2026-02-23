#!/bin/bash
# =============================================================================
# Quality Gate Hook - Vue 3
# =============================================================================
# Stop Hook: Claude Code가 작업을 마치기 전 자동으로 ESLint + vue-tsc 실행
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

# -----------------------------------------------------------------------------
# ESLint 검사 (.ts, .tsx, .vue, .js, .jsx)
# -----------------------------------------------------------------------------
JS_FILES=$(echo "$CHANGED_FILES" | grep -E '\.(ts|tsx|vue|js|jsx)$' || true)

if [ -n "$JS_FILES" ]; then
  if command -v npx &>/dev/null; then
    EXISTING_JS_FILES=""
    while IFS= read -r f; do
      [ -f "$f" ] && EXISTING_JS_FILES="$EXISTING_JS_FILES $f"
    done <<< "$JS_FILES"

    if [ -n "$EXISTING_JS_FILES" ]; then
      LINT_OUTPUT=$(run_with_timeout 30 npx eslint --quiet $EXISTING_JS_FILES 2>&1) || {
        if [ $? -ne 124 ]; then
          ERRORS="${ERRORS}\n[ESLint] 린트 에러 발견:\n${LINT_OUTPUT}\n"
        fi
      }
    fi
  else
    echo "[Quality Gate] npx를 찾을 수 없습니다. ESLint 검사를 건너뜁니다." >&2
  fi
fi

# -----------------------------------------------------------------------------
# vue-tsc TypeCheck (.ts, .vue 변경 시)
# -----------------------------------------------------------------------------
TS_FILES=$(echo "$CHANGED_FILES" | grep -E '\.(ts|vue)$' || true)

if [ -n "$TS_FILES" ]; then
  if command -v npx &>/dev/null; then
    if npx vue-tsc --version &>/dev/null 2>&1; then
      TC_OUTPUT=$(run_with_timeout 60 npx vue-tsc --noEmit 2>&1) || {
        if [ $? -ne 124 ]; then
          ERRORS="${ERRORS}\n[vue-tsc] 타입 에러 발견:\n${TC_OUTPUT}\n"
        fi
      }
    fi
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
