#!/bin/bash
# =============================================================================
# Quality Gate Hook - FastAPI
# =============================================================================
# Stop Hook: Claude Code가 작업을 마치기 전 자동으로 Ruff + Pyright 실행
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
# Python 파일 필터링
# -----------------------------------------------------------------------------
PY_FILES=$(echo "$CHANGED_FILES" | grep -E '\.py$' || true)

if [ -z "$PY_FILES" ]; then
  exit 0
fi

# 존재하는 파일만 필터링
EXISTING_PY_FILES=""
while IFS= read -r f; do
  [ -f "$f" ] && EXISTING_PY_FILES="$EXISTING_PY_FILES $f"
done <<< "$PY_FILES"

if [ -z "$EXISTING_PY_FILES" ]; then
  exit 0
fi

# -----------------------------------------------------------------------------
# Ruff 린트 검사
# -----------------------------------------------------------------------------
if command -v ruff &>/dev/null; then
  RUFF_OUTPUT=$(run_with_timeout 30 ruff check $EXISTING_PY_FILES 2>&1) || {
    if [ $? -ne 124 ]; then
      ERRORS="${ERRORS}\n[Ruff] 린트 에러 발견:\n${RUFF_OUTPUT}\n"
    fi
  }
else
  echo "[Quality Gate] ruff를 찾을 수 없습니다. 린트 검사를 건너뜁니다." >&2
fi

# -----------------------------------------------------------------------------
# Pyright 타입 검사
# -----------------------------------------------------------------------------
if command -v npx &>/dev/null; then
  PYRIGHT_OUTPUT=$(run_with_timeout 60 npx pyright $EXISTING_PY_FILES 2>&1) || {
    if [ $? -ne 124 ]; then
      ERRORS="${ERRORS}\n[Pyright] 타입 에러 발견:\n${PYRIGHT_OUTPUT}\n"
    fi
  }
elif command -v pyright &>/dev/null; then
  PYRIGHT_OUTPUT=$(run_with_timeout 60 pyright $EXISTING_PY_FILES 2>&1) || {
    if [ $? -ne 124 ]; then
      ERRORS="${ERRORS}\n[Pyright] 타입 에러 발견:\n${PYRIGHT_OUTPUT}\n"
    fi
  }
else
  echo "[Quality Gate] pyright를 찾을 수 없습니다. 타입 검사를 건너뜁니다." >&2
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
