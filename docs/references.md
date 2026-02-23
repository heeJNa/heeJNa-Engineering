# 주석 달린 레퍼런스

> 각 레퍼런스에 "왜 이것을 참고하는지" 설명을 포함한다.

---

## 방법론

### Agentic Engineering - Addy Osmani

- **URL**: https://addyosmani.com/blog/agentic-engineering/
- **왜 참고하는가**: AI 시대 소프트웨어 엔지니어링의 핵심 인사이트를 제공한다. 특히 "Human Architect, AI Implementer" 원칙은 heejuna-engineering 프레임워크의 설계 철학 그 자체다. 인간이 아키텍처를 설계하고 AI가 구현하는 역할 분리, Context Engineering의 중요성, 에이전트 오케스트레이션의 실전 패턴을 다룬다.
- **핵심 인용**: "The most productive AI-assisted developers aren't the ones who write the most prompts. They're the ones who provide the best context."

---

### The 80% Problem - Addy Osmani

- **URL**: https://addyo.substack.com/p/the-80-problem-in-agentic-coding
- **왜 참고하는가**: AI가 코드의 80%를 해결하지만, 나머지 20%가 소프트웨어의 품질을 결정한다는 현실적인 분석이다. "거의 되는" 코드가 오히려 위험할 수 있다는 경고와 함께, Quality Gate, Writer/Reviewer 패턴 등 검증 메커니즘의 필요성을 뒷받침한다. 우리 프레임워크에서 momus(리뷰), Ralph Loop(완료 보장), Quality Gate Hook(자동 검증)을 도입한 이론적 근거다.
- **핵심 인용**: "The last 20% is where the engineering happens."

---

### Spec-Driven Development - Martin Fowler

- **URL**: https://martinfowler.com/articles/exploring-gen-ai/sdd-3-tools.html
- **왜 참고하는가**: 명세(Specification)를 먼저 작성하고 AI가 구현하는 SDD(Spec-Driven Development) 접근법을 설명한다. 이 방법론에서 "Right-Sized Process" 원칙을 차용했다. 모든 작업에 무거운 프로세스를 적용하는 것이 아니라, 작업 규모에 맞는 적절한 수준의 계획을 세우는 것이 핵심이다. 다만, SDD 자체는 Sisyphus의 Todo 기반 워크플로우와 충돌하므로 방법론 자체는 채택하지 않았다.
- **핵심 인용**: "Not every task needs a specification. The key is to match the process to the problem."

---

### METR Study - AI Experienced Developer Study

- **URL**: https://metr.org/blog/2025-07-10-early-2025-ai-experienced-os-dev-study/
- **왜 참고하는가**: AI를 사용하는 경험 많은 개발자도 AI 없이 작업했을 때보다 19% 느린 결과가 나왔다는 충격적인 연구 결과다. 이것은 AI를 "아무렇게나" 사용하면 오히려 역효과가 난다는 것을 증명한다. 구조화된 워크플로우(계획 -> 구현 -> 검증), 적절한 에이전트 선택, Context Engineering이 왜 필요한지를 설명하는 핵심 근거다. 프레임워크 없는 AI 사용은 생산성을 떨어뜨릴 수 있다.
- **핵심 인용**: "AI-experienced developers took 19% longer on average when using AI tools."

---

### DDD + LLMs - Eric Evans

- **URL**: https://www.infoq.com/news/2024/03/Evans-ddd-experiment-llm/
- **왜 참고하는가**: Domain-Driven Design의 창시자 Eric Evans가 LLM과 DDD의 결합을 실험한 내용이다. AI에게 도메인 지식을 전달하는 방법, Ubiquitous Language를 AI 컨텍스트에 포함시키는 전략 등을 다룬다. 우리 프레임워크에서 CLAUDE.md에 도메인 용어(계약, 정산, 유료DB 등)를 명시하고, MEMORY.md에 학습된 도메인 지식을 축적하는 패턴의 이론적 배경이다.
- **핵심 인용**: "The model inside the LLM needs to align with the model in your domain."

---

## 도구 / 플러그인

### Superpowers

- **URL**: https://github.com/obra/superpowers
- **왜 참고하는가**: TDD(Test-Driven Development), Systematic Debugging, Verification Loop 등 검증된 개발 방법론을 Claude Code에 주입하는 플러그인이다. 특히 TDD 스킬은 AI가 코드를 작성할 때 "테스트 먼저" 습관을 강제하여 품질을 보장한다. Systematic Debugging은 체계적인 문제 해결 과정을 제공한다.
- **주의**: SDD(Spec-Driven Development) 스킬은 Sisyphus와 충돌하므로 사용하지 않는다.

---

### Oh-My-ClaudeCode (OMC)

- **URL**: https://github.com/Yeachan-Heo/oh-my-claudecode
- **왜 참고하는가**: heejuna-engineering 프레임워크의 핵심 인프라다. Sisyphus(Todo 기반 멀티에이전트), Ultrawork(병렬 실행), Ralph Loop(완료 보장), Prometheus(전략적 계획) 등 모든 오케스트레이션 기능을 제공한다. 12개 에이전트의 정의, 모델 티어 배치, Slash 명령어 체계가 여기서 온다.
- **핵심 기능**: 멀티 에이전트 오케스트레이션, Todo 추적, 병렬 실행, 자기참조 완료 루프

---

### Anthropic Official Skills

- **URL**: https://github.com/anthropics/skills
- **왜 참고하는가**: Anthropic이 공식으로 제공하는 스킬 모음으로, 문서 생성(PDF, PPTX, DOCX), 웹앱 테스팅, 프론트엔드 디자인 등을 지원한다. 공식 스킬이므로 Claude Code와의 호환성이 보장되며, 업데이트도 꾸준히 이루어진다.
- **핵심 기능**: 문서 생성, 웹앱 테스트 자동화, 프론트엔드 디자인 가이드

---

### Trail of Bits Skills

- **URL**: https://github.com/trailofbits/skills
- **왜 참고하는가**: 보안 전문 기업 Trail of Bits가 제공하는 보안 관련 스킬이다. SQL 인젝션 방지, 인증/인가 보안, 암호화 관련 가이드를 AI 컨텍스트로 주입한다. v2 백엔드에서 SQL 인젝션을 완전히 제거한 경험과 맞물려, 보안 코딩 습관을 강화하는 데 유용하다.
- **핵심 기능**: 보안 코드 리뷰, 취약점 패턴 감지, 보안 코딩 가이드

---

## 공식 문서

### Claude Code Best Practices

- **URL**: https://docs.anthropic.com/en/docs/claude-code/best-practices
- **왜 참고하는가**: Claude Code를 효과적으로 사용하기 위한 Anthropic의 공식 권장 사항이다. CLAUDE.md 작성법, 프롬프트 최적화, 에이전트 활용 패턴 등 프레임워크 설계의 기반이 되는 공식 가이드라인이다. 특히 "Memory 파일로 학습 축적하기", "프로젝트별 CLAUDE.md 분리" 등의 패턴을 이 문서에서 참고했다.
- **핵심 내용**: CLAUDE.md 구조화, 명령어 문서화, 에이전트 커스터마이징

---

### Claude Code Hooks

- **URL**: https://docs.anthropic.com/en/docs/claude-code/hooks
- **왜 참고하는가**: Hook 시스템은 에이전트의 행동 전후에 자동으로 실행되는 스크립트를 정의한다. Quality Gate(린트/타입체크 자동 실행), Pre-commit 검증, Post-edit 자동 포맷팅 등을 구현하는 데 필수적인 문서다. Writer/Reviewer 패턴의 자동화된 Reviewer 부분이 Hook으로 구현된다.
- **핵심 내용**: PreToolUse, PostToolUse, Notification Hook 등 Hook 유형과 설정 방법

---

### Claude Code Skills

- **URL**: https://docs.anthropic.com/en/docs/claude-code/skills
- **왜 참고하는가**: 커스텀 Skill 작성 방법을 설명하는 공식 가이드다. `/v2-api`, `/wr-component`, `/v2-frontend` 등 프로젝트별 커스텀 스킬을 만드는 데 참고했다. Skill은 특정 작업 유형에 대한 전문 컨텍스트를 제공하며, CLAUDE.md보다 더 세분화된 지침을 담는다.
- **핵심 내용**: Skill 파일 위치 (.claude/skills/), Skill 작성 포맷, 자동 활성화 조건

---

## 2026 트렌드

### 8 Trends in Software Development - Claude Blog

- **URL**: https://www.anthropic.com/research/swe-bench-sonnet
- **왜 참고하는가**: Anthropic이 분석한 2026년 소프트웨어 개발 트렌드를 담고 있다. SWE-bench 결과와 함께, AI가 소프트웨어 개발에 미치는 영향, 멀티 에이전트 시스템의 발전, Context Engineering의 중요성 등을 다룬다. 프레임워크의 방향성을 검증하고 미래 발전 방향을 설정하는 데 참고한다.
- **핵심 트렌드**: 에이전트 자율성 증가, 도구 사용의 표준화(MCP), Context-first 개발

---

### Agentic AI Design Patterns 2026

- **URL**: https://medium.com/@dewasheesh.rana/agentic-ai-design-patterns-2026-ed-e3a5125162c5
- **왜 참고하는가**: 2026년 기준 에이전틱 AI 디자인 패턴을 종합적으로 정리한 글이다. ReAct, Reflection, Planning, Multi-Agent 등 본 프레임워크에서 구현한 7가지 패턴의 이론적 배경과 업계 동향을 확인할 수 있다. 특히 각 패턴의 장단점과 조합 방법에 대한 실용적인 분석이 유용하다.
- **핵심 내용**: 7가지 에이전틱 디자인 패턴 분류, 패턴 조합 전략, 실전 적용 사례

---

## 커뮤니티 자료

### Claude Code 완전 가이드: 70가지 파워 팁

- **저자**: Manus AI (ykdojo + Ado Kukic 기반)
- **왜 참고하는가**: Anthropic 해커톤 우승자 ykdojo와 DevRel Ado Kukic의 실전 경험을 70가지 팁으로 정리한 종합 가이드다. HANDOFF.md 패턴, 컨텍스트 관리 전략, 터미널 별칭, 자동화의 자동화 철학 등 실전에서 바로 적용 가능한 팁이 풍부하다. heejuna-engineering의 quick-reference.md와 컨텍스트 관리 전략의 주요 출처다.
- **핵심 인사이트**: "같은 작업을 3번 이상 반복한다면, 자동화할 방법을 찾아라. 그리고 그 자동화 과정 자체도 자동화하라."

---

### ykdojo/claude-code-tips

- **URL**: https://github.com/ykdojo/claude-code-tips
- **왜 참고하는가**: Anthropic 해커톤 우승자 ykdojo가 43가지 이상의 Claude Code 팁을 정리한 저장소다. 시스템 프롬프트 슬림화, 커스텀 dx 플러그인, HANDOFF.md 생성기 등 고급 사용법이 포함되어 있다. 특히 `/dx:gha`(GitHub Actions 디버깅), `/dx:handoff`(컨텍스트 압축) 등 실용적인 명령어를 제공한다.
- **핵심 기능**: 시스템 프롬프트 패치, 음성 코딩 워크플로우, Reddit Fetch 스킬

---

### Ado's Advent of Claude

- **URL**: https://adocomplete.com/advent-of-claude-2025/
- **왜 참고하는가**: Anthropic DevRel Ado Kukic가 31일간 매일 Claude Code 팁을 공유한 시리즈다. 초급(Day 1-10)부터 고급(Day 21-31)까지 체계적으로 구성되어 있어 학습 로드맵으로 활용하기 좋다. Hooks, Skills, Agents, Headless 모드 등 기능별 심층 가이드를 제공한다.
- **핵심 인용**: "Claude Code의 최고 기능들은 여러분에게 제어권을 줍니다. AI와 함께 일하는 도구이지, AI에게 항복하는 것이 아닙니다."

---

## 레퍼런스 활용 가이드

### 목적별 레퍼런스 분류

| 목적 | 참고할 레퍼런스 |
|------|---------------|
| 프레임워크 철학 이해 | Agentic Engineering, The 80% Problem |
| 실전 패턴 학습 | Agentic AI Design Patterns, DDD + LLMs |
| 도구 설정 | Claude Code Best Practices, Hooks, Skills |
| 플러그인 선택 | Superpowers, OMC, Anthropic Skills |
| 방법론 근거 | METR Study, SDD |
| 트렌드 파악 | 8 Trends, Agentic AI Design Patterns |

### 읽기 순서 추천

**처음 접하는 경우**:

1. Claude Code Best Practices (공식 기본)
2. Agentic Engineering (프레임워크 철학)
3. The 80% Problem (검증의 중요성)
4. OMC GitHub README (도구 사용법)

**깊이 이해하고 싶은 경우**:

5. METR Study (왜 구조화가 필요한지)
6. Agentic AI Design Patterns (패턴 이론)
7. Claude Code Hooks & Skills (커스터마이징)
8. DDD + LLMs (도메인 지식과 AI의 결합)

**최신 트렌드를 추적하고 싶은 경우**:

9. 8 Trends - Claude Blog
10. SDD - Martin Fowler
11. Trail of Bits Skills (보안 트렌드)

---

## 부록: 레퍼런스에서 추출한 핵심 원칙

이 레퍼런스들에서 공통적으로 강조하는 원칙을 정리하면 다음과 같다.

### 1. Context > Prompt

좋은 프롬프트보다 좋은 컨텍스트가 더 중요하다. CLAUDE.md, MEMORY.md, Skills가 이 원칙의 구현체다.

### 2. Verify > Trust

AI의 출력을 믿지 말고 검증하라. Quality Gate, momus review, Ralph Loop이 이 원칙의 구현체다.

### 3. Plan > Code

코드를 바로 작성하기보다 계획을 먼저 세워라. Prometheus, Metis가 이 원칙의 구현체다.

### 4. Specialize > Generalize

하나의 만능 에이전트보다 전문화된 여러 에이전트가 낫다. 12개 에이전트 시스템이 이 원칙의 구현체다.

### 5. Iterate > Perfect

한 번에 완벽하게 만들려 하지 말고 반복적으로 개선하라. ReAct 패턴, Incremental Development가 이 원칙의 구현체다.
