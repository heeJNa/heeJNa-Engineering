# Anthropic 공식 문서 기준 감사 보고서

**감사 대상**: heejuna-engineering 프레임워크 전체
**기준 문서**: Anthropic Claude Code 공식 문서 (code.claude.com/docs)
**감사 일자**: 2026-02-23

---

## 요약

Anthropic 공식 Claude Code 문서를 기준으로 프로젝트 전체를 검토한 결과, **7개 Critical/High 이슈**와 **8개 Medium/Low 이슈**를 발견했습니다. 모든 Critical/High 이슈는 이번 감사에서 수정 완료했습니다.

| 심각도 | 발견 수 | 수정 완료 | 잔여 |
|--------|---------|-----------|------|
| Critical | 2 | 2 | 0 |
| High | 5 | 5 | 0 |
| Medium | 5 | 3 | 2 |
| Low | 3 | 1 | 2 |
| Info | 4 | - | 4 |

---

## Critical 이슈

### C-1. Stop Hook 무한 루프 위험 (수정 완료)

**영향 파일**: 모든 `quality-gate.sh` (4개)
**Anthropic 문서**: Hooks Reference > Stop Event

**문제**: Stop 훅이 stdin에서 `stop_hook_active` 불리언을 확인하지 않았습니다. Anthropic 문서는 다음과 같이 명시합니다:

> "For Stop hooks that run forever, check `stop_hook_active` in the JSON input and exit 0 if true to prevent infinite loops."

Quality Gate가 에러를 발견하고 exit 2를 반환하면, Claude가 수정을 시도하고 다시 Stop하면 Quality Gate가 재실행됩니다. `stop_hook_active`가 true인 경우(이전 Stop 훅 결과로 인한 재실행) 건너뛰어야 합니다.

**수정**: 모든 quality-gate.sh 스크립트 상단에 다음 가드 추가:

```bash
if command -v jq &>/dev/null; then
  HOOK_INPUT=$(cat)
  if [ "$(echo "$HOOK_INPUT" | jq -r '.stop_hook_active // false')" = "true" ]; then
    exit 0
  fi
else
  cat > /dev/null
fi
```

### C-2. Hook command 필드에 "bash" 접두사 사용 (수정 완료)

**영향 파일**: `install.sh`, `custom/settings-addon.json`, 모든 template README.md
**Anthropic 문서**: Hooks Reference > Hook Handler Types

**문제**: 모든 settings.json 설정에서 `"command": "bash ~/.claude/hooks/quality-gate.sh"` 형태로 `bash` 접두사를 사용했습니다. Anthropic 공식 문서의 command 필드는 **raw shell command string**이며, 스크립트에 shebang(`#!/bin/bash`)이 있고 `chmod +x`로 실행 권한이 있으면 `bash` 접두사가 불필요합니다.

**Anthropic 공식 예시**:
```json
{
  "type": "command",
  "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/script.sh"
}
```

**수정**: 모든 command 필드에서 "bash " 접두사 제거:
- 글로벌: `"command": "~/.claude/hooks/quality-gate.sh"`
- 프로젝트: `"command": ".claude/hooks/quality-gate.sh"`

---

## High 이슈

### H-1. Stop 이벤트에 불필요한 matcher 필드 (수정 완료)

**영향 파일**: `install.sh`, `custom/settings-addon.json`
**Anthropic 문서**: Hooks Reference > Matcher Patterns by Event

**문제**: Stop 훅 설정에 `"matcher": ""`를 포함했습니다. Anthropic 문서에 따르면 Stop, UserPromptSubmit, TeammateIdle, TaskCompleted 이벤트는 **matcher를 지원하지 않으며 항상 실행**됩니다. 빈 matcher는 무시되지만 혼란을 유발합니다.

**수정**: 모든 Stop 훅 설정에서 `"matcher": ""` 필드 제거.

### H-2. domain-verify 플러그인에 hooks.json 누락 (수정 완료)

**영향 파일**: `plugins/domain-verify/`
**Anthropic 문서**: Plugins Reference > hooks.json Format

**문제**: 플러그인의 PostToolUse 훅이 `hooks/hooks.json`에 등록되지 않았습니다. Anthropic 플러그인 사양에 따르면 플러그인의 훅은 반드시 `hooks/hooks.json`(또는 plugin.json에서 지정한 경로)에 선언되어야 Claude Code가 자동으로 로드합니다.

**수정**: `plugins/domain-verify/hooks/hooks.json` 생성 및 `plugin.json`에 `"hooks"` 필드 추가.

### H-3. domain-verify plugin.json에 hooks 참조 누락 (수정 완료)

**영향 파일**: `plugins/domain-verify/.claude-plugin/plugin.json`
**Anthropic 문서**: Plugins Reference > plugin.json Schema

**문제**: plugin.json에 `"hooks"` 필드가 없어 hooks.json이 자동 발견되지 않을 수 있습니다.

**수정**: `"hooks": "./hooks/hooks.json"` 추가.

### H-4. Skills 디렉토리에 SKILL.md 엔트리포인트 누락 (수정 완료)

**영향 파일**: `plugins/domain-verify/skills/verify/`
**Anthropic 문서**: Skills Specification

**문제**: Anthropic 공식 스킬 형식은 `skills/<name>/SKILL.md`를 엔트리포인트로 요구합니다. `verify` 스킬 디렉토리에는 `_template.md`와 개별 도메인 .md 파일만 있었고 `SKILL.md`가 없었습니다.

**Anthropic 공식 형식**:
```
skills/
└── verify/
    ├── SKILL.md           # Required entrypoint
    ├── api-router.md      # Supporting file
    └── api-service.md     # Supporting file
```

**수정**: `skills/verify/SKILL.md` 생성. YAML frontmatter(name, description, user-invocable)와 지원 도메인 목록, @import 참조 포함.

### H-5. nuxt-monorepo 템플릿이 Nuxt/Vue 콘텐츠를 혼합 (수정 완료)

**영향 파일**: `project-templates/nuxt-monorepo/`
**원칙**: Right-Sized Process, Context is King

**문제**: 하나의 템플릿에 Nuxt 4 고유 패턴(레이어 아키텍처, useAsyncData, nuxi typecheck)과 범용 Vue 3 패턴(Composition API, TypeScript, 반응형 디자인)이 혼재되어 있었습니다.

- Vue 3 + Vite 프로젝트에는 불필요한 Nuxt 규칙이 포함
- Nuxt 프로젝트에는 Vue Router/Pinia 패턴이 불필요 (Nuxt가 자체 관리)

**수정**: `nuxt4`와 `vue3` 두 개의 독립 템플릿으로 분리:
- **nuxt4**: 레이어, auto-import, useAsyncData/useFetch, nuxi typecheck, 미들웨어/플러그인
- **vue3**: Vue Router, Pinia, vue-tsc, 일반 Composition API 패턴

---

## Medium 이슈

### M-1. CLAUDE.md addon 콘텐츠가 과도하게 길다 (미수정 - 검토 권장)

**영향 파일**: `custom/claude-md-addon.md`
**Anthropic 문서**: Best Practices > CLAUDE.md

**문제**: Anthropic 공식 모범 사례는 다음과 같이 경고합니다:

> "Bloated CLAUDE.md files cause Claude to ignore your actual instructions."
> "The test for each line: 'Would removing this cause Claude to make mistakes?' If not, cut it."

현재 addon은 60줄이며, Skill 선택 규칙 테이블, 작업 크기별 워크플로우 테이블, 터미널 별칭 등을 포함합니다. 이 중 일부(특히 Skill 선택 규칙)는 OMC 시스템의 CLAUDE.md에서 이미 다루고 있어 중복됩니다.

**권장**: 핵심 원칙(5대 원칙 요약)과 Quality Gate 설명만 남기고, Skill 선택/워크플로우 테이블은 별도 rules 파일이나 스킬로 이동.

### M-2. Rules 파일에 paths 프론트매터 미사용 (미수정 - 선택 사항)

**영향 파일**: 모든 `.claude/rules/*.md` 파일
**Anthropic 문서**: Memory > Path-Scoped Rules

**문제**: Anthropic은 `.claude/rules/` 파일에 YAML frontmatter `paths:` 필드를 지원하여 특정 파일 패턴에서만 규칙을 로드할 수 있습니다:

```markdown
---
paths:
  - "src/api/**/*.ts"
---
```

현재 모든 rules 파일이 무조건 로드되고 있습니다. SQL 안전성 규칙(Python에만 해당)이 Vue 파일 작업 시에도 로드되는 비효율이 있습니다.

**권장 예시**:
- `sql-safety.md` → `paths: ["**/*.py"]`
- `vue-patterns.md` → `paths: ["**/*.vue", "**/*.ts"]`

### M-3. domain-verify.sh에서 $CLAUDE_PLUGIN_ROOT 미사용 (수정 완료)

**영향 파일**: `plugins/domain-verify/hooks/hooks.json`
**Anthropic 문서**: Plugins Reference > Environment Variables

**문제**: 플러그인 스크립트 경로에는 `${CLAUDE_PLUGIN_ROOT}` 환경 변수를 사용해야 합니다. 플러그인이 마켓플레이스를 통해 설치되면 `~/.claude/plugins/cache/`에 복사되므로, 상대 경로가 깨질 수 있습니다.

**수정**: `hooks.json`에서 `"command": "${CLAUDE_PLUGIN_ROOT}/hooks/domain-verify.sh"` 사용.

### M-4. template README에 잘못된 settings.json 예시 (수정 완료)

**영향 파일**: 모든 template README.md
**문제**: README의 설정 예시가 `"bash .claude/hooks/..."` 패턴과 `"matcher": ""` 를 포함.

**수정**: nuxt4, vue3 README에는 올바른 예시 사용. fastapi/general README 업데이트.

### M-5. settings-addon.json에 비표준 `_comment` 필드 (수정 완료)

**영향 파일**: `custom/settings-addon.json`
**Anthropic 문서**: Settings Schema

**문제**: `_comment` 필드는 Anthropic settings.json 스키마에 정의되지 않은 필드입니다. 무시되지만 비표준입니다.

**수정**: `_comment` 필드 제거.

---

## Low 이슈

### L-1. domain-agents 플러그인이 비어있음 (미수정)

**영향**: `plugins/domain-agents/`
**상태**: plugin.json만 존재하고 실제 agents 파일이 없음. 플래이스홀더로 남겨두되, README나 install-plugins.sh에서 참조하지 않도록 주의.

### L-2. install-plugins.sh가 존재하지 않는 플러그인 참조 (미수정)

**영향**: `install-plugins.sh`
**문제**: 14개 플러그인을 나열하지만 실제로 존재하는 것은 domain-verify와 domain-agents(비어있음) 뿐. 가이드 문서이므로 치명적이지 않으나, 실제 설치 가능한 것과 예정인 것을 구분하면 좋겠음.

### L-3. settings.json에 $schema 참조 없음 (미수정)

**영향**: 모든 settings.json 설정
**Anthropic 문서**: Settings Schema
**문제**: `"$schema": "https://json.schemastore.org/claude-code-settings.json"` 추가로 IDE 자동완성/검증 가능.

---

## 정보성 항목 (Info)

### I-1. prompt/agent 타입 훅 미활용

Anthropic은 세 가지 훅 타입을 지원합니다:
- `"type": "command"` - 쉘 스크립트 (현재 사용 중)
- `"type": "prompt"` - LLM이 판단 (Haiku 기본)
- `"type": "agent"` - 멀티턴 에이전트 (도구 접근 가능)

Quality Gate를 `"type": "agent"`로 구현하면 코드 맥락을 이해하고 더 정확한 검증이 가능합니다. 비용이 증가하지만 검증 품질이 높아집니다.

### I-2. SessionStart compact 훅 미활용

컨텍스트 압축 후 중요 지시사항이 손실될 수 있습니다. `SessionStart` 이벤트의 `compact` matcher를 활용하면 압축 후 핵심 규칙을 재주입할 수 있습니다:

```json
{
  "hooks": {
    "SessionStart": [{
      "matcher": "compact",
      "hooks": [{
        "type": "command",
        "command": "echo 'Reminder: Always verify SQL safety and 3-layer architecture.'"
      }]
    }]
  }
}
```

### I-3. PreToolUse 보안 훅 미활용

위험한 명령어(rm -rf, git push --force 등)를 차단하는 PreToolUse 훅 추가 가능:

```json
{
  "hooks": {
    "PreToolUse": [{
      "matcher": "Bash",
      "hooks": [{
        "type": "command",
        "command": ".claude/hooks/validate-bash.sh"
      }]
    }]
  }
}
```

### I-4. 17개 Hook 이벤트 중 2개만 활용

현재 사용 중인 이벤트: `Stop`, `PostToolUse`
미활용 이벤트: `SessionStart`, `SessionEnd`, `UserPromptSubmit`, `PreToolUse`, `PermissionRequest`, `PostToolUseFailure`, `Notification`, `SubagentStart`, `SubagentStop`, `PreCompact`, `ConfigChange`, `WorktreeCreate`, `WorktreeRemove`, `TeammateIdle`, `TaskCompleted`

모든 이벤트를 활용할 필요는 없지만, 프레임워크 목적에 맞는 유용한 후보:
- `SessionStart(compact)`: 컨텍스트 압축 후 핵심 규칙 재주입
- `PreToolUse(Bash)`: 위험 명령어 차단
- `Notification`: 데스크탑 알림 통합

---

## 수정 완료 항목 요약

| # | 이슈 | 수정 내용 |
|---|------|-----------|
| C-1 | stop_hook_active 미확인 | 모든 quality-gate.sh에 재진입 가드 추가 |
| C-2 | "bash" 접두사 | install.sh, settings-addon.json에서 제거 |
| H-1 | 빈 matcher | Stop 훅 설정에서 제거 |
| H-2 | hooks.json 누락 | domain-verify에 hooks.json 생성 |
| H-3 | plugin.json hooks 참조 | hooks 필드 추가 |
| H-4 | SKILL.md 누락 | verify 스킬에 SKILL.md 생성 |
| H-5 | 템플릿 혼합 | nuxt4/vue3로 분리, nuxt-monorepo 제거 |
| M-3 | CLAUDE_PLUGIN_ROOT | hooks.json에서 사용 |
| M-4 | README 설정 예시 | 올바른 설정으로 업데이트 |
| M-5 | _comment 필드 | settings-addon.json에서 제거 |

---

## 참고한 Anthropic 공식 문서

- [Hooks Reference](https://code.claude.com/docs/en/hooks) - 17개 이벤트, 3가지 핸들러 타입, matcher 패턴
- [Settings](https://code.claude.com/docs/en/settings) - settings.json 스키마, 우선순위 체계
- [Memory](https://code.claude.com/docs/en/memory) - CLAUDE.md 계층, rules 경로 스코핑
- [Skills](https://code.claude.com/docs/en/skills) - SKILL.md 형식, frontmatter 필드
- [Sub-agents](https://code.claude.com/docs/en/sub-agents) - 에이전트 정의, frontmatter
- [Plugins Reference](https://code.claude.com/docs/en/plugins-reference) - plugin.json, hooks.json, 디렉토리 구조
- [Best Practices](https://code.claude.com/docs/en/best-practices) - CLAUDE.md 간결함, 훅 vs 지시, 검증 원칙
