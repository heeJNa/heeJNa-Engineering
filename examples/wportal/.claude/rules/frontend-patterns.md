# WPortal 프론트엔드 패턴

## v2 API 사용 (필수)

```typescript
// 신규 기능은 반드시 v2 패턴
const { $v2 } = useV2Api()
const data = await $v2.paidDb.getList(params)
```

## Woori DS 컴포넌트

모든 UI는 Wr 컴포넌트를 우선 사용:
- `WrButton`, `WrInput`, `WrSelect`, `WrDialog`
- `WrTable`, `WrBadge`, `WrCard`
- Quasar 컴포넌트(`q-*`)는 기존 코드에서만 유지

## 필터 검색 패턴

- **자동 검색**: 필터 3개 이하 + 본인 데이터 → watch/debounce
- **수동 검색**: 필터 4개 이상 또는 관리자 → 검색 버튼
- 모든 API 호출에 `useWrDebounce` (300ms) 적용

## 반응형 디자인

```scss
// Mobile First
@include respond-to('sm') { ... }  // >= 600px
@include respond-to('md') { ... }  // >= 1024px

// 주의: respond-below는 상한값 사용!
@include respond-below('sm') { ... }  // < 1024px (not < 600px!)
```

## 컴포넌트 배치

| 분류 | 경로 | 예시 |
|------|------|------|
| Wr 공통 | `base/app/components/wr/` | WrButton, WrInput |
| v2 도메인 | `{app}/app/components/v2/{domain}/` | V2PaidDbPageAdmin |
| v1 레거시 | 기존 위치 유지 | - |
