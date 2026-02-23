# Vue 패턴 가이드 (Vue 3)

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

#### 미디어 쿼리
```scss
// Mobile First
@media (min-width: 600px) { ... }
@media (min-width: 1024px) { ... }

// 또는 프로젝트 mixin 사용
@include respond-to('sm') { ... }
@include respond-to('md') { ... }
```

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

## Vue Router 패턴

### Lazy Loading Routes
```typescript
const routes = [
  {
    path: '/dashboard',
    component: () => import('@/views/Dashboard.vue'),
    meta: { requiresAuth: true },
  },
]
```

### 중첩 라우트
```typescript
{
  path: '/users',
  component: () => import('@/layouts/UserLayout.vue'),
  children: [
    { path: '', component: () => import('@/views/users/List.vue') },
    { path: ':id', component: () => import('@/views/users/Detail.vue') },
  ],
}
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
- 라우트: `() => import(...)` (Vue Router)
- 컴포넌트: `defineAsyncComponent(() => import(...))`
- 이미지: `loading="lazy"`

### 리스트 렌더링
- `v-for`에 `:key` 필수 (index 사용 금지, 고유 ID 사용)
- 대량 리스트: `virtual-scroll` 고려

### 이벤트 최적화
- 스크롤/리사이즈: debounce 사용
- API 호출: debounce (300ms)
