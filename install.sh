#!/bin/bash
# =============================================================================
# heejuna-engineering 설치 스크립트
# =============================================================================
# 사용법:
#   ./install.sh                              # 글로벌 설치만
#   ./install.sh /path/to/project             # 글로벌 + 프로젝트 (general)
#   ./install.sh /path/to/project --template nuxt4
#   ./install.sh /path/to/project --template vue3
#   ./install.sh /path/to/project --template fastapi
#   ./install.sh /path/to/project --template general
#
# 수행 작업:
# [글로벌] 1. 기존 ~/.claude 설정 백업
# [글로벌] 2. Quality Gate Hook → ~/.claude/hooks/
# [글로벌] 3. CLAUDE.md 보강 내용 추가
# [글로벌] 4. settings.json에 Hook 등록
# [프로젝트] 5. 프로젝트에 .claude/hooks/, .claude/rules/ 복사
# =============================================================================

set -euo pipefail

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 스크립트 위치 기준 경로
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
BACKUP_DIR="$CLAUDE_DIR.backup.$(date +%Y%m%d_%H%M%S)"

# -----------------------------------------------------------------------------
# 인자 파싱
# -----------------------------------------------------------------------------
PROJECT_DIR=""
TEMPLATE="general"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --template)
      TEMPLATE="$2"
      shift 2
      ;;
    --help|-h)
      echo "사용법: ./install.sh [PROJECT_DIR] [--template TEMPLATE]"
      echo ""
      echo "옵션:"
      echo "  PROJECT_DIR        프로젝트 경로 (생략하면 글로벌 설치만)"
      echo "  --template NAME    프로젝트 템플릿 (nuxt4|vue3|fastapi|general)"
      echo "  --help             이 도움말"
      exit 0
      ;;
    *)
      PROJECT_DIR="$1"
      shift
      ;;
  esac
done

# 템플릿 유효성 검사
TEMPLATE_DIR="$SCRIPT_DIR/project-templates/$TEMPLATE"
if [ -n "$PROJECT_DIR" ] && [ ! -d "$TEMPLATE_DIR" ]; then
  echo -e "${RED}오류: '$TEMPLATE' 템플릿을 찾을 수 없습니다.${NC}"
  echo "사용 가능한 템플릿: nuxt4, vue3, fastapi, general"
  exit 1
fi

# 프로젝트 디렉토리 유효성 검사
if [ -n "$PROJECT_DIR" ] && [ ! -d "$PROJECT_DIR" ]; then
  echo -e "${RED}오류: '$PROJECT_DIR' 디렉토리가 존재하지 않습니다.${NC}"
  exit 1
fi

TOTAL_STEPS=4
[ -n "$PROJECT_DIR" ] && TOTAL_STEPS=5

echo -e "${BLUE}=== heejuna-engineering 설치 ===${NC}"
[ -n "$PROJECT_DIR" ] && echo -e "  프로젝트: ${PROJECT_DIR}"
[ -n "$PROJECT_DIR" ] && echo -e "  템플릿: ${TEMPLATE}"
echo ""

# =============================================================================
# 글로벌 설치 (항상 수행)
# =============================================================================

# -----------------------------------------------------------------------------
# 1. 백업
# -----------------------------------------------------------------------------
echo -e "${YELLOW}[1/${TOTAL_STEPS}] 기존 설정 백업...${NC}"

if [ -d "$CLAUDE_DIR" ]; then
  cp -r "$CLAUDE_DIR" "$BACKUP_DIR"
  echo -e "  ${GREEN}백업 완료: ${BACKUP_DIR}${NC}"
else
  mkdir -p "$CLAUDE_DIR"
  echo -e "  ${GREEN}~/.claude 디렉토리 생성${NC}"
fi

mkdir -p "$CLAUDE_DIR/hooks"

# -----------------------------------------------------------------------------
# 2. Quality Gate Hook 복사
# -----------------------------------------------------------------------------
echo -e "${YELLOW}[2/${TOTAL_STEPS}] Quality Gate Hook 설치...${NC}"

HOOK_SRC="$SCRIPT_DIR/custom/hooks/quality-gate.sh"
HOOK_DST="$CLAUDE_DIR/hooks/quality-gate.sh"

if [ -f "$HOOK_SRC" ]; then
  cp "$HOOK_SRC" "$HOOK_DST"
  chmod +x "$HOOK_DST"
  echo -e "  ${GREEN}quality-gate.sh 설치 완료${NC}"
else
  echo -e "  ${RED}오류: $HOOK_SRC 파일을 찾을 수 없습니다${NC}"
  exit 1
fi

# -----------------------------------------------------------------------------
# 3. CLAUDE.md 보강
# -----------------------------------------------------------------------------
echo -e "${YELLOW}[3/${TOTAL_STEPS}] CLAUDE.md 보강 내용 추가...${NC}"

ADDON_SRC="$SCRIPT_DIR/custom/claude-md-addon.md"
CLAUDE_MD="$CLAUDE_DIR/CLAUDE.md"

if [ -f "$ADDON_SRC" ]; then
  MARKER="## heejuna-engineering"
  if [ -f "$CLAUDE_MD" ] && grep -q "$MARKER" "$CLAUDE_MD"; then
    echo -e "  ${YELLOW}이미 추가되어 있습니다. 건너뜁니다.${NC}"
  else
    [ -f "$CLAUDE_MD" ] || touch "$CLAUDE_MD"
    echo "" >> "$CLAUDE_MD"
    echo "---" >> "$CLAUDE_MD"
    echo "" >> "$CLAUDE_MD"
    cat "$ADDON_SRC" >> "$CLAUDE_MD"
    echo -e "  ${GREEN}CLAUDE.md 보강 완료${NC}"
  fi
else
  echo -e "  ${RED}오류: $ADDON_SRC 파일을 찾을 수 없습니다${NC}"
  exit 1
fi

# -----------------------------------------------------------------------------
# 4. settings.json에 Hook 등록
# -----------------------------------------------------------------------------
echo -e "${YELLOW}[4/${TOTAL_STEPS}] settings.json에 Hook 등록...${NC}"

SETTINGS="$CLAUDE_DIR/settings.json"

if [ -f "$SETTINGS" ]; then
  if command -v jq &>/dev/null; then
    if jq -e '.hooks.Stop[]?.hooks[]?.command | select(contains("quality-gate"))' "$SETTINGS" &>/dev/null; then
      echo -e "  ${YELLOW}Quality Gate Hook이 이미 등록되어 있습니다.${NC}"
    else
      TEMP=$(mktemp)
      jq '.hooks.Stop = (.hooks.Stop // []) + [{
        "hooks": [{
          "type": "command",
          "command": "~/.claude/hooks/quality-gate.sh"
        }]
      }]' "$SETTINGS" > "$TEMP"
      mv "$TEMP" "$SETTINGS"
      echo -e "  ${GREEN}settings.json에 Hook 등록 완료${NC}"
    fi
  else
    echo -e "  ${YELLOW}jq가 설치되어 있지 않습니다.${NC}"
    echo -e "  ${YELLOW}수동으로 settings.json에 다음을 추가하세요:${NC}"
    echo ""
    echo '  "Stop": [{"hooks":[{"type":"command","command":"~/.claude/hooks/quality-gate.sh"}]}]'
    echo ""
    echo -e "  ${YELLOW}jq 설치: brew install jq${NC}"
  fi
else
  echo -e "  ${YELLOW}settings.json이 없습니다. 새로 생성합니다.${NC}"
  cat > "$SETTINGS" << 'SETTINGS_EOF'
{
  "hooks": {
    "Stop": [{
      "hooks": [{
        "type": "command",
        "command": "~/.claude/hooks/quality-gate.sh"
      }]
    }]
  }
}
SETTINGS_EOF
  echo -e "  ${GREEN}settings.json 생성 완료${NC}"
fi

# =============================================================================
# 프로젝트 템플릿 적용 (PROJECT_DIR이 지정된 경우만)
# =============================================================================

if [ -n "$PROJECT_DIR" ]; then
  echo -e "${YELLOW}[5/${TOTAL_STEPS}] 프로젝트 템플릿 적용 (${TEMPLATE})...${NC}"

  PROJECT_CLAUDE="$PROJECT_DIR/.claude"
  mkdir -p "$PROJECT_CLAUDE/hooks" "$PROJECT_CLAUDE/rules"

  # hooks 복사
  if [ -d "$TEMPLATE_DIR/.claude/hooks" ]; then
    cp "$TEMPLATE_DIR/.claude/hooks/"*.sh "$PROJECT_CLAUDE/hooks/" 2>/dev/null || true
    chmod +x "$PROJECT_CLAUDE/hooks/"*.sh 2>/dev/null || true
    echo -e "  ${GREEN}hooks 복사 완료${NC}"
  fi

  # rules 복사
  if [ -d "$TEMPLATE_DIR/.claude/rules" ]; then
    cp "$TEMPLATE_DIR/.claude/rules/"*.md "$PROJECT_CLAUDE/rules/" 2>/dev/null || true
    echo -e "  ${GREEN}rules 복사 완료${NC}"
  fi

  # 프로젝트 settings.json 생성 (없는 경우만)
  PROJECT_SETTINGS="$PROJECT_CLAUDE/settings.json"
  if [ ! -f "$PROJECT_SETTINGS" ]; then
    cat > "$PROJECT_SETTINGS" << 'PROJ_SETTINGS_EOF'
{
  "hooks": {
    "Stop": [{
      "hooks": [{
        "type": "command",
        "command": ".claude/hooks/quality-gate.sh"
      }]
    }]
  }
}
PROJ_SETTINGS_EOF
    echo -e "  ${GREEN}프로젝트 settings.json 생성 완료${NC}"
  else
    echo -e "  ${YELLOW}프로젝트 settings.json이 이미 존재합니다. 건너뜁니다.${NC}"
  fi
fi

# -----------------------------------------------------------------------------
# 완료
# -----------------------------------------------------------------------------
echo ""
echo -e "${GREEN}=== 설치 완료 ===${NC}"
echo ""
echo "다음 단계:"
echo "  1. Claude Code 플러그인 설치: ./install-plugins.sh"
if [ -z "$PROJECT_DIR" ]; then
  echo "  2. 프로젝트에 템플릿 적용: ./install.sh /path/to/project --template <type>"
fi
echo ""
echo "설정 백업 위치: $BACKUP_DIR"
echo "제거: ./uninstall.sh"
