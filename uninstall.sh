#!/bin/bash
# =============================================================================
# heejuna-engineering 제거 스크립트
# =============================================================================
# 사용법: ./uninstall.sh
#
# 수행 작업:
# 1. quality-gate.sh Hook 제거
# 2. CLAUDE.md에서 heejuna-engineering 섹션 제거
# 3. settings.json에서 quality-gate Hook 등록 제거
# =============================================================================

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

CLAUDE_DIR="$HOME/.claude"

echo -e "${BLUE}=== heejuna-engineering 제거 ===${NC}"
echo ""

# -----------------------------------------------------------------------------
# 1. Quality Gate Hook 제거
# -----------------------------------------------------------------------------
echo -e "${YELLOW}[1/3] Quality Gate Hook 제거...${NC}"

HOOK_FILE="$CLAUDE_DIR/hooks/quality-gate.sh"
if [ -f "$HOOK_FILE" ]; then
  rm "$HOOK_FILE"
  echo -e "  ${GREEN}quality-gate.sh 제거 완료${NC}"
else
  echo -e "  ${YELLOW}이미 제거되어 있습니다.${NC}"
fi

# -----------------------------------------------------------------------------
# 2. CLAUDE.md에서 heejuna-engineering 섹션 제거
# -----------------------------------------------------------------------------
echo -e "${YELLOW}[2/3] CLAUDE.md에서 heejuna-engineering 섹션 제거...${NC}"

CLAUDE_MD="$CLAUDE_DIR/CLAUDE.md"
if [ -f "$CLAUDE_MD" ]; then
  # 마커 기반으로 섹션 찾기
  if grep -q "## heejuna-engineering" "$CLAUDE_MD"; then
    # --- 구분선부터 heejuna-engineering 섹션 끝까지 제거
    # sed로 마커 라인부터 파일 끝 또는 다음 --- 까지 제거
    TEMP=$(mktemp)
    # heejuna-engineering 섹션 시작 직전의 --- 부터 끝까지 제거
    awk '
      /^---$/ { found_sep=1; sep_line=NR; buffer=$0"\n"; next }
      found_sep && /^## heejuna-engineering/ { removing=1; next }
      found_sep && !removing { printf "%s", buffer; buffer=""; found_sep=0; print; next }
      removing { next }
      !removing { print }
    ' "$CLAUDE_MD" > "$TEMP"
    mv "$TEMP" "$CLAUDE_MD"
    echo -e "  ${GREEN}heejuna-engineering 섹션 제거 완료${NC}"
  else
    echo -e "  ${YELLOW}heejuna-engineering 섹션이 없습니다.${NC}"
  fi
else
  echo -e "  ${YELLOW}CLAUDE.md 파일이 없습니다.${NC}"
fi

# -----------------------------------------------------------------------------
# 3. settings.json에서 Hook 제거
# -----------------------------------------------------------------------------
echo -e "${YELLOW}[3/3] settings.json에서 Quality Gate Hook 등록 제거...${NC}"

SETTINGS="$CLAUDE_DIR/settings.json"
if [ -f "$SETTINGS" ] && command -v jq &>/dev/null; then
  if jq -e '.hooks.Stop' "$SETTINGS" &>/dev/null; then
    TEMP=$(mktemp)
    # quality-gate를 포함하는 Stop hook 항목 제거
    jq '.hooks.Stop = [.hooks.Stop[]? | select(.hooks[]?.command | contains("quality-gate") | not)]' "$SETTINGS" > "$TEMP"
    # Stop 배열이 비어있으면 키 자체 제거
    if jq -e '.hooks.Stop | length == 0' "$TEMP" &>/dev/null; then
      jq 'del(.hooks.Stop)' "$TEMP" > "${TEMP}.2"
      mv "${TEMP}.2" "$TEMP"
    fi
    # hooks 객체가 비어있으면 키 자체 제거
    if jq -e '.hooks | length == 0' "$TEMP" &>/dev/null; then
      jq 'del(.hooks)' "$TEMP" > "${TEMP}.2"
      mv "${TEMP}.2" "$TEMP"
    fi
    mv "$TEMP" "$SETTINGS"
    echo -e "  ${GREEN}settings.json에서 Hook 제거 완료${NC}"
  else
    echo -e "  ${YELLOW}Stop Hook이 등록되어 있지 않습니다.${NC}"
  fi
else
  if [ ! -f "$SETTINGS" ]; then
    echo -e "  ${YELLOW}settings.json 파일이 없습니다.${NC}"
  else
    echo -e "  ${YELLOW}jq가 없습니다. 수동으로 quality-gate 관련 항목을 제거하세요.${NC}"
  fi
fi

# -----------------------------------------------------------------------------
# 완료
# -----------------------------------------------------------------------------
echo ""
echo -e "${GREEN}=== 제거 완료 ===${NC}"
echo ""
echo "참고:"
echo "  - 프로젝트 수준 설정(.claude/)은 수동으로 제거하세요."
echo "  - 플러그인은 Claude Code CLI에서 /plugins → 비활성화할 플러그인 선택"
