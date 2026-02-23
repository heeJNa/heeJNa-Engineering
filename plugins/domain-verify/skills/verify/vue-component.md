---
description: "v2 Vue 컴포넌트 검증. /verify-vue-component로 수동 호출 가능."
---
# v2 Vue Component 검증 체크리스트

## 트리거
- 파일 패턴: `*/app/components/v2/*/*.vue`
- 훅 메시지에 핵심 체크리스트가 직접 주입됨

## 상세 체크리스트

### Quasar 금지 (CRITICAL)
- [ ] `q-btn` → `WrButton`
- [ ] `q-input` → `WrInput`
- [ ] `q-select` → `WrSelect`
- [ ] `q-table` → `WrTable`
- [ ] `q-dialog` → `WrDialog`
- [ ] `q-card` → `WrCard`
- [ ] `q-badge` → `WrBadge`
- [ ] `q-icon` → `WrIcon`
- [ ] `useQuasar()` / `$q` → Wr composables 사용

### 디자인 토큰
- [ ] 하드코딩 색상 금지 (`#333`, `#f8f9fb` 등) → `var(--wr-*)` 사용
- [ ] 하드코딩 간격 금지 → `var(--wr-space-*)` 사용
- [ ] 하드코딩 폰트 크기 금지 → `var(--wr-font-*)` 사용

### 반응형 (v2 필수)
- [ ] `@use 'breakpoints' as bp` 믹스인 임포트
- [ ] `min-width` / `max-width` 설정 (고정 크기 대신 유동적 사이즈)
- [ ] `flex-wrap: wrap` 으로 좁은 화면 줄바꿈 처리
- [ ] 다이얼로그: `min-width: min(Xpx, calc(100vw - 48px))` 패턴
- [ ] 소형 화면 패딩 축소

### 코드 품질
- [ ] `<style lang="scss" scoped>` 사용
- [ ] Composition API order 준수 (imports → definePageMeta → Props → Composables → Refs → Watch → Methods → Lifecycle)
- [ ] Arrow function + JSDoc 스타일
- [ ] 숫자 input은 `align="right"`

## Quasar → Wr 매핑 참조

| Quasar | Wr 컴포넌트 |
|--------|------------|
| `q-btn` | `WrButton` |
| `q-input` | `WrInput` |
| `q-select` | `WrSelect` |
| `q-table` | `WrTable` |
| `q-dialog` | `WrDialog` |
| `q-card` | `WrCard` |
| `q-tabs` / `q-tab` | `WrTabs` / `WrTab` |
| `q-badge` | `WrBadge` |
| `q-icon` | `WrIcon` |
| `q-spinner` | `WrSpinner` |
| `q-skeleton` | `WrSkeleton` |
| `q-checkbox` | `WrCheckbox` |
| `q-separator` | `WrSeparator` |
| `q-tooltip` | `WrTooltip` |
| `q-pagination` | `WrPagination` |
| `$q.notify()` | `useWrNotify()` |
| `$q.dialog()` | `useWrDialog()` |

## 위반 시 수정 방법

| 위반 | 수정 |
|------|------|
| `<q-btn label="저장">` | `<WrButton label="저장">` |
| `color: #333;` | `color: var(--wr-text);` |
| `background: #f8f9fb;` | `background: var(--wr-bg-secondary);` |
| `<style lang="scss">` | `<style lang="scss" scoped>` |
| 반응형 미적용 | `@use 'breakpoints' as bp` + 미디어쿼리 추가 |

## 참조
- 규칙 출처: `wcloud-front/.claude/rules/woori-ds.md`, `wcloud-front/.claude/rules/coding-standards.md`
