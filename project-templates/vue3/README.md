# Vue 3 프로젝트 템플릿

heejuna-engineering 프레임워크의 Vue 3 프로젝트 템플릿입니다.
Nuxt 없이 Vue 3 + TypeScript + Vue Router + Pinia로 구성된 프로젝트에 최적화되어 있습니다.

## 적용 방법

```bash
./install.sh /path/to/project --template vue3
```

또는 수동 설치:

```bash
mkdir -p .claude/hooks .claude/rules
cp path/to/heejuna-engineering/project-templates/vue3/.claude/hooks/* .claude/hooks/
cp path/to/heejuna-engineering/project-templates/vue3/.claude/rules/* .claude/rules/
chmod +x .claude/hooks/*.sh
```

## 포함된 파일

| 파일 | 용도 |
|------|------|
| `hooks/quality-gate.sh` | ESLint + vue-tsc 자동 실행 |
| `rules/coding-standards.md` | Vue 3 Composition API, TypeScript, Pinia, Router 규칙 |
| `rules/vue-patterns.md` | 반응형, 접근성, 성능, 라우팅 패턴 |

## Nuxt 프로젝트라면?

Nuxt 4 기반 프로젝트는 `nuxt4` 템플릿을 사용하세요:

```bash
./install.sh /path/to/project --template nuxt4
```
