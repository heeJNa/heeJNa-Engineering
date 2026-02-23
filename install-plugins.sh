#!/bin/bash
# =============================================================================
# heejuna-engineering 추천 플러그인 설치 가이드
# =============================================================================
# 주의: Claude Code 플러그인은 CLI 내부의 /install 명령어로만 설치 가능합니다.
#       이 스크립트는 설치할 명령어를 안내합니다.
# =============================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${BLUE}=== heejuna-engineering 플러그인 설치 가이드 ===${NC}"
echo ""
echo -e "${YELLOW}아래 명령어를 Claude Code CLI 안에서 실행하세요.${NC}"
echo -e "${YELLOW}(이 스크립트는 가이드만 제공합니다)${NC}"
echo ""

# ─────────────────────────────────────────────────────────────────────────────
echo -e "${GREEN}━━━ 필수 플러그인 (Must Have) ━━━${NC}"
echo ""

echo -e "${CYAN}1. Oh-My-ClaudeCode (OMC)${NC} — 멀티에이전트 오케스트레이션"
echo "   /install Yeachan-Heo/oh-my-claudecode"
echo ""

echo -e "${CYAN}2. Superpowers${NC} — TDD, systematic-debugging, verification"
echo "   /install obra/superpowers"
echo ""

echo -e "${CYAN}3. Anthropic Official Skills${NC} — 문서/테스팅/디자인"
echo "   /install anthropics/skills"
echo ""

# ─────────────────────────────────────────────────────────────────────────────
echo -e "${GREEN}━━━ 추천 플러그인 (Recommended) ━━━${NC}"
echo ""

echo -e "${CYAN}4. Context7${NC} — 라이브러리 문서 자동 조회"
echo "   /install context7"
echo ""

echo -e "${CYAN}5. Code Review${NC} — PR 코드 리뷰"
echo "   /install code-review"
echo ""

echo -e "${CYAN}6. GitHub${NC} — GitHub 연동"
echo "   /install github"
echo ""

echo -e "${CYAN}7. Frontend Design${NC} — 프론트엔드 디자인"
echo "   /install frontend-design"
echo ""

echo -e "${CYAN}8. TypeScript LSP${NC} — TypeScript 언어 서버"
echo "   /install typescript-lsp"
echo ""

echo -e "${CYAN}9. Playwright${NC} — E2E 테스트"
echo "   /install playwright"
echo ""

echo -e "${CYAN}10. Code Simplifier${NC} — 코드 정리"
echo "    /install code-simplifier"
echo ""

echo -e "${CYAN}11. Ralph Loop${NC} — 완료 보장 루프"
echo "    /install ralph-loop"
echo ""

# ─────────────────────────────────────────────────────────────────────────────
echo -e "${GREEN}━━━ 선택 플러그인 (Optional) ━━━${NC}"
echo ""

echo -e "${CYAN}12. Figma${NC} — 디자인 연동"
echo "    /install figma"
echo ""

echo -e "${CYAN}13. Security Guidance (Trail of Bits)${NC} — 보안 가이드"
echo "    /install trailofbits/skills"
echo ""

echo -e "${CYAN}14. Agent SDK Dev${NC} — 에이전트 SDK 개발"
echo "    /install agent-sdk-dev"
echo ""

# ─────────────────────────────────────────────────────────────────────────────
echo -e "${BLUE}━━━ 설치 확인 ━━━${NC}"
echo ""
echo "설치 후 Claude Code CLI에서 다음을 확인하세요:"
echo "  /help            — 전체 skill 목록 확인"
echo "  /sisyphus test   — OMC 작동 확인"
echo "  /plugins         — 설치된 플러그인 목록"
echo ""

echo -e "${GREEN}=== 가이드 끝 ===${NC}"
