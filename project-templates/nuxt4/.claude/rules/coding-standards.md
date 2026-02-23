# Nuxt 4 코딩 표준

## Vue 3 컴포넌트 패턴

### Composition API (필수)
- `<script setup lang="ts">` 사용 (Options API 금지)
- `defineProps`에 TypeScript 타입 명시
- `defineEmits`에 이벤트 타입 명시

### 컴포넌트 구조
```vue
<script setup lang="ts">
// 1. imports
// 2. props & emits
// 3. composables (useXxx)
// 4. reactive state (ref, reactive, computed)
// 5. watchers
// 6. lifecycle hooks
// 7. methods
</script>

<template>
  <!-- 단일 루트 엘리먼트 권장 -->
</template>

<style scoped lang="scss">
/* scoped 필수, 글로벌 스타일은 레이어에서 관리 */
</style>
```

### 네이밍 규칙
- 컴포넌트 파일: `PascalCase.vue` (예: `UserProfile.vue`)
- composable: `useCamelCase.ts` (예: `useUserProfile.ts`)
- 유틸리티: `camelCase.ts` (예: `formatDate.ts`)
- 상수: `UPPER_SNAKE_CASE`
- 타입/인터페이스: `PascalCase`

## TypeScript 규칙

### 필수
- `strict: true` 모드
- `any` 타입 사용 금지 (불가피한 경우 `unknown` 사용)
- 함수 반환 타입 명시 (공개 API)
- 인터페이스보다 `type` 선호 (합성 용이)

### Import 순서
1. Vue/Nuxt 내장 (`#imports` auto-import 우선)
2. 외부 라이브러리
3. 내부 모듈 (절대 경로)
4. 상대 경로

## Nuxt 레이어 아키텍처

### 레이어 구조
- **base 레이어** (공통): 모든 앱에서 공유되는 코드만 배치
  - 디자인 시스템 컴포넌트
  - 공통 composable, 유틸리티
- **앱 레이어** (web/mobile/open): 앱별 페이지, 레이아웃, 컴포넌트

### Auto-Import 활용
- Nuxt가 자동 import하는 항목 (composables, utils, components)은 명시적 import 불필요
- `#imports`에서 가져올 수 없는 경우만 명시적 import 사용

### Server Routes
- `server/api/` 디렉토리에 API 라우트 배치
- `defineEventHandler()` 사용
- H3 유틸리티 (`readBody`, `getQuery`, `createError`) 활용

## 데이터 패칭 패턴

### Nuxt 내장 (필수 사용)
```typescript
// SSR + 클라이언트 하이드레이션
const { data, error } = await useAsyncData('key', () => $fetch('/api/items'))

// 자동 캐시/중복 제거 (간편)
const { data } = await useFetch('/api/items')

// 클라이언트 전용 (lazy)
const { data } = useLazyFetch('/api/items')
```

### v2 API 패턴 (신규 기능 필수)
```typescript
const { $v2 } = useV2Api()
const data = await $v2.module.method(params)
```

## 상태 관리
- 서버 상태: `useAsyncData` / `useFetch` (SSR-safe)
- 전역 상태: `useState` (Nuxt SSR-safe)
- 복잡한 상태: Pinia (SSR 호환)
- 클라이언트 로컬 상태: `ref` / `reactive`
- 외부 상태 라이브러리 추가 금지

## 스타일 규칙
- SCSS 사용, CSS-in-JS 금지
- 디자인 토큰 변수 사용 (`$token-*`)
- 매직 넘버 금지 (토큰으로 대체)
- 반응형: `respond-to()` / `respond-below()` mixin 사용
