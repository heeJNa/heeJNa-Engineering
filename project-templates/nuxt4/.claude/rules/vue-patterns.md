# Vue 패턴 가이드 (Nuxt 4)

## 레이아웃 패턴

### Flexbox 우선
- Grid보다 Flexbox 선호 (대부분의 레이아웃에 충분)
- CSS Grid는 2차원 레이아웃에만 사용
- `gap` 속성으로 간격 관리 (margin보다 선호)

### 반응형 디자인

#### Breakpoint 체계
| 이름 | 범위 | 용도 |
|------|------|------|
| xs | 0 ~ 599px | 모바일 (세로) |
| sm | 600 ~ 1023px | 태블릿 / 모바일 (가로) |
| md | 1024 ~ 1439px | 랩탑 |
| lg | 1440 ~ 1919px | 데스크탑 |
| xl | 1920px+ | 와이드 데스크탑 |

#### 반응형 mixin
```scss
// Mobile First (min-width)
@include respond-to('sm') { ... }  // >= 600px
@include respond-to('md') { ... }  // >= 1024px

// Desktop First (max-width)
@include respond-below('sm') { ... }  // < 1024px (주의!)
@include respond-below('xs') { ... }  // < 600px
```

**주의**: `respond-below`는 해당 범위의 **상한값** 사용!

## 컴포넌트 패턴

### Props 기반 변형
```vue
<script setup lang="ts">
type Size = 'sm' | 'md' | 'lg'
type Variant = 'primary' | 'secondary' | 'outline'

const props = withDefaults(defineProps<{
  size?: Size
  variant?: Variant
}>(), {
  size: 'md',
  variant: 'primary',
})
</script>
```

### v-model 패턴
```vue
<script setup lang="ts">
const model = defineModel<string>({ required: true })
</script>
```

### Provide/Inject (부모-자식 통신)
```typescript
// 부모
provide('key', readonly(value))

// 자식
const value = inject('key')
```

## Nuxt 전용 패턴

### 미들웨어
```typescript
// middleware/auth.ts
export default defineNuxtRouteMiddleware((to) => {
  const { isAuthenticated } = useAuth()
  if (!isAuthenticated.value) {
    return navigateTo('/login')
  }
})
```

### 플러그인
```typescript
// plugins/api.ts
export default defineNuxtPlugin(() => {
  // 플러그인 로직
})
```

### 에러 핸들링
```vue
<script setup lang="ts">
// 에러 바운더리
const error = useError()
</script>

<template>
  <NuxtErrorBoundary>
    <slot />
    <template #error="{ error, clearError }">
      <ErrorPage :error="error" @clear="clearError" />
    </template>
  </NuxtErrorBoundary>
</template>
```

## 접근성 (a11y)

### 필수
- 인터랙티브 요소에 `aria-label` 또는 `aria-labelledby`
- `role` 적절히 사용
- 키보드 네비게이션 지원 (`tabindex`, `@keydown`)
- 색상 대비 4.5:1 이상

### 이미지
- `<img>`에 `alt` 필수
- 장식용 이미지: `alt=""`

## 성능 패턴

### Lazy Loading
- 페이지: Nuxt 자동 (파일 기반 라우팅)
- 컴포넌트: `defineAsyncComponent(() => import(...))`
- 이미지: `loading="lazy"`

### 리스트 렌더링
- `v-for`에 `:key` 필수 (index 사용 금지, 고유 ID 사용)
- 대량 리스트: `virtual-scroll` 고려

### 이벤트 최적화
- 스크롤/리사이즈: debounce 사용
- API 호출: debounce (300ms)
