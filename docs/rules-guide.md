# Rules 시스템 사용 설명서

> 파일 패턴에 따라 자동으로 규칙을 적용하여, AI가 올바른 맥락에서 올바른 방식으로 코드를 작성하게 만든다.

---

## 개요

Rules는 Claude Code의 **조건부 지시 시스템**이다. 특정 파일이나 디렉토리를 작업할 때, 해당 영역에 맞는 규칙이 **자동으로 AI의 컨텍스트에 로드**된다.

### 비유

> 병원에서 각 진료과(내과, 외과, 소아과)마다 다른 진료 지침서가 있는 것과 같다. 의사(AI)가 내과 환자를 볼 때는 내과 지침서가 자동으로 나오고, 외과 환자를 볼 때는 외과 지침서가 나온다. 모든 진료과 지침서를 동시에 들고 다닐 필요가 없다.

### CLAUDE.md와의 차이

| 구분 | CLAUDE.md | Rules |
|------|-----------|-------|
| **로드 시점** | 항상 | 관련 파일 작업 시에만 |
| **범위** | 프로젝트 전체 | 특정 파일/디렉토리 |
| **역할** | 프로젝트 핵심 정보 | 상세 코딩 규칙 |
| **비유** | 회사 사원 수칙 | 부서별 업무 매뉴얼 |

```
CLAUDE.md (항상 로드 - 프로젝트 전체 규칙)
  "우리 프로젝트는 Nuxt 4 + TypeScript, strict 모드 사용"

rules/ (조건부 로드 - 파일 패턴별 규칙)
  vue-patterns.md → .vue 파일 작업 시
  sql-safety.md   → .py 파일 작업 시
  test-rules.md   → .test.ts 파일 작업 시
```

---

## Rules 파일 위치

```
프로젝트/
└── .claude/
    └── rules/
        ├── coding-standards.md    # 기본 코딩 표준
        ├── vue-patterns.md        # Vue 컴포넌트 패턴
        ├── api-rules.md           # API 엔드포인트 규칙
        └── test-rules.md          # 테스트 작성 규칙
```

Rules 파일은 **`.claude/rules/` 디렉토리**에 마크다운(.md) 파일로 작성한다.

---

## Rules 작성법

### 기본 구조

```markdown
# 규칙 제목

## 필수 규칙
- 규칙 1
- 규칙 2

## 금지 사항
- 하면 안 되는 것 1
- 하면 안 되는 것 2

## 패턴 (DO / DON'T)

### DO (올바른 예시)
\`\`\`typescript
// 올바른 코드 예시
\`\`\`

### DON'T (잘못된 예시)
\`\`\`typescript
// 잘못된 코드 예시
\`\`\`
```

### paths 프론트매터 (권장)

YAML frontmatter의 `paths:` 필드로 **특정 파일 패턴에서만** 규칙이 로드되도록 제한할 수 있다.

```markdown
---
paths:
  - "**/*.vue"
  - "**/*.ts"
---

# Vue/TypeScript 코딩 규칙
...
```

```markdown
---
paths:
  - "**/*.py"
---

# Python 코딩 규칙
...
```

**장점:** SQL 안전성 규칙(Python 전용)이 Vue 파일 작업 시 로드되는 비효율을 방지한다.

**glob 패턴:**
- `**/*.vue` — 모든 하위 디렉토리의 .vue 파일
- `src/api/**/*.ts` — src/api 하위의 .ts 파일만
- `**/*.test.ts` — 모든 테스트 파일

---

## 좋은 Rules 작성 원칙

### 1. 정보 밀도를 높여라

```markdown
# 나쁜 예 (장황함)
우리 프로젝트에서는 SQL을 작성할 때 f-string을 사용하면 안 됩니다.
왜냐하면 SQL injection 위험이 있기 때문입니다.
대신 파라미터 바인딩을 사용해야 합니다.

# 좋은 예 (간결함)
SQL: f-string 금지, %s 바인딩 필수. IN절은 = ANY(%s) 사용.
```

### 2. DO/DON'T 코드 예시를 포함하라

규칙만 나열하면 AI가 잘못 해석할 수 있다. **코드 예시**가 가장 정확하다.

```markdown
### 데이터 패칭 패턴

DO:
\`\`\`typescript
const { data } = await useAsyncData('key', () => $fetch('/api/items'))
\`\`\`

DON'T:
\`\`\`typescript
// Nuxt에서 axios 직접 호출 금지
const data = await axios.get('/api/items')
\`\`\`
```

### 3. "삭제해도 AI가 실수하지 않을 내용"은 넣지 마라

Anthropic 공식 가이드:

> "The test for each line: 'Would removing this cause Claude to make mistakes?' If not, cut it."

```markdown
# 넣어야 할 것
- f-string SQL 금지 (삭제하면 AI가 f-string 쓸 수 있음)
- Composition API 필수 (삭제하면 Options API 쓸 수 있음)

# 넣지 말아야 할 것
- "코드는 읽기 쉽게 작성하세요" (너무 일반적)
- "변수명은 의미 있게" (AI가 이미 잘 함)
```

### 4. 파일 패턴별로 분리하라

모든 규칙을 하나의 파일에 넣지 말고, **역할별로 분리**한다.

```
rules/
├── coding-standards.md   # 전체 코딩 표준 (모든 파일)
├── vue-patterns.md        # Vue 컴포넌트 규칙 (*.vue)
├── api-rules.md           # API 엔드포인트 규칙 (*/api/**)
├── test-rules.md          # 테스트 규칙 (*.test.ts)
└── sql-safety.md          # SQL 안전성 (*.py)
```

---

## 실제 Rules 예시

### 예시 1: Nuxt 4 코딩 표준

```markdown
---
paths:
  - "**/*.vue"
  - "**/*.ts"
---

# Nuxt 4 코딩 표준

## Composition API (필수)
- `<script setup lang="ts">` 사용 (Options API 금지)
- `defineProps`에 TypeScript 타입 명시
- `defineEmits`에 이벤트 타입 명시

## Auto-Import 활용
- Nuxt가 자동 import하는 항목은 명시적 import 불필요
- `#imports`에서 가져올 수 없는 경우만 명시적 import

## 데이터 패칭 (필수)
\`\`\`typescript
// SSR + 클라이언트 하이드레이션
const { data } = await useAsyncData('key', () => $fetch('/api/items'))

// 간편 버전
const { data } = await useFetch('/api/items')
\`\`\`

## 상태 관리
- 서버 상태: `useAsyncData` / `useFetch`
- 전역 상태: `useState` (SSR-safe)
- 복잡한 상태: Pinia
- 외부 상태 라이브러리 추가 금지
```

### 예시 2: SQL 안전성 규칙

```markdown
---
paths:
  - "**/*.py"
---

# SQL 안전성 규칙 (CRITICAL)

## 절대 금지
- `f"SELECT ... WHERE col = '{val}'"` — SQL injection 위험
- `f"... IN ({','.join(ids)})"` — SQL injection 위험
- `query.replace()` — 안전하지 않은 문자열 치환

## 필수 패턴
\`\`\`python
# 단일 값 바인딩
cursor.execute("SELECT * FROM users WHERE id = %s", (user_id,))

# IN 절
cursor.execute("SELECT * FROM users WHERE id = ANY(%s)", (list(ids),))

# 동적 WHERE 빌더
clauses: list[str] = []
params: tuple = ()
if name:
    clauses.append("name ILIKE %s")
    params += (f"%{name}%",)
\`\`\`
```

### 예시 3: Vue 3 Router/Pinia 패턴

```markdown
---
paths:
  - "**/*.vue"
  - "**/*.ts"
---

# Vue 3 패턴 가이드

## Vue Router
\`\`\`typescript
// Lazy Loading (필수)
const routes = [
  {
    path: '/dashboard',
    component: () => import('@/views/Dashboard.vue'),
    meta: { requiresAuth: true },
  },
]
\`\`\`

## Pinia Store (Setup Syntax)
\`\`\`typescript
export const useUserStore = defineStore('user', () => {
  const user = ref<User | null>(null)
  const isLoggedIn = computed(() => !!user.value)

  async function login(credentials: LoginForm) {
    user.value = await api.login(credentials)
  }

  return { user, isLoggedIn, login }
})
\`\`\`

## API 호출
- composable 패턴 사용 (`useApi()`)
- interceptor로 인증 토큰 자동 주입
- 에러 핸들링 통일
```

---

## 프로젝트 템플릿별 Rules

### Nuxt 4 템플릿

| 파일 | 내용 |
|------|------|
| `coding-standards.md` | Composition API, TypeScript, 레이어 아키텍처, Auto-Import, 데이터 패칭 |
| `vue-patterns.md` | 레이아웃, 반응형, 컴포넌트 패턴, 미들웨어, 접근성, 성능 |

### Vue 3 템플릿

| 파일 | 내용 |
|------|------|
| `coding-standards.md` | Composition API, TypeScript, Vue Router, Pinia, API 호출 |
| `vue-patterns.md` | 레이아웃, 반응형, 컴포넌트 패턴, Lazy Loading, 접근성 |

### FastAPI 템플릿

| 파일 | 내용 |
|------|------|
| `api-rules.md` | 3계층 구조, Router/Service/Repository 패턴 |
| `sql-safety.md` | SQL 안전성, %s 바인딩, WHERE 빌더 |
| `test-rules.md` | pytest 패턴, 픽스처, 비동기 테스트 |

---

## 커스텀 Rules 추가하기

### 1단계: 파일 생성

```bash
# 프로젝트의 .claude/rules/ 디렉토리에 생성
touch /path/to/project/.claude/rules/my-custom-rule.md
```

### 2단계: 규칙 작성

```markdown
---
paths:
  - "src/components/**/*.vue"
---

# 컴포넌트 규칙

## 네이밍
- 파일명: PascalCase.vue
- 2단어 이상: UserProfile.vue (Profile.vue 금지)

## 구조
- props는 interface 대신 type 사용
- emit 이벤트는 kebab-case (update:modelValue)

## 금지
- Options API 사용 금지
- 인라인 스타일 금지
- any 타입 금지
```

### 3단계: 확인

해당 파일 패턴을 편집하면 Claude Code가 자동으로 규칙을 참조한다. 별도의 설정이나 등록은 필요 없다.

---

## 컨텍스트 계층 구조

Rules는 Claude Code의 컨텍스트 계층 중 **Level 1**에 해당한다.

```
Level 0: CLAUDE.md (항상 로드)
  프로젝트 핵심 정보. 기술 스택, 아키텍처, 핵심 규칙

Level 1: rules/ (관련 파일 작업 시 자동 로드)  ← Rules
  파일 패턴별 세부 규칙. 코딩 표준, 패턴, 금지 사항

Level 2: skills/ (명시적 호출 시 로드)
  특정 작업 유형의 완전한 수행 절차

Level 3: MEMORY.md (참조용)
  프로젝트에서 축적된 경험적 지식
```

**핵심:** CLAUDE.md에 모든 규칙을 넣으면 AI가 중요한 지시를 놓칠 수 있다. Rules로 분리하면 **필요한 때에 필요한 규칙만** 로드되어 AI의 주의력이 분산되지 않는다.

---

## 자주 묻는 질문

### Q: Rules가 로드되었는지 어떻게 확인하나?

파일을 편집할 때 Claude Code가 내부적으로 관련 rules를 로드한다. Claude에게 "현재 적용된 규칙을 확인해줘"라고 요청하면 확인할 수 있다.

### Q: Rules 파일이 너무 많으면 문제가 되나?

파일 수 자체는 문제가 되지 않는다. `paths:` 프론트매터를 사용하면 관련 규칙만 로드되므로 성능 영향이 없다. 다만 `paths:`가 없으면 모든 규칙이 항상 로드되어 컨텍스트가 오염될 수 있다.

### Q: CLAUDE.md에 넣어야 할 것과 Rules에 넣어야 할 것의 기준은?

| CLAUDE.md에 넣을 것 | Rules에 넣을 것 |
|---------------------|-----------------|
| 프로젝트 개요 | 파일별 코딩 패턴 |
| 기술 스택 | 상세 DO/DON'T |
| 디렉토리 구조 | 도메인별 규칙 |
| 핵심 원칙 (1~2줄) | 코드 예시 |
| 커밋 규칙 | 테스트 규칙 |

**판단 기준:** "이 규칙이 **모든 작업**에 필요한가?" → CLAUDE.md, "**특정 파일 작업 시에만** 필요한가?" → Rules

---

## 참고

- [Anthropic 공식: Memory & Rules](https://docs.anthropic.com/en/docs/claude-code/memory)
- [철학](philosophy.md) — Context is King, Domain Knowledge as Code
- [감사 보고서](audit-report.md) — M-2: paths 프론트매터 미사용 이슈
