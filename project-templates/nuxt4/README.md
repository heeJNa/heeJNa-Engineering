# Nuxt 4 프로젝트 템플릿

heejuna-engineering 프레임워크의 Nuxt 4 프로젝트 템플릿입니다.
Nuxt 레이어 아키텍처, SSR, auto-import 등 Nuxt 4 고유 기능에 최적화되어 있습니다.

## 적용 방법

```bash
./install.sh /path/to/project --template nuxt4
```

또는 수동 설치:

```bash
mkdir -p .claude/hooks .claude/rules
cp path/to/heejuna-engineering/project-templates/nuxt4/.claude/hooks/* .claude/hooks/
cp path/to/heejuna-engineering/project-templates/nuxt4/.claude/rules/* .claude/rules/
chmod +x .claude/hooks/*.sh
```

## 포함된 파일

| 파일 | 용도 |
|------|------|
| `hooks/quality-gate.sh` | ESLint + Nuxt TypeCheck 자동 실행 |
| `rules/coding-standards.md` | Nuxt 4 레이어, auto-import, 데이터 패칭 규칙 |
| `rules/vue-patterns.md` | 반응형, 접근성, 성능, Nuxt 미들웨어/플러그인 패턴 |

## Vue 3 전용 프로젝트라면?

Nuxt 없이 Vue 3만 사용하는 프로젝트는 `vue3` 템플릿을 사용하세요:

```bash
./install.sh /path/to/project --template vue3
```
