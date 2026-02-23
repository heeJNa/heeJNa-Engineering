# Claude Code 빠른 참조 가이드

> 터미널 옆에 열어두고 바로 찾아 쓰는 치트시트

---

## 필수 명령어

| 명령어 | 설명 |
|--------|------|
| `/init` | 프로젝트 CLAUDE.md 자동 생성 |
| `/usage` | 토큰 사용량 및 한도 확인 |
| `/context` | 컨텍스트 윈도우 사용 현황 |
| `/clear` | 대화 내용 지우기 |
| `/stats` | 사용 통계 및 활동 그래프 |
| `/clone` | 대화 복제 (동일 컨텍스트로 새 세션) |
| `/half-clone` | 대화 반복제 (컨텍스트 절반 줄이기) |
| `/export` | 대화 내역 마크다운으로 내보내기 |
| `/sandbox` | 권한 경계 설정 |
| `/mcp` | MCP 서버 관리 |
| `/permissions` | 승인된 명령어 관리 |
| `/vim` | Vim 모드 활성화 |
| `/release-notes` | 최신 릴리스 노트 확인 |
| `/rename <name>` | 현재 세션 이름 지정 |
| `/help` | 전체 명령어 및 스킬 목록 |

---

## 키보드 단축키

| 단축키 | 기능 |
|--------|------|
| `!command` | Bash 명령어 즉시 실행 (토큰 낭비 없음) |
| `Esc` `Esc` | 대화/코드 되감기 (undo) |
| `Ctrl+R` | 역방향 검색 (명령어 히스토리) |
| `Ctrl+S` | 프롬프트 임시 저장 |
| `Shift+Tab` (×2) | Plan 모드 토글 |
| `Alt+P` / `Option+P` | 모델 전환 (Opus ↔ Sonnet) |
| `Ctrl+O` | Verbose 모드 토글 |
| `Tab` / `Enter` | 프롬프트 제안 수락 |
| `Ctrl+B` | 실행 중인 작업을 백그라운드로 보내기 |
| `Ctrl+G` | 외부 에디터로 프롬프트 편집 |

### `!` prefix 활용

프롬프트 앞에 `!`를 붙이면 Claude를 거치지 않고 바로 셸 명령어를 실행한다. 간단한 확인 작업에 토큰을 낭비하지 않는 핵심 팁이다.

```bash
!git status          # 바로 실행, 토큰 소비 없음
!ls src/components   # 파일 목록 빠르게 확인
!npm test            # 테스트 바로 실행
```

---

## CLI 플래그

| 플래그 | 설명 |
|--------|------|
| `-p "prompt"` | Headless 모드 (비대화형 실행) |
| `--continue` | 마지막 세션 이어가기 |
| `--resume` | 세션 목록에서 선택 |
| `--resume <name>` | 이름으로 세션 재개 |
| `--chrome` | Chrome 통합 모드 |

---

## 터미널 별칭 (권장)

`~/.zshrc` 또는 `~/.bashrc`에 추가:

```bash
# Claude Code 빠른 실행
alias c='claude'                      # 기본 실행
alias cc='claude --continue'          # 마지막 세션 이어가기
alias cr='claude --resume'            # 세션 목록에서 선택
alias cs='claude -p'                  # Headless 모드 (스크립트용)

# 실용적인 조합
alias cstatus='claude -p "git status를 확인하고 변경 사항을 요약해줘"'
alias creview='claude -p "최근 커밋을 리뷰해줘"'
```

---

## Extended Thinking (깊은 사고)

복잡한 아키텍처 결정이나 까다로운 디버깅에 Claude가 더 깊이 생각하도록 요청한다.

```
ultrathink: 이 아키텍처 결정의 장단점을 깊이 분석해줘
```

`ultrathink` 키워드를 포함하면 Claude가 응답 전 최대 32k 토큰을 내부 추론에 할당한다.

---

## 대화 관리

### 세션 이름 지정
```
/rename auth-refactor    # 현재 세션에 이름 부여
```

### 과거 대화 재개
```bash
claude --resume                   # 세션 목록에서 선택
claude --resume auth-refactor     # 이름으로 바로 재개
claude --continue                 # 가장 최근 세션 이어가기
```

### 컨텍스트 신선도 관리

```
컨텍스트 < 50%  →  계속 작업
컨텍스트 50-70% →  불필요한 내용 정리 고려
컨텍스트 70-85% →  HANDOFF.md 작성 준비
컨텍스트 > 85%  →  HANDOFF.md 작성 후 새 세션 시작
```

---

## heejuna-engineering Skill 명령어

| 명령어 | 용도 |
|--------|------|
| `/sisyphus <task>` | 멀티에이전트 오케스트레이션 |
| `/ultrawork <task>` | 병렬 에이전트 최대 성능 |
| `/plan <task>` | 전략적 계획 수립 (Prometheus) |
| `/review [path]` | 계획 리뷰 (Momus) |
| `/ralph-loop <task>` | 완료까지 멈추지 않는 루프 |
| `/deepsearch <query>` | 코드베이스 심층 검색 |
| `/analyze <target>` | 깊은 분석 및 조사 |

---

## 자동화 레벨

반복 작업을 발견하면 단계적으로 자동화 수준을 높인다.

```
Level 0: 매번 수동으로 프롬프트 입력
Level 1: CLAUDE.md에 규칙 추가 (자동 참조)
Level 2: Slash Command 생성 (수동 호출)
Level 3: Skill 생성 (Claude 자동 호출)
Level 4: Hook 설정 (이벤트 기반 자동 실행)
Level 5: CI/CD 통합 (파이프라인 자동화)
```

> "같은 작업을 3번 이상 반복한다면, 자동화할 방법을 찾아라." — ykdojo

---

## 참고

- 전체 방법론: [methodology.md](methodology.md)
- 에이전트 가이드: [agents-guide.md](agents-guide.md)
- 플러그인 설치: [plugin-guide.md](plugin-guide.md)
- 디자인 패턴: [agentic-patterns.md](agentic-patterns.md)
