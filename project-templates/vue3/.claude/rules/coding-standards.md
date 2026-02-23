# Vue 3 코딩 표준

## Composition API (필수)

### 기본 규칙
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
/* scoped 필수 */
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
1. Vue 내장 (`vue`, `vue-router`, `pinia`)
2. 외부 라이브러리
3. 내부 모듈 (절대 경로 `@/`)
4. 상대 경로

## Vue Router

### 라우팅 설정
```typescript
import { createRouter, createWebHistory } from 'vue-router'

const router = createRouter({
  history: createWebHistory(),
  routes: [
    {
      path: '/',
      component: () => import('@/views/Home.vue'),
    },
  ],
})
```

### 라우트 가드
```typescript
router.beforeEach((to, from, next) => {
  // 인증 체크 등
  next()
})
```

## 상태 관리

### Pinia (전역 상태)
```typescript
export const useUserStore = defineStore('user', () => {
  const user = ref<User | null>(null)
  const isLoggedIn = computed(() => !!user.value)

  async function login(credentials: LoginForm) {
    user.value = await api.login(credentials)
  }

  return { user, isLoggedIn, login }
})
```

### 로컬 상태
- `ref`: 단일 값
- `reactive`: 객체
- `computed`: 파생 값
- 외부 상태 라이브러리 추가 금지

## API 호출 패턴

### API 클라이언트
```typescript
// composables/useApi.ts
export function useApi() {
  const instance = axios.create({
    baseURL: import.meta.env.VITE_API_URL,
  })

  // 인증 인터셉터
  instance.interceptors.request.use((config) => {
    const token = useAuthStore().token
    if (token) config.headers.Authorization = `Bearer ${token}`
    return config
  })

  return instance
}
```

## 스타일 규칙
- SCSS 사용, CSS-in-JS 금지
- 디자인 토큰 변수 사용
- 매직 넘버 금지 (변수로 대체)
- `scoped` 스타일 필수
