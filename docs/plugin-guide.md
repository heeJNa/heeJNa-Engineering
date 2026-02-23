# Claude Code 플러그인 완전 가이드

> 초보자를 위한 단계별 설치 및 설정 가이드

## 사전 요구사항

시작하기 전에 다음이 설치되어 있어야 한다.

| 요구사항 | 확인 방법 | 최소 버전 |
|---------|----------|----------|
| Claude Code CLI | `claude --version` | 최신 버전 |
| Node.js | `node --version` | 18.0+ |
| npm/pnpm | `npm --version` | 해당 없음 |
| Git | `git --version` | 2.0+ |

Claude Code CLI가 설치되어 있지 않다면:

```bash
# Claude Code 설치
npm install -g @anthropic-ai/claude-code

# 설치 확인
claude --version
```

---

## 필수 플러그인 (Must Have)

이 세 가지는 반드시 설치해야 한다. heejuna-engineering 프레임워크의 핵심 기능을 제공한다.

### 1. Oh-My-ClaudeCode (OMC)

**멀티 에이전트 오케스트레이션 시스템**

OMC는 이 프레임워크의 근간이다. Sisyphus, Ultrawork, Ralph Loop, Prometheus 등 모든 멀티 에이전트 기능을 제공한다.

**설치**

```bash
# Claude Code 내에서 실행
/install Yeachan-Heo/oh-my-claudecode
```

**제공 기능**

| 명령어 | 기능 |
|--------|------|
| `/sisyphus <task>` | Todo 기반 멀티에이전트 작업 실행 |
| `/ultrawork <task>` | 병렬 에이전트 최대 성능 모드 |
| `/ralph-loop <task>` | 완료 보장 자기참조 루프 |
| `/prometheus <task>` | 전략적 계획 수립 (인터뷰 워크플로우) |
| `/orchestrator <task>` | 복잡한 다단계 작업 조율 |
| `/plan <description>` | 계획 세션 시작 |
| `/review [path]` | 계획/코드 리뷰 |
| `/deepsearch <query>` | 심층 코드베이스 검색 |
| `/analyze <target>` | 깊은 분석 및 조사 |

**설치 확인**

```bash
# Claude Code 내에서 다음 명령어가 작동하는지 확인
/sisyphus 테스트

# 정상이면 Todo 목록이 생성되고 에이전트가 작업을 시작한다
```

**주의사항**

- CLAUDE.md에 OMC 설정이 자동으로 추가된다
- 기존 CLAUDE.md가 있다면 내용이 병합된다
- 에이전트 모델 선택 (Opus/Sonnet/Haiku)은 작업 복잡도에 따라 자동 결정된다

---

### 2. Superpowers

**개발 방법론 스킬 모음**

Superpowers는 TDD, Systematic Debugging, Verification Loop 등 검증된 개발 방법론을 Claude Code에 주입한다.

**설치**

```bash
/install obra/superpowers
```

**제공 기능**

| 스킬 | 용도 |
|------|------|
| TDD (Test-Driven Development) | 테스트 먼저 작성 -> 구현 -> 리팩토링 |
| Systematic Debugging | 체계적 디버깅 프로세스 |
| Verification Loops | 구현 후 자동 검증 루프 |
| Incremental Development | 점진적 개발 (작은 단위로 나눠서) |

**중요: SDD와의 충돌**

Superpowers에 포함된 SDD(Spec-Driven Development) 스킬은 Sisyphus의 Todo 기반 워크플로우와 충돌한다. **SDD는 사용하지 않는다.**

```
사용하는 것: TDD, systematic-debugging, verification
사용하지 않는 것: SDD (Spec-Driven Development)
```

**설치 확인**

```bash
# Claude Code 내에서 TDD 스킬이 활성화되는지 확인
# 코드 작성 요청 시 테스트를 먼저 작성하는 패턴이 나타나면 정상
```

---

### 3. Anthropic Official Skills

**공식 문서 생성 및 테스팅 스킬**

Anthropic에서 공식으로 제공하는 스킬 모음이다. 문서 생성(PDF, PPTX, DOCX), 웹앱 테스팅, 프론트엔드 디자인 등을 지원한다.

**설치**

```bash
/install anthropics/skills
```

**제공 기능**

| 스킬 | 명령어 | 용도 |
|------|--------|------|
| PDF 생성 | `/pdf` | PDF 문서 생성 |
| PPTX 생성 | `/pptx` | 프레젠테이션 생성 |
| DOCX 생성 | `/docx` | Word 문서 생성 |
| Webapp Testing | 자동 | 웹앱 테스트 지원 |
| Frontend Design | 자동 | 프론트엔드 디자인 가이드 |

**설치 확인**

```bash
# Claude Code 내에서 문서 생성 명령어 확인
/pdf 테스트 문서 생성
```

---

## 추천 플러그인 (Recommended)

필수는 아니지만 설치하면 생산성이 크게 향상되는 플러그인들이다.

### 4. Context7

**라이브러리 문서 자동 조회**

코드 작성 중 사용하는 라이브러리의 최신 문서를 자동으로 조회한다. AI가 오래된 API를 사용하는 문제를 방지한다.

```bash
/install context7
```

**활용 예시**: Vue 3 Composition API, Nuxt 4 API, FastAPI 최신 문법 등을 작업 중 자동으로 참조한다. 특히 메이저 버전 변경이 잦은 프레임워크에서 유용하다.

---

### 5. Code Review

**PR 코드 리뷰 자동화**

GitHub Pull Request에 대한 자동 코드 리뷰를 수행한다.

```bash
/install code-review
```

**활용 예시**: PR 생성 시 자동으로 코드 리뷰를 실행하여, 보안 취약점, 성능 이슈, 코딩 표준 위반 등을 사전에 발견한다.

---

### 6. GitHub

**GitHub 심화 연동**

기본 `gh` CLI를 넘어서는 GitHub 연동 기능을 제공한다.

```bash
/install github
```

**활용 예시**: 이슈 분석, PR 자동 생성, 릴리스 노트 작성 등 GitHub 워크플로우를 에이전트가 직접 수행한다.

---

### 7. Frontend Design

**프론트엔드 디자인 가이드**

UI/UX 구현 시 디자인 원칙과 접근성 가이드를 제공한다.

```bash
/install frontend-design
```

**활용 예시**: Woori DS 컴포넌트 설계 시 접근성(a11y), 반응형 디자인, 색상 대비 등의 가이드라인을 참조한다.

---

### 8. TypeScript LSP

**TypeScript 언어 서버 연동**

TypeScript의 타입 시스템을 에이전트가 직접 활용하여 더 정확한 코드를 작성한다.

```bash
/install typescript-lsp
```

**활용 예시**: 자동 완성, 타입 추론, 리팩토링 시 타입 안전성을 에이전트 수준에서 보장한다.

---

### 9. Playwright

**E2E 테스트 에이전트**

Playwright를 활용한 End-to-End 테스트를 에이전트가 직접 작성하고 실행한다.

```bash
/install playwright
```

**주의사항**: `--config` 옵션이 필수다. 없으면 workspace root에서 config를 찾지 못해 "seed test not found" 에러가 발생한다.

```json
// .mcp.json 설정 예시
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": ["playwright", "run-test-mcp-server", "--config", "playwright.config.ts"]
    }
  }
}
```

---

### 10. Code Simplifier

**코드 정리 및 간소화**

복잡한 코드를 더 읽기 쉽고 유지보수하기 좋은 형태로 리팩토링한다.

```bash
/install code-simplifier
```

**활용 예시**: 레거시 코드 정리, 중복 제거, 복잡한 조건문 간소화 등에 활용한다.

---

### 11. Ralph Loop

**완료 보장 루프**

작업이 완전히 완료될 때까지 자기참조 루프를 실행한다. OMC에 포함된 기능이지만, 독립 플러그인으로도 사용 가능하다.

```bash
/install ralph-loop
```

**활용 예시**: "이 작업은 반드시 완료되어야 한다"는 요구사항이 있을 때, 모든 체크리스트를 통과할 때까지 반복한다.

---

## 선택 플러그인 (Optional)

특정 용도에서만 필요한 플러그인들이다.

### Figma

디자인 파일을 직접 참조하여 구현한다. 디자이너와 협업 시 유용하다.

```bash
/install figma
```

### Security Guidance (Trail of Bits)

보안 관련 코드 작성 시 가이드를 제공한다. 인증, 암호화, SQL 인젝션 방지 등.

```bash
/install trailofbits/skills
```

### Agent SDK Dev

커스텀 에이전트를 개발할 때 사용한다. 일반 사용자에게는 불필요하다.

```bash
/install agent-sdk-dev
```

---

## 전체 한번에 설치

Claude Code를 열고 아래 명령어를 순서대로 입력한다.

**필수 플러그인**:
```
/install Yeachan-Heo/oh-my-claudecode
/install obra/superpowers
/install anthropics/skills
```

**추천 플러그인**:
```
/install context7
/install code-review
/install github
/install frontend-design
/install typescript-lsp
/install playwright
/install code-simplifier
/install ralph-loop
```

**선택 플러그인** (필요시):
```
/install figma
/install trailofbits/skills
/install agent-sdk-dev
```

> 참고: `/install` 명령어는 Claude Code 세션 내에서만 실행 가능하다. 일괄 설치 가이드 스크립트는 `install-plugins.sh`를 참조하라.

---

## 설치 후 확인

### 1. 전체 스킬 목록 확인

```bash
# Claude Code 내에서
/help
```

모든 설치된 스킬과 명령어가 표시되어야 한다.

### 2. 핵심 기능 동작 확인

| 확인 항목 | 테스트 방법 | 기대 결과 |
|----------|-----------|----------|
| Sisyphus | `/sisyphus 간단한 테스트` | Todo 목록 생성 및 작업 시작 |
| Ultrawork | `/ultrawork 파일 3개 동시 생성` | 병렬 에이전트 실행 |
| Prometheus | `/plan 테스트 계획` | 인터뷰 질문 시작 |
| TDD | "테스트 먼저 작성해서 구현해줘" | 테스트 코드 먼저 생성 |
| 문서 생성 | `/pdf 테스트` | PDF 파일 생성 |

### 3. 충돌 확인

플러그인 간 충돌이 발생할 수 있는 경우:

| 충돌 유형 | 증상 | 해결 방법 |
|----------|------|----------|
| SDD vs Sisyphus | 스펙 파일과 Todo가 동시 생성 | SDD 비활성화 |
| 여러 린터 중복 | 같은 파일에 대해 여러 린터 실행 | Hook에서 하나만 지정 |
| MCP 포트 충돌 | MCP 서버 시작 실패 | 포트 설정 변경 |

### 4. CLAUDE.md 확인

플러그인 설치 후 프로젝트 루트의 `CLAUDE.md` 파일을 확인한다. 각 플러그인이 추가한 설정이 기존 내용과 잘 병합되었는지 검토한다.

```bash
# CLAUDE.md 내용 확인
cat CLAUDE.md
```

---

## MCP 최적화 가이드라인

MCP(Model Context Protocol) 서버는 Claude Code에 외부 도구와 서비스를 연결하는 강력한 기능이지만, 과도하게 설정하면 성능이 저하된다.

### 권장 한도

| 항목 | 권장 한도 | 이유 |
|------|----------|------|
| MCP 서버 수 | **10개 이하** | 서버마다 시작/통신 오버헤드 |
| 총 MCP 도구 수 | **80개 이하** | 도구 설명이 컨텍스트를 소비 |
| 서버당 도구 수 | **10-15개** | 도구 선택의 정확도 유지 |

### 최적화 방법

1. **사용하지 않는 MCP 서버 제거**: 설치만 해놓고 사용하지 않는 서버는 비활성화
2. **프로젝트별 MCP 분리**: 글로벌(`~/.claude/.mcp.json`)보다 프로젝트별(`.mcp.json`) 설정 우선
3. **도구 수 관리**: 한 서버에 너무 많은 도구가 있으면 성능 저하 (Claude가 올바른 도구를 선택하기 어려움)
4. **Deferred loading 활용**: Claude Code의 `ToolSearch`를 통해 필요 시에만 도구를 로드

### MCP 설정 확인

```bash
# Claude Code 내에서
/mcp              # 현재 연결된 MCP 서버 목록
```

---

## 자주 묻는 질문

### Q: 플러그인을 제거하려면?

현재 Claude Code는 `/uninstall` 명령어를 공식 지원하지 않는다. CLAUDE.md에서 해당 플러그인이 추가한 설정을 수동으로 제거하면 된다.

### Q: 플러그인 업데이트는?

```bash
/update
```

OMC에서 제공하는 업데이트 명령어로 최신 버전을 확인하고 설치할 수 있다.

### Q: 플러그인 없이도 프레임워크를 사용할 수 있나?

CLAUDE.md와 MEMORY.md만으로도 기본적인 Context Engineering은 가능하다. 하지만 멀티 에이전트 오케스트레이션, TDD 방법론, 문서 생성 등 고급 기능은 플러그인이 필요하다.

### Q: 회사 네트워크에서 설치가 안 된다면?

GitHub 접근이 제한된 환경에서는 플러그인 저장소를 내부 미러에 복제한 후 로컬 경로로 설치할 수 있다.

```bash
# 저장소 복제
git clone https://github.com/Yeachan-Heo/oh-my-claudecode.git /path/to/local

# 로컬 경로로 설치 (지원 여부는 Claude Code 버전에 따라 다름)
/install /path/to/local
```
