# Agentic Design Patterns

> AI 에이전트가 소프트웨어를 개발하는 시대, 패턴을 이해하면 에이전트를 더 잘 활용할 수 있다.

## 7가지 Agentic Design Patterns

### 1. ReAct (Reasoning + Acting)

**설명**

ReAct는 "생각(Reasoning) -> 행동(Acting) -> 관찰(Observation)" 루프를 반복하는 패턴이다. 에이전트가 문제를 분석하고, 도구를 사용해 행동하고, 결과를 관찰한 뒤 다음 행동을 결정한다. 단순히 한 번에 답을 생성하는 것이 아니라, 단계적으로 추론하면서 실제 환경과 상호작용한다.

**우리 프레임워크에서의 구현**

Sisyphus의 Todo 기반 작업 흐름이 ReAct 패턴 그 자체다.

```
[Reasoning] Todo 목록에서 다음 작업 선택, 구현 방법 판단
     |
[Acting]    코드 작성, 파일 수정, 테스트 실행
     |
[Observation] 결과 확인 (빌드 성공? 테스트 통과? 린트 에러?)
     |
[Reasoning] 다음 Todo 항목으로 이동 또는 실패 시 수정 전략 수립
```

- `TodoWrite`로 작업 목록 관리 (Reasoning 단계의 구조화)
- `Bash`, `Edit`, `Write` 도구로 실행 (Acting 단계)
- 실행 결과를 분석하여 다음 행동 결정 (Observation -> Reasoning)

**예시**

```
사용자: "v2 API에 고객 목록 엔드포인트를 추가해줘"

[Reasoning] 기존 v2 패턴 분석 필요 -> router/service/repository 3계층 구조 확인
[Acting]    기존 paid-db 모듈 코드 읽기
[Observation] 패턴 확인 완료 - router에서 의존성 주입, service에서 비즈니스 로직
[Reasoning] customer 모듈 생성 계획 수립
[Acting]    router.py, service.py, repository.py 파일 생성
[Observation] 파일 생성 완료, ruff check 실행
[Acting]    린트 에러 수정
[Observation] 모든 검증 통과
```

---

### 2. Reflection

**설명**

Reflection은 AI가 자신의 출력물을 스스로 검토하고 개선하는 패턴이다. 한 에이전트가 작성한 결과물을 같은 에이전트 또는 다른 에이전트가 비판적으로 평가하여 품질을 높인다. "Writer/Reviewer" 분리가 핵심이다.

**우리 프레임워크에서의 구현**

1. **Momus Review**: `prometheus`가 작성한 계획을 `momus`가 비판적으로 검토한다.
2. **Quality Gate Hook**: 코드 작성 후 자동으로 린트/타입체크/테스트를 실행하여 품질을 검증한다.
3. **Ralph Loop**: 작업 완료 후 자기 검증 체크리스트를 통과할 때까지 반복한다.

```
Writer (sisyphus-junior)     Reviewer (momus / Quality Gate)
        |                              |
   코드 작성 ------>  코드 리뷰 요청 ---->  문제점 지적
        |                              |
   수정 반영 <------  피드백 전달  <------  개선 제안
        |                              |
   재제출   ------>  최종 승인   ---->  통과
```

**예시**

```
/plan 인증 시스템 리팩토링

[prometheus] 계획서 작성 완료

/review

[momus] "Redis 세션 만료 처리가 계획에 없습니다. 동시 로그인 제한도 고려해야 합니다."

[prometheus] 계획 수정 -> 재리뷰 -> 승인

/sisyphus 구현 시작
```

---

### 3. Tool Use

**설명**

Tool Use는 에이전트가 외부 도구를 활용하여 자신의 한계를 넘어서는 패턴이다. 코드 실행, 파일 시스템 접근, API 호출, 린터/테스터 실행 등 LLM 단독으로는 불가능한 작업을 도구를 통해 수행한다.

**우리 프레임워크에서의 구현**

| 도구 카테고리 | 도구 | 용도 |
|-------------|------|------|
| **파일 시스템** | Read, Write, Edit, Glob, Grep | 코드 읽기/쓰기/검색 |
| **실행 환경** | Bash | 빌드, 테스트, Git 명령어 |
| **MCP 서버** | Playwright, Context7, GitHub | E2E 테스트, 문서 조회, PR 관리 |
| **품질 도구** | ESLint, Ruff, Pyright, pytest | 린트, 타입체크, 테스트 |
| **분석 도구** | multimodal-looker | 스크린샷/다이어그램 분석 |

MCP(Model Context Protocol) 서버를 통해 도구를 표준화된 인터페이스로 연결한다.

```json
// .mcp.json 예시
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": ["playwright", "run-test-mcp-server", "--config", "playwright.config.ts"]
    },
    "context7": {
      "command": "npx",
      "args": ["-y", "@context7/mcp-server"]
    }
  }
}
```

**예시**

```
사용자: "로그인 페이지 스크린샷을 분석해서 UI 개선점을 알려줘"

[Tool Use] multimodal-looker로 스크린샷 분석
[Tool Use] Grep으로 관련 컴포넌트 코드 검색
[Tool Use] Edit으로 스타일 수정
[Tool Use] Playwright로 수정 후 E2E 테스트 실행
```

---

### 4. Planning

**설명**

Planning은 작업 실행 전에 체계적으로 계획을 수립하는 패턴이다. 복잡한 작업일수록 바로 코드를 작성하기보다 전체 구조를 먼저 설계하고, 단계별 실행 계획을 세운 후 진행하는 것이 효율적이다.

**우리 프레임워크에서의 구현**

Prometheus의 인터뷰 -> 계획 워크플로우가 이 패턴을 구현한다.

```
1. /plan <설명>          -- 계획 세션 시작
2. Prometheus 인터뷰      -- 요구사항 구체화 질문
3. 사용자 답변            -- 숨겨진 요구사항 발굴
4. "Create the plan"     -- 계획서 생성
5. /review               -- Momus가 계획 검토
6. /sisyphus             -- 계획 기반 실행
```

**Right-Sized Process 원칙**: 모든 작업에 계획이 필요한 것은 아니다.

| 작업 규모 | 접근법 |
|----------|--------|
| 단순 (1-2 파일) | 바로 구현 (`sisyphus`) |
| 중간 (3-5 파일) | 간단한 todo 목록 후 구현 |
| 복잡 (6+ 파일, 아키텍처 변경) | `prometheus` 계획 -> `momus` 리뷰 -> 구현 |

**예시**

```
/plan Woori DS에 WrDatePicker 컴포넌트 추가

[prometheus] "다음 질문에 답해주세요:
1. 날짜 범위 선택이 필요한가요?
2. 모바일 반응형이 필요한가요?
3. 기존 Quasar QDate를 대체하는 건가요?"

사용자: "범위 선택 필요, 반응형 필수, QDate 대체 목적"

[prometheus] 계획서 작성:
- Phase 1: 토큰 정의 (_tokens.scss)
- Phase 2: 기본 컴포넌트 (WrDatePicker.vue)
- Phase 3: 범위 선택 확장 (WrDateRangePicker.vue)
- Phase 4: 반응형 대응 (breakpoint별 레이아웃)
- Phase 5: 기존 QDate 마이그레이션 가이드
```

---

### 5. Multi-Agent

**설명**

Multi-Agent는 여러 전문 에이전트가 협업하여 작업을 수행하는 패턴이다. 하나의 거대한 에이전트 대신, 역할이 분리된 작은 에이전트들이 각자의 전문 영역을 담당하면 복잡한 작업도 효과적으로 처리할 수 있다.

**우리 프레임워크에서의 구현**

1. **Ultrawork 병렬 실행**: 독립적인 작업을 여러 에이전트가 동시에 처리한다.
2. **Orchestrator 조율**: orchestrator-sisyphus가 여러 sisyphus-junior를 조율한다.
3. **전문가 분업**: 모델 티어별 에이전트 배치 (Opus=아키텍처, Sonnet=구현, Haiku=검색).

```
          [orchestrator-sisyphus] (조율자)
           /        |         \
  [sisyphus-junior] [sisyphus-junior] [sisyphus-junior]
   백엔드 API 구현    프론트엔드 구현     테스트 작성
```

**비용 최적화**: 모든 작업에 Opus를 쓰지 않는다. 작업 복잡도에 맞는 모델을 선택한다.

| 작업 유형 | 에이전트 (모델) | API 비용 |
|----------|---------------|---------|
| 파일 검색 | explore (Haiku) | 최저 |
| 코드 구현 | sisyphus-junior (Sonnet) | 중간 |
| 아키텍처 설계 | oracle (Opus) | 최고 |

**예시**

```
/ultrawork 전체 v2 마이그레이션

[ultrawork] 병렬 작업 분배:
  Agent 1: paid-db 모듈 마이그레이션
  Agent 2: batch-db 모듈 마이그레이션
  Agent 3: dashboard 모듈 마이그레이션
  Agent 4: permission 모듈 마이그레이션

[결과 수집] 4개 모듈 동시 완료 -> 통합 테스트
```

---

### 6. Sequential Pipeline

**설명**

Sequential Pipeline은 작업을 순서가 있는 단계들로 분리하여 처리하는 패턴이다. 각 단계의 출력이 다음 단계의 입력이 된다. 전통적인 소프트웨어 파이프라인과 동일한 개념이며, AI 에이전트 간에도 적용된다.

**우리 프레임워크에서의 구현**

백엔드 v2의 3계층 아키텍처가 Sequential Pipeline의 전형적인 예다.

```
[Router]  요청 수신, 파라미터 검증, 의존성 주입
    |
    v
[Service] 비즈니스 로직, 데이터 가공, 권한 검증
    |
    v
[Repository] SQL 실행, DB 접근, 결과 반환
    |
    v
[Response] V2Response { status, message, data } 표준 응답
```

에이전트 워크플로우에서도 파이프라인이 적용된다.

```
[metis] 숨겨진 요구사항 분석
   |
   v
[prometheus] 전략적 계획 수립
   |
   v
[momus] 계획 리뷰 및 개선
   |
   v
[orchestrator] 작업 분배 및 실행
   |
   v
[Quality Gate] 린트/타입체크/테스트 검증
```

**예시**

```
v2 API 엔드포인트 생성 파이프라인:

Step 1: [repository.py] SQL 쿼리 작성 (%s 바인딩 필수)
Step 2: [service.py]    비즈니스 로직 + WHERE 빌더 (clauses, params)
Step 3: [router.py]     FastAPI 엔드포인트 + 의존성 주입
Step 4: [ruff check]    린트 검증
Step 5: [pytest]        테스트 실행
Step 6: [pyright]       타입 체크
```

---

### 7. Human-in-the-Loop

**설명**

Human-in-the-Loop은 AI 워크플로우에 인간의 판단과 승인을 포함하는 패턴이다. AI가 모든 것을 자동으로 처리하는 것이 아니라, 중요한 결정 지점에서 인간이 개입하여 방향을 조정한다. 특히 비즈니스 임팩트가 큰 변경에서 필수적이다.

**우리 프레임워크에서의 구현**

```
[Plan] prometheus가 계획 생성
   |
   v
[Human Review] 사용자가 계획 검토 및 승인  <-- 인간 개입
   |
   v
[Execute] sisyphus가 승인된 계획 실행
   |
   v
[Human Verify] 사용자가 결과물 확인  <-- 인간 개입
```

Claude Code에서의 Human-in-the-Loop 포인트:

| 시점 | 인간 역할 | 도구 |
|-----|----------|------|
| 계획 승인 | 요구사항 확인, 방향 조정 | `/plan` -> `/review` |
| 파일 수정 승인 | 위험한 변경 거부 가능 | Claude Code 자동 확인 |
| Git 커밋 | 커밋 메시지/범위 확인 | 명시적 요청 시에만 커밋 |
| 배포 | 운영 반영 최종 승인 | GitHub PR 리뷰 |

**예시**

```
사용자: "/plan 계약 모듈 v2 마이그레이션"

[prometheus] "계약/정산은 비즈니스 임팩트가 큽니다. 다음을 확인해주세요:
1. 스테이징 환경에서 충분히 테스트할 수 있나요?
2. 롤백 계획이 있나요?
3. 마이그레이션 기간 중 운영 중단이 가능한가요?"

사용자: "아직 준비가 안 됐습니다. 다른 모듈부터 진행합시다."

[계획 변경] 계약/정산 제외, 나머지 모듈 우선 마이그레이션으로 조정
```

---

## Writer/Reviewer 패턴

AI 코드 품질을 높이는 핵심은 **작성자와 검토자를 분리**하는 것이다.

### 왜 분리해야 하는가

하나의 에이전트가 코드를 작성하고 자기가 검토하면, 자신의 실수를 발견하기 어렵다. 이것은 인간 개발자도 마찬가지다. "자기가 쓴 코드는 자기 눈에는 항상 맞아 보인다."

### 우리 프레임워크의 Writer/Reviewer 구현

```
Writer: sisyphus-junior (Sonnet)
  - 코드 작성에 최적화
  - 실행 비용이 낮음
  - 빠른 반복 가능

Reviewer: momus (Opus)
  - 비판적 분석에 최적화
  - 더 높은 추론 능력
  - 숨겨진 문제 발견

Quality Gate (자동화):
  - ESLint: 코드 스타일 검증
  - Ruff: Python 린트
  - Pyright: 타입 안전성
  - pytest: 기능 검증
```

### 3단계 검증 루프

```
Level 1: 자동 검증 (Quality Gate)
  -> 린트, 타입체크, 테스트 자동 실행
  -> 실패 시 Writer가 즉시 수정

Level 2: AI 리뷰 (Momus)
  -> 로직 오류, 설계 문제, 보안 취약점 검토
  -> 피드백 기반 수정

Level 3: 인간 리뷰 (Human-in-the-Loop)
  -> 비즈니스 로직 검증, 최종 승인
  -> PR 리뷰로 구현
```

---

### 8. Headless CI/CD Integration

**설명**

Headless 모드는 Claude Code를 비대화형 파이프라인에 통합하는 패턴이다. `-p` 플래그로 프롬프트를 직접 전달하고, stdout으로 결과를 받는다. 이를 통해 CI/CD 파이프라인에 AI 기반 코드 리뷰, 문서 생성, 테스트 분석을 자동화할 수 있다.

**우리 프레임워크에서의 구현**

```bash
# 기본 사용: Headless 모드로 실행
claude -p "Fix the lint errors"

# 파이프라인 통합: stdin에서 입력 받기
git diff | claude -p "Explain these changes"

# JSON 출력: 구조화된 결과
echo "Review this PR" | claude -p --json
```

**GitHub Actions 통합 예시**

```yaml
name: Claude Code Review
on:
  pull_request:
    types: [opened, synchronize]

jobs:
  review:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Review PR
        env:
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
        run: |
          git diff origin/main...HEAD | \
          claude -p "Review this PR and identify potential issues" \
          > review.md
```

**적용 시나리오**:
- PR 자동 리뷰 (코드 품질, 보안 취약점 감지)
- 커밋 메시지 품질 검증
- 자동 문서 생성 (API docs, changelog)
- 테스트 실패 원인 자동 분석

---

### 9. Container Sandbox

**설명**

위험한 실험이나 자율 작업을 **격리된 컨테이너 환경**에서 수행하는 패턴이다. `--dangerously-skip-permissions` 플래그의 위험성을 컨테이너로 완화하면서, 완전한 자율 실행의 이점을 누릴 수 있다.

**우리 프레임워크에서의 구현**

```
[호스트: 메인 Claude]
  │
  ├─ 안전한 작업: 직접 수행 (일반 모드)
  │
  └─ 위험한 작업: Docker 컨테이너로 위임
       │
       └─ [컨테이너: 워커 Claude]
            --dangerously-skip-permissions 모드
            격리된 파일 시스템
            마운트된 작업 디렉토리만 접근 가능
```

```bash
# 컨테이너에서 Claude Code 실행
docker run -it --rm \
  -v $(pwd):/workspace \
  -e ANTHROPIC_API_KEY=$ANTHROPIC_API_KEY \
  claude-sandbox claude --dangerously-skip-permissions
```

**적용 시나리오**:
- 대규모 리팩토링 실험 (실패해도 호스트에 영향 없음)
- 알 수 없는 코드베이스 분석 (보안 리스크 격리)
- 장시간 자율 작업 (사람 없이 완료까지 실행)
- 새 버전 테스트 (컨테이너에서 먼저 검증)

**주의**: Container Sandbox는 실험/테스트 용도다. 프로덕션 코드 수정은 반드시 일반 모드에서 검증 절차를 거쳐 수행한다.

---

## 2026 Agentic Coding 트렌드

### 1. Context Engineering의 부상

2025년에는 "Prompt Engineering"이 화두였다면, 2026년에는 **Context Engineering**이 핵심이다. 단순히 프롬프트를 잘 작성하는 것을 넘어서, AI에게 제공하는 전체 컨텍스트를 엔지니어링하는 것이다.

우리 프레임워크에서의 적용:
- **CLAUDE.md**: 프로젝트 컨텍스트를 구조화하여 제공
- **MEMORY.md**: 학습된 교훈을 누적하여 반복 실수 방지
- **Skills**: 작업 유형별 전문 컨텍스트 주입

```
Context = Instructions (CLAUDE.md)
        + Memory (MEMORY.md)
        + Skills (/v2-api, /wr-component)
        + Tools (MCP servers)
        + Codebase (파일 시스템)
```

### 2. Human Architect, AI Implementer

Anthropic의 보고서와 Addy Osmani의 분석이 공통적으로 지적하는 패턴: **인간은 설계자, AI는 구현자**가 된다.

- 인간의 역할: 아키텍처 결정, 비즈니스 로직 판단, 코드 리뷰
- AI의 역할: 보일러플레이트 작성, 테스트 생성, 리팩토링, 문서화

METR 연구에 따르면, 구조화된 워크플로우 없이 AI를 사용하면 오히려 19% 느려질 수 있다. 하지만 체계적인 프레임워크(계획 -> 구현 -> 검증)를 적용하면 생산성이 크게 향상된다.

### 3. 멀티 에이전트 협업의 일상화

단일 AI 어시스턴트 시대에서 **전문 에이전트 팀** 시대로 전환되고 있다.

- 2025: "AI에게 질문하기" (단일 대화)
- 2026: "AI 팀을 조율하기" (멀티 에이전트 오케스트레이션)

우리 프레임워크의 12개 에이전트 시스템이 이 트렌드를 선도한다. 비용 효율을 위해 Haiku/Sonnet/Opus 티어를 작업 복잡도에 맞춰 배치하는 것이 핵심이다.

### 4. AI가 코드의 90%를 작성하는 시대의 개발자 역할

AI가 대부분의 코드를 작성하게 되면, 개발자의 역할은 근본적으로 변한다.

| 과거 | 현재/미래 |
|-----|----------|
| 코드 직접 작성 | 에이전트에게 명세 전달 |
| 디버깅 | AI 출력물 검증 |
| 문서 읽기 | Context Engineering |
| 코드 리뷰 | AI + Human 하이브리드 리뷰 |
| 기술 선택 | 에이전트 조합 설계 |

개발자는 **"코딩하는 사람"에서 "AI를 통해 소프트웨어를 만드는 엔지니어"**로 진화한다. 이 전환에서 가장 중요한 역량은:

1. **명확한 요구사항 정의** 능력
2. **시스템 아키텍처 설계** 능력
3. **AI 출력물의 품질 판단** 능력
4. **효과적인 컨텍스트 구성** 능력

이것이 바로 heejuna-engineering 프레임워크가 추구하는 방향이다.
