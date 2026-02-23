# Heejuna Engineering Framework

**A structured AI-agent development framework that turns AI coding assistants from "19% slower" into measurably productive teammates.** Built on lessons from METR's 2025 study, Anthropic's best practices, and real-world production experience, this framework provides opinionated workflows, project templates, and quality gates for Claude Code and similar AI agents.

---

## 목차

- [한눈에 이해하기 (비개발자용)](#한눈에-이해하기-비개발자용)
- [왜 이 프레임워크가 필요한가](#왜-이-프레임워크가-필요한가)
- [5대 원칙](#5대-원칙)
- [Hybrid Approach 전략](#hybrid-approach-전략)
- [퀵스타트](#퀵스타트)
- [디렉토리 구조](#디렉토리-구조)
- [프로젝트 템플릿](#프로젝트-템플릿)
- [상세 문서](#상세-문서)
- [검증 방법](#검증-방법)
- [라이선스](#라이선스)
- [출처](#출처)

---

## 한눈에 이해하기 (비개발자용)

### 한 줄 요약

> **AI 코딩 도우미(Claude Code)가 실수를 줄이고 더 잘 일하게 만들어주는 "작업 매뉴얼 + 자동 검사 도구"**

### 비유로 이해하기

회사에 새로운 직원(AI)이 들어왔다고 생각해보자.

**이 프레임워크가 없을 때:**
- 신입(AI)에게 "이거 해줘"라고만 말함
- 신입은 회사 규칙도 모르고, 어떤 스타일로 일하는지도 모름
- 결과물을 받아보면 수정할 게 너무 많음
- **오히려 직접 하는 것보다 느려짐** (실제 연구에서 19% 더 느려졌다고 함)

**이 프레임워크를 쓸 때:**
- 신입(AI)에게 **업무 매뉴얼**(CLAUDE.md)을 줌 → "우리 회사는 이렇게 일해"
- **부서별 규칙**(Rules)도 줌 → "이 폴더 작업할 땐 이 규칙을 따라"
- 일을 끝내면 **자동 검수**(Quality Gate)를 돌림 → "오류 있으면 통과 못 함"
- 복잡한 일은 **팀장(오케스트레이터)**이 나눠서 여러 전문가에게 동시에 시킴

### 주요 구성 요소

| 요소 | 비유 | 하는 일 |
|------|------|---------|
| **CLAUDE.md** | 업무 매뉴얼 | "우리 프로젝트는 이런 구조고, 이런 규칙이 있어" |
| **Rules** | 부서별 가이드 | "이 폴더 파일을 건드릴 땐 이 규칙을 따라" |
| **Quality Gate Hook** | 품질 검수관 | 코드 저장 전에 자동으로 오류 검사 |
| **Templates** | 신입 온보딩 키트 | Nuxt4, Vue3, FastAPI 등 프로젝트별 세팅 패키지 |
| **OMC** | 팀장 + 전문가 팀 | 복잡한 작업을 여러 AI 에이전트가 분담하여 처리 |
| **Superpowers** | 업무 방법론 교육 | TDD, 체계적 디버깅 등 검증된 개발 방법론 주입 |

### 핵심 철학 (5대 원칙을 쉽게)

1. **사람이 설계하고, AI가 만든다** — AI한테 "알아서 해"가 아니라 "이렇게 해"라고 지시
2. **항상 검증한다** — AI 결과물을 그냥 믿지 말고 자동으로 체크
3. **과하지 않게** — 팀 규모에 맞는 적절한 프로세스만
4. **지식을 파일로 남긴다** — 머릿속 노하우를 AI가 읽을 수 있는 파일로 저장
5. **맥락이 전부다** — AI에게 충분한 배경 정보를 주면 결과가 좋아진다

---

## 왜 이 프레임워크가 필요한가

2025년 1월, AI 평가 기관 METR은 충격적인 연구 결과를 발표했다.

> **"숙련된 오픈소스 개발자가 AI 도구를 사용했을 때, 오히려 작업 완료 시간이 19% 증가했다."**
> -- METR, "Measuring the Impact of Early LLM-Based Tools on Software Developers" (2025)

원인은 명확하다. AI가 생성한 코드를 검증하고, 잘못된 출력을 수정하고, 프롬프트를 반복 조정하는 데 드는 **오버헤드**가 생산성 향상분을 초과한 것이다. 도구 자체의 문제가 아니라 **워크플로우의 부재**가 문제였다.

Heejuna Engineering Framework는 이 문제를 정면으로 해결한다.

| 문제 | 원인 | 해결 |
|------|------|------|
| AI가 엉뚱한 방향으로 구현 | 컨텍스트 부족 | CLAUDE.md + Project Rules로 도메인 지식 주입 |
| 생성 코드 품질 불안정 | 검증 미흡 | Quality Gate Hook으로 자동 검증 |
| 프롬프트 반복 조정 | 구조화된 지시 부재 | Skills + Agents 패턴으로 재사용 가능한 워크플로우 |
| AI 의존도 과잉 | 역할 분담 불명확 | Human Architect / AI Implementer 원칙 |

---

## 5대 원칙

이 프레임워크의 모든 설계 결정은 아래 5가지 원칙에 기반한다.

| # | 원칙 | 출처 | 핵심 내용 |
|---|------|------|-----------|
| 1 | **Human Architect, AI Implementer** | Addy Osmani | 인간은 설계하고 AI는 구현한다. 아키텍처 결정권은 반드시 인간에게 있다. |
| 2 | **Verify Always, Trust Never** | Superpowers + METR | AI 출력은 항상 검증한다. 자동화된 Quality Gate가 신뢰를 대체한다. |
| 3 | **Right-Sized Process** | Martin Fowler | 프로세스는 팀과 프로젝트 규모에 맞게 조절한다. 과잉 프로세스는 생산성의 적이다. |
| 4 | **Domain Knowledge as Code** | DDD (Eric Evans) | 도메인 지식을 CLAUDE.md, Rules, Memory에 코드화하여 AI에 주입한다. |
| 5 | **Context is King** | Anthropic Best Practices | AI의 성능은 제공하는 컨텍스트의 품질에 비례한다. 구조화된 컨텍스트가 핵심이다. |

### 원칙 간 관계

```
[5. Context is King] ─── 컨텍스트를 구조화하여 ──→ [4. Domain Knowledge as Code]
         │                                                      │
         │                                                      ▼
         │                                          CLAUDE.md / Rules / Memory
         │                                                      │
         ▼                                                      ▼
[1. Human Architect] ─── 설계를 AI에 전달 ──→ [AI Implementer가 구현]
                                                                │
                                                                ▼
                                              [2. Verify Always] ─── Quality Gate
                                                                │
                                                                ▼
                                              [3. Right-Sized Process] ─── 팀에 맞게 조절
```

---

## Hybrid Approach 전략

이 프레임워크는 단일 방법론이 아니라, 검증된 여러 접근법을 **역할별로 조합**한 하이브리드 전략이다.

| 역할 | 접근법 | 출처 | 설명 |
|------|--------|------|------|
| **오케스트레이션** | Oh-My-ClaudeCode (OMC) | Sisyphus System | 다중 에이전트 계층 구조. 복잡한 작업을 분할-위임-통합한다. |
| **방법론** | Superpowers | obra (Jesse Vincent) | TDD, Systematic Debugging, Verification Loop 등 검증된 개발 방법론. |
| **도구** | Skills + Agents | Anthropic | 재사용 가능한 워크플로우(Skills)와 전문화된 에이전트(Agents) 패턴. |
| **품질 보증** | Quality Gate Hook | Custom | pre-commit 스타일 자동 검증. lint, typecheck, test를 커밋 전 강제 실행. |
| **철학** | CLAUDE.md | Anthropic Convention | 프로젝트의 맥락, 규칙, 패턴을 하나의 파일에 집약하여 AI에 주입. |
| **도메인** | Project Rules | Claude Code | 파일 패턴 기반 규칙 자동 적용. 특정 디렉토리/파일에 맞는 지시를 자동 로드. |

### 왜 하이브리드인가?

각 접근법은 단독으로도 가치가 있지만, 조합할 때 시너지가 극대화된다.

- **CLAUDE.md** 없는 Skills는 컨텍스트가 부족하고
- **Quality Gate** 없는 에이전트는 검증이 불가능하며
- **OMC** 없는 복잡한 작업은 에이전트가 길을 잃는다

이 프레임워크는 이들을 하나의 일관된 워크플로우로 통합한다.

---

## 퀵스타트

### 사전 요구사항

- [Claude Code](https://claude.ai/code) CLI 설치 완료
- macOS 또는 Linux (Windows WSL 지원)
- Git, Bash 4.0+

### 5분 설치

**1단계: 저장소 클론**

```bash
git clone https://github.com/heejuna/heejuna-engineering.git
cd heejuna-engineering
```

**2단계: 글로벌 설치**

```bash
# ~/.claude/에 Quality Gate Hook + CLAUDE.md 보강 + settings.json 등록
./install.sh
```

**3단계: 프로젝트에 템플릿 적용 (선택)**

```bash
# 프로젝트별 hooks + rules 적용
./install.sh /path/to/your/project --template nuxt4
./install.sh /path/to/your/project --template vue3
./install.sh /path/to/your/project --template fastapi
./install.sh /path/to/your/project --template general
```

`install.sh`가 수행하는 작업:
- **글로벌**: `~/.claude/hooks/quality-gate.sh` 설치, `CLAUDE.md` 보강, `settings.json`에 Hook 등록
- **프로젝트**: `.claude/hooks/`, `.claude/rules/` 에 템플릿별 파일 복사, 프로젝트 `settings.json` 생성

**4단계: 플러그인 설치 (선택)**

```bash
# 추천 플러그인 설치 가이드 확인
./install-plugins.sh
```

**5단계: 확인**

```bash
# 글로벌 설치 확인
ls ~/.claude/hooks/quality-gate.sh

# 프로젝트 설치 확인 (템플릿 적용한 경우)
ls /path/to/your/project/.claude/
```

### 제거

```bash
# 글로벌 설정 제거
./uninstall.sh
```

---

## 디렉토리 구조

```
heejuna-engineering/
├── README.md                          # 이 문서
├── install.sh                         # 프로젝트 설치 스크립트
├── install-plugins.sh                 # 플러그인 (Skills/Agents) 설치
├── uninstall.sh                       # 제거 스크립트
│
├── docs/                              # 프레임워크 문서
│   ├── philosophy.md                  #   5대 원칙 상세 설명
│   ├── methodology.md                 #   Hybrid Approach 방법론
│   ├── agentic-patterns.md            #   에이전트 패턴 (OMC, Skills, Agents)
│   ├── omc-guide.md                   #   OMC (Oh-My-ClaudeCode) 상세 사용 설명서
│   ├── superpowers-guide.md           #   Superpowers 상세 사용 설명서
│   ├── rules-guide.md                 #   Rules 시스템 사용 설명서
│   ├── plugin-guide.md                #   플러그인 설치 가이드
│   ├── agents-guide.md                #   12개 에이전트 상세 가이드
│   ├── quick-reference.md             #   명령어/단축키/CLI 빠른 참조 가이드
│   ├── audit-report.md                #   Anthropic 공식 문서 기준 감사 보고서
│   └── references.md                  #   참고 문헌 및 연구 링크
│
├── custom/                            # 커스텀 확장
│   ├── hooks/                         #   Quality Gate Hook 스크립트
│   │   └── quality-gate.sh            #     lint + typecheck + test 자동 실행
│   ├── claude-md-addon.md             #   CLAUDE.md에 병합할 추가 규칙
│   └── settings-addon.json            #   Claude Code 설정 확장
│
├── project-templates/                 # 프로젝트 유형별 템플릿
│   ├── nuxt4/                         #   Nuxt 4 (레이어, SSR, auto-import)
│   │   └── .claude/                   #     hooks, rules 프리셋
│   ├── vue3/                          #   Vue 3 (Router, Pinia, vue-tsc)
│   │   └── .claude/                   #     hooks, rules 프리셋
│   ├── fastapi/                       #   FastAPI + PostgreSQL
│   │   └── .claude/                   #     hooks, rules 프리셋
│   └── general/                       #   범용 프로젝트
│       └── .claude/                   #     hooks 프리셋
│
└── examples/                          # 실제 적용 사례
    └── wportal/                       #   WPortal ERP 시스템 적용 예시
        └── .claude/
            └── rules/                 #     프로젝트 규칙 예시
```

---

## 프로젝트 템플릿

프로젝트 유형에 따라 최적화된 CLAUDE.md와 규칙 세트를 제공한다.

### `nuxt4`

Nuxt 4 기반 프로젝트용. 레이어 아키텍처, SSR, auto-import 등 Nuxt 고유 기능에 최적화.

| 포함 항목 | 설명 |
|-----------|------|
| Rules | 레이어 구조, auto-import, 데이터 패칭 (useAsyncData/useFetch), 미들웨어/플러그인 |
| Hooks | ESLint + `nuxi typecheck` |

```bash
./install.sh /path/to/project --template nuxt4
```

### `vue3`

Nuxt 없이 Vue 3 + TypeScript로 구성된 프로젝트용. Vue Router, Pinia 패턴 포함.

| 포함 항목 | 설명 |
|-----------|------|
| Rules | Composition API, Vue Router, Pinia, 컴포넌트 패턴 |
| Hooks | ESLint + `vue-tsc` |

```bash
./install.sh /path/to/project --template vue3
```

### `fastapi`

FastAPI + PostgreSQL 기반 백엔드 프로젝트용.

| 포함 항목 | 설명 |
|-----------|------|
| CLAUDE.md | 3계층 구조 (router/service/repository), SQL 안전성 규칙 |
| Rules | API 엔드포인트 규칙, DB 마이그레이션 규칙, 테스트 규칙 |
| Hooks | Ruff lint + pytest + Pyright typecheck |
| Skills | v2 API 생성, 마이그레이션 생성 워크플로우 |

```bash
./install.sh /path/to/project --template fastapi
```

### `general`

특정 스택에 종속되지 않는 범용 템플릿.

| 포함 항목 | 설명 |
|-----------|------|
| CLAUDE.md | 프로젝트 개요, 코딩 표준, 디렉토리 구조 뼈대 |
| Hooks | 기본 Quality Gate (커스터마이즈 필요) |

```bash
./install.sh /path/to/project --template general
```

---

## 상세 문서

프레임워크의 각 구성 요소에 대한 자세한 사용 설명서다.

### 핵심 도구 가이드

| 문서 | 내용 | 대상 |
|------|------|------|
| [OMC 사용 설명서](docs/omc-guide.md) | Oh-My-ClaudeCode 전체 명령어, 12개 에이전트, Skill 조합, 워크플로우 예시 | 멀티 에이전트 활용법을 배우고 싶은 사용자 |
| [Superpowers 사용 설명서](docs/superpowers-guide.md) | TDD, 체계적 디버깅, 검증 루프, 점진적 개발 방법론 상세 | 개발 방법론을 이해하고 싶은 사용자 |
| [Rules 시스템 가이드](docs/rules-guide.md) | Rules 작성법, paths 프론트매터, 실제 예시, 커스터마이징 | 프로젝트별 규칙을 설정하고 싶은 사용자 |

### 심화 문서

| 문서 | 내용 |
|------|------|
| [5대 원칙 상세](docs/philosophy.md) | Human Architect, Verify Always 등 5대 원칙의 이론적 배경 |
| [방법론](docs/methodology.md) | 작업 크기별(S/M/L/XL) 워크플로우, Skill 선택 흐름도 |
| [에이전틱 패턴](docs/agentic-patterns.md) | ReAct, Reflection, Multi-Agent 등 9가지 디자인 패턴 |
| [12개 에이전트 가이드](docs/agents-guide.md) | 각 에이전트의 역할, 모델, 비용, 조합 패턴 |
| [플러그인 설치 가이드](docs/plugin-guide.md) | 필수/추천/선택 플러그인 설치 방법 |
| [빠른 참조](docs/quick-reference.md) | 명령어, 단축키, CLI 플래그 치트시트 |
| [감사 보고서](docs/audit-report.md) | Anthropic 공식 문서 기준 검토 결과 |
| [레퍼런스](docs/references.md) | 참고 문헌, 연구 논문, 읽기 순서 추천 |

### 읽기 순서 추천

**처음 접하는 사용자:**
1. [OMC 사용 설명서](docs/omc-guide.md) — 핵심 도구 사용법
2. [Superpowers 사용 설명서](docs/superpowers-guide.md) — 개발 방법론
3. [Rules 시스템 가이드](docs/rules-guide.md) — 프로젝트 규칙 설정

**깊이 이해하고 싶은 사용자:**
4. [5대 원칙](docs/philosophy.md) → [방법론](docs/methodology.md) → [에이전틱 패턴](docs/agentic-patterns.md)

---

## 검증 방법

프레임워크 도입 효과를 측정하기 위한 테스트 시나리오.

### 정량적 검증

| 시나리오 | 측정 지표 | 기대 결과 |
|----------|-----------|-----------|
| 신규 API 엔드포인트 생성 | 완료 시간, 재작업 횟수 | 프레임워크 적용 시 재작업 50% 감소 |
| 기존 코드 리팩토링 | 버그 발생률, 테스트 커버리지 | Quality Gate로 리팩토링 후 버그 0건 |
| 다중 파일 변경 | 에이전트 컨텍스트 유지율 | CLAUDE.md로 컨텍스트 손실 방지 |
| 새 팀원 온보딩 | 첫 PR까지 소요 시간 | 템플릿으로 환경 구성 시간 80% 단축 |

### 정성적 검증

| 시나리오 | 확인 항목 | 검증 방법 |
|----------|-----------|-----------|
| AI 출력 일관성 | 코딩 스타일, 패턴 준수 | Rules 적용 전후 코드 리뷰 비교 |
| 도메인 지식 반영 | 비즈니스 로직 정확도 | CLAUDE.md 도메인 섹션 유무에 따른 정확도 비교 |
| 에이전트 자율성 | 사람 개입 빈도 | Skills 사용 시 프롬프트 수정 횟수 감소 확인 |
| 품질 게이트 효과 | 커밋 전 오류 차단율 | Hook 없는 프로젝트 대비 배포 후 버그 비교 |

### A/B 테스트 권장 방식

```
1. 동일한 작업을 두 환경에서 수행
   - A: 프레임워크 미적용 (vanilla Claude Code)
   - B: 프레임워크 적용 (Heejuna Engineering)

2. 측정 항목
   - 작업 완료 시간
   - 사람 개입 횟수 (프롬프트 수정, 코드 수동 편집)
   - 최종 코드 품질 (lint 오류, 타입 오류, 테스트 실패)

3. 최소 5개 작업에 대해 반복 측정
```

---

## 라이선스

MIT License

Copyright (c) 2026 heejuna

이 프레임워크는 자유롭게 사용, 수정, 배포할 수 있다. 상업적 사용을 포함한 모든 용도에 제한이 없다. 자세한 내용은 [LICENSE](LICENSE) 파일을 참고한다.

---

## 출처

이 프레임워크는 다음 연구와 저작물에 기반한다.

### 연구 논문

- **METR (2025)** - [AI Experienced Developer Study](https://metr.org/blog/2025-07-10-early-2025-ai-experienced-os-dev-study/) - AI 도구 사용 시 19% 생산성 저하 현상 분석

### 방법론 및 프레임워크

- **Addy Osmani** - [Agentic Engineering](https://addyosmani.com/blog/agentic-engineering/) - Human Architect / AI Implementer 원칙
- **obra (Jesse Vincent)** - [Superpowers](https://github.com/obra/superpowers) - TDD, Systematic Debugging, Verification Loop
- **Martin Fowler** - [Spec-Driven Development](https://martinfowler.com/articles/exploring-gen-ai/sdd-3-tools.html) - Right-Sized Process 원칙
- **Eric Evans** - [DDD + LLMs](https://www.infoq.com/news/2024/03/Evans-ddd-experiment-llm/) - 도메인 지식의 코드화

### AI 에이전트 가이드

- **Anthropic** - [Claude Code Best Practices](https://docs.anthropic.com/en/docs/claude-code/best-practices) - CLAUDE.md, Skills, Agents, Hooks
- **Anthropic** - [Building Effective Agents](https://www.anthropic.com/engineering/building-effective-agents) - 에이전트 아키텍처 패턴

### 에이전트 오케스트레이션

- **Sisyphus Multi-Agent System** - OMC 패턴, 다중 에이전트 오케스트레이션 설계

---

> *"The boulder never stops until it reaches the summit."*
>
> 이 프레임워크는 AI와 인간이 함께 일하는 방식에 대한 하나의 제안이다. 완벽하지 않지만, METR 연구가 보여준 문제에 대한 실용적인 답을 제시한다. 피드백과 기여를 환영한다.
