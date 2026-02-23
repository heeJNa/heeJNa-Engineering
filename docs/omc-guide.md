# Oh-My-ClaudeCode (OMC) 상세 사용 설명서

> 멀티 에이전트 오케스트레이션의 핵심. AI 팀을 조율하는 지휘자.

---

## 개요

Oh-My-ClaudeCode(OMC)는 Claude Code에 **멀티 에이전트 오케스트레이션** 기능을 추가하는 플러그인이다. 하나의 AI가 모든 일을 하는 것이 아니라, **여러 전문 AI 에이전트가 역할을 나눠서 협업**하는 시스템이다.

### 비유

> 건설 현장을 생각해보자. 현장소장(Orchestrator)이 설계도(Plan)를 받아서, 배관공(Backend Agent), 전기기사(Frontend Agent), 인테리어(Design Agent)에게 동시에 작업을 지시한다. 각 전문가는 자기 영역만 집중하고, 현장소장이 전체 진행을 관리한다.

OMC가 없는 Claude Code는 "혼자서 모든 걸 하는 인부"이고, OMC가 있는 Claude Code는 "전문가 팀을 이끄는 현장소장"이다.

---

## 설치

```bash
# Claude Code 내에서 실행
/install Yeachan-Heo/oh-my-claudecode
```

설치 후 `~/.claude/CLAUDE.md`에 OMC 설정이 자동으로 추가된다.

---

## 핵심 명령어

### `/sisyphus <task>` — 기본 작업 모드

가장 자주 사용하는 명령어. Todo 기반으로 작업을 추적하며 완료까지 진행한다.

```
/sisyphus v2 고객 관리 API 추가

[sisyphus 동작]
1. 작업을 Todo 항목으로 분해
   - [ ] repository.py 생성
   - [ ] service.py 생성
   - [ ] router.py 생성
   - [ ] 테스트 작성
2. 각 항목을 순차적으로 실행
3. Quality Gate로 검증
4. 모든 항목 완료까지 멈추지 않음
```

**언제 사용하나?**
- 파일 2개 이상을 변경하는 일반적인 개발 작업
- 버그 수정, 기능 추가, 리팩토링
- "해야 할 일 목록"이 명확한 작업

---

### `/ultrawork <task>` — 최대 성능 모드

독립적인 작업을 **병렬로 동시 실행**한다. 여러 에이전트가 각각 다른 파일을 동시에 작업한다.

```
/ultrawork 3개 API 모듈 동시 생성: customer, product, order

[ultrawork 동작]
[Agent 1] customer 모듈 생성 중...
[Agent 2] product 모듈 생성 중...    ← 동시 실행!
[Agent 3] order 모듈 생성 중...
```

**언제 사용하나?**
- 서로 독립적인 3개 이상의 작업이 있을 때
- "동시에 해도 충돌 안 나는" 작업들
- 시간이 급할 때

**주의:** 서로 의존하는 작업(A가 끝나야 B를 할 수 있는 경우)에는 사용하지 않는다.

---

### `/plan <description>` — 계획 세션 (Prometheus)

복잡한 작업을 시작하기 전에 **체계적으로 계획**을 세운다. Prometheus 에이전트가 인터뷰를 진행한다.

```
/plan 사용자 인증 시스템 리팩토링

[prometheus] 다음 질문에 답해주세요:
1. 현재 세션 기반인가요, JWT인가요?
2. OAuth(소셜 로그인)도 포함하나요?
3. 이번에 바꿔야 할 범위는 어디까지인가요?
4. 하위 호환성을 유지해야 하나요?

[사용자 답변 후]

[prometheus] 계획서 생성:
Phase 1: 새 인증 미들웨어 작성 (기존 코드 무변경)
Phase 2: 새 API에 먼저 적용
Phase 3: 기존 API 점진적 마이그레이션
Phase 4: 레거시 인증 코드 제거
```

**언제 사용하나?**
- 파일 5개 이상 변경하는 대규모 작업
- 아키텍처 변경, 마이그레이션
- "어디서부터 시작할지 모르겠는" 복잡한 작업
- 요구사항이 모호할 때

---

### `/review [path]` — 계획 리뷰 (Momus)

작성된 계획을 **비판적으로 검토**한다. Momus 에이전트는 의도적으로 문제점을 찾는다.

```
/review

[momus] 리뷰 결과:
1. 위험: Phase 3에서 롤백 전략이 없습니다.
2. 누락: 동시 요청 시 세션 충돌 처리가 없습니다.
3. 개선: Phase 1과 2를 병렬로 수행할 수 있습니다.
4. 질문: 기존 세션 만료 시간은 유지하나요?
```

**언제 사용하나?**
- `/plan`으로 계획을 세운 직후
- 중요한 아키텍처 결정 전
- "이 방향이 맞나?" 확인하고 싶을 때

---

### `/ralph-loop <task>` — 완료 보장 루프

작업이 **100% 완료될 때까지 절대 멈추지 않는다**. 자기 검증 체크리스트를 통과할 때까지 반복한다.

```
/ralph-loop 모든 테스트가 통과하도록 버그 수정

[ralph-loop 동작]
Iteration 1: 버그 분석 → 수정 → 테스트 실행 → 3개 실패
Iteration 2: 실패 원인 분석 → 수정 → 테스트 실행 → 1개 실패
Iteration 3: 마지막 실패 수정 → 테스트 실행 → 전체 통과!
[완료] 모든 체크리스트 통과
```

**언제 사용하나?**
- "반드시 끝내야 하는" 작업
- 테스트를 전부 통과시켜야 할 때
- 여러 세션에 걸쳐 이어지는 장기 작업

**중지:** `/cancel-ralph`

---

### `/orchestrator <task>` — 복잡한 다단계 조율

자신은 코드를 작성하지 않고, **하위 에이전트에게 작업을 분배하고 결과를 취합**한다.

```
/orchestrator v2 풀스택 기능 개발

[orchestrator 분배]
→ [sisyphus-junior #1] 백엔드 API 구현
→ [sisyphus-junior #2] 프론트엔드 API 클라이언트
→ [frontend-engineer] UI 컴포넌트
→ [document-writer] API 문서

[orchestrator 취합]
→ 전체 통합 테스트 실행
→ 결과 보고
```

**언제 사용하나?**
- 백엔드 + 프론트엔드 + 테스트를 한 번에
- 여러 전문 분야가 관여하는 작업

---

### `/deepsearch <query>` — 심층 코드베이스 검색

코드베이스 전체를 심층적으로 검색한다.

```
/deepsearch useV2Api가 사용되는 모든 곳

[결과]
- composables/v2Api.ts (정의)
- pages/v2/paid-db/index.vue (사용)
- pages/v2/batch-db/index.vue (사용)
- components/v2/dashboard/Chart.vue (사용)
```

---

### `/analyze <target>` — 깊은 분석

코드나 시스템을 깊이 분석한다.

```
/analyze 현재 인증 시스템의 보안 취약점

[분석 결과]
1. JWT 토큰 만료 시간이 24시간으로 과도하게 길다
2. Refresh Token 회전이 구현되지 않았다
3. 세션 동시 접속 제한이 없다
...
```

---

## 12개 에이전트 시스템

OMC는 작업 복잡도에 따라 다른 모델(AI)을 사용하여 비용을 최적화한다.

### Opus 티어 (최고 성능, 높은 비용)

복잡한 추론이 필요한 작업에만 사용.

| 에이전트 | 역할 | 사용 시점 |
|----------|------|-----------|
| **Oracle** | 아키텍처 분석, 복잡한 디버깅 | 원인 불명 버그, 설계 결정 |
| **Momus** | 비판적 리뷰, 문제점 발견 | 계획 검토, 코드 리뷰 |
| **Metis** | 숨겨진 요구사항 발굴, 위험 분석 | 대규모 작업 시작 전 |
| **Prometheus** | 전략적 계획 수립 | 복잡한 기능 계획 |

### Sonnet 티어 (균형 잡힌 성능, 중간 비용)

대부분의 코드 구현에 사용.

| 에이전트 | 역할 | 사용 시점 |
|----------|------|-----------|
| **Sisyphus-Junior** | 코드 작성/수정 | 일반적인 구현 작업 |
| **Frontend-Engineer** | UI/UX 구현 | 컴포넌트, 스타일링 |
| **Librarian** | 문서 검색, 코드 이해 | 기존 코드 파악 |
| **Multimodal-Looker** | 스크린샷/다이어그램 분석 | 디자인 → 코드 변환 |
| **Orchestrator-Sisyphus** | 작업 분배, 조율 | 다단계 복합 작업 |
| **QA-Tester** | 기능 테스트, 검증 | E2E 테스트 |

### Haiku 티어 (빠른 응답, 최저 비용)

단순하고 빠른 작업에 사용.

| 에이전트 | 역할 | 사용 시점 |
|----------|------|-----------|
| **Explore** | 빠른 파일/패턴 검색 | "이 파일 어딨지?" |
| **Document-Writer** | 문서 작성 | README, API 문서 |

### 비용 최적화 원칙

```
가장 저렴한 에이전트부터 시도:

"이 함수 어디에 있지?"
  X oracle (Opus) — 과도한 비용
  X librarian (Sonnet) — 불필요한 비용
  O explore (Haiku) — 적절한 비용
```

---

## 워크플로우 예시

### 예시 1: 간단한 버그 수정 (Medium)

```
/sisyphus 로그인 실패 시 에러 메시지가 안 뜨는 버그 수정

1. [explore] 관련 파일 검색
2. [sisyphus-junior] 원인 분석 → 수정
3. [Quality Gate] lint + typecheck 통과 확인
4. 완료
```

### 예시 2: 새 기능 추가 (Large)

```
/plan 유저 프로필 페이지 추가
→ [prometheus] 인터뷰 → 계획서 생성

/review
→ [momus] 계획 검토 → 개선점 제안

/sisyphus 유저 프로필 구현
→ [ultrawork 병렬 실행]
   Agent 1: 백엔드 API
   Agent 2: 프론트엔드 페이지
   Agent 3: API 클라이언트
→ [순차 실행]
   통합 연결 → 테스트 작성
→ [Quality Gate] 전체 검증
```

### 예시 3: 대규모 마이그레이션 (X-Large)

```
/plan v1 → v2 API 전체 마이그레이션

→ [metis] 숨겨진 요구사항 + 위험 분석
→ [prometheus] 단계별 마이그레이션 계획
→ [momus] 계획 리뷰

/ralph-loop v2 마이그레이션 전체 실행
→ Phase 1: 새 구조 병행 도입
→ Phase 2: 모듈별 점진적 이동
→ Phase 3: 레거시 제거
→ [ralph-loop] 모든 테스트 통과까지 반복
```

---

## Skill 조합 가이드

OMC의 스킬은 3개 레이어로 구성되며, **조합하여 사용**한다.

### 레이어 구조

```
[실행 레이어] — HOW: 작업 수행 방식 선택 (1개)
  sisyphus, orchestrator, prometheus

[보강 레이어] — ADD: 추가 능력 부여 (0~N개)
  ultrawork, git-master, frontend-ui-ux

[보증 레이어] — ENSURE: 완료 보장 (0~1개)
  ralph-loop
```

### 조합 공식

```
Skill 조합 = [실행 1개] + [보강 0~N개] + [보증 0~1개]
```

### 실전 조합 예시

| 상황 | 조합 |
|------|------|
| 일반 기능 개발 | `sisyphus` |
| 병렬 가능한 작업 | `sisyphus + ultrawork` |
| 여러 파일 변경 + 커밋 관리 | `sisyphus + git-master` |
| 프론트엔드 UI 작업 | `sisyphus + frontend-ui-ux` |
| 반드시 완료해야 할 작업 | `sisyphus + ralph-loop` |
| 대규모 병렬 + 완료 보장 | `sisyphus + ultrawork + ralph-loop` |
| 계획부터 시작 | `prometheus → sisyphus` |
| 계획 + 리뷰 + 구현 | `prometheus → momus → sisyphus + ultrawork` |

---

## 자주 묻는 질문

### Q: sisyphus와 ultrawork의 차이는?

| | sisyphus | ultrawork |
|---|---------|-----------|
| **실행 방식** | 순차 실행 | 병렬 실행 |
| **적합한 작업** | 순서가 있는 작업 | 독립적인 작업 |
| **에이전트 수** | 1개 | 여러 개 동시 |
| **비용** | 낮음 | 높음 (에이전트 수만큼) |

### Q: plan과 sisyphus를 같이 쓸 수 있나?

순차적으로 사용한다. **plan으로 계획을 먼저 세우고**, 계획이 확정되면 **sisyphus로 실행**한다.

```
/plan 기능 설계 → /review 리뷰 → /sisyphus 구현
```

### Q: ralph-loop이 무한 루프에 빠지면?

`/cancel-ralph` 명령어로 즉시 중단할 수 있다.

### Q: 에이전트 모델(Opus/Sonnet/Haiku)을 직접 선택할 수 있나?

OMC가 작업 복잡도에 따라 자동으로 선택한다. 일반적으로 수동 지정은 불필요하다.

---

## 참고 문서

- [에이전트 상세 가이드](agents-guide.md) — 12개 에이전트 개별 설명
- [방법론](methodology.md) — 작업 크기별 워크플로우, Skill 선택 흐름도
- [에이전틱 패턴](agentic-patterns.md) — ReAct, Reflection, Multi-Agent 등 디자인 패턴
- [OMC GitHub 저장소](https://github.com/Yeachan-Heo/oh-my-claudecode)
