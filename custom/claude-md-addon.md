## heejuna-engineering 원칙

### 5대 원칙
1. **Human Architect, AI Implementer**: 인간=아키텍처/품질 판단, AI=구현/반복작업
2. **Verify Always, Trust Never**: AI 출력은 반드시 검증 (자동: Quality Gate, 수동: 테스트/리뷰)
3. **Right-Sized Process**: 작업 크기에 맞는 프로세스 (Small->바로, Large->계획->리뷰->구현)
4. **Domain Knowledge as Code**: 암묵지->CLAUDE.md/rules/skills로 명시화
5. **Context is King**: 컨텍스트 윈도우는 가장 소중한 자원, 불필요한 정보 최소화

### Skill 선택 규칙

#### 오케스트레이션 (OMC)
- `sisyphus`: 다단계 작업 실행 + todo 추적
- `ultrawork`: 병렬 에이전트 최대 성능
- `ralph-loop`: 완료까지 멈추지 않음
- `prometheus`: 전략적 계획 수립
- `orchestrator`: 복잡한 작업 조율

#### 방법론 (Superpowers)
- TDD: 테스트 주도 개발 (red->green->refactor)
- systematic-debugging: 체계적 디버깅 (가설->검증)
- verification: 코드 품질 검증

#### 충돌 방지
- Superpowers의 SDD(Spec-Driven Development)는 사용하지 않음 (sisyphus와 충돌)
- 오케스트레이션은 항상 OMC 사용
- 방법론(TDD/디버깅)은 Superpowers 사용

### Quality Gate
- Stop Hook이 자동으로 lint/typecheck 실행
- 에러 발견 시 자동 수정 시도
- `CLAUDE_SKIP_QUALITY_GATE=1`로 비활성화 가능

### 작업 크기별 워크플로우

| 크기 | 기준 | 프로세스 | 도구 |
|------|------|---------|------|
| S | 1줄 변경, 타이포 | 바로 수행 | Edit/Write |
| M | 버그 수정, 간단한 기능 | 분석->구현->검증 | sisyphus |
| L | 새 기능, 리팩토링 | 계획->리뷰->구현->검증 | prometheus+sisyphus |
| XL | 아키텍처 변경 | 풀 프로세스 | 전체 스택 |

### 실전 팁

#### Extended Thinking
- 복잡한 아키텍처 결정이나 까다로운 디버깅에는 `ultrathink` 키워드를 포함하여 Claude가 더 깊이 생각하도록 유도
- 예: "ultrathink: 이 인증 시스템의 보안 취약점을 분석해줘"

#### 컨텍스트 관리
- 하나의 세션에서 하나의 작업만 수행 (단일 목적 대화)
- 컨텍스트 70% 이상 사용 시 HANDOFF.md 작성 후 새 세션 시작
- `/context`로 컨텍스트 사용량 수시 확인

#### 터미널 별칭 (권장)
```bash
alias c='claude'
alias cc='claude --continue'
alias cr='claude --resume'
```
