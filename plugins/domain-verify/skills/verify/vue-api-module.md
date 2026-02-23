---
description: "v2 API 모듈 검증. /verify-vue-api-module로 수동 호출 가능."
---
# v2 API Module 검증 체크리스트

## 트리거
- 파일 패턴: `*/app/utils/api/v2/module/*/*.ts`
- 훅 메시지에 핵심 체크리스트가 직접 주입됨

## 상세 체크리스트

- [ ] **createV2Client() 사용** — `get`/`post`/`put`/`del` 메서드 사용
- [ ] **Public 메서드 리턴 타입** — `Promise<T>` 명시
- [ ] **v2Api.ts 등록** — `base/app/composables/v2Api.ts`에 모듈 등록 확인
- [ ] **내부 request() non-generic** — 내부 함수는 제네릭 없음, public 메서드에만 `Promise<T>`
- [ ] **V2Response 자동 언래핑** — createV2Client가 처리하므로 수동 언래핑 불필요
- [ ] **successMessage 옵션** — 성공 알림이 필요한 경우 `V2CallOptions.successMessage` 사용

## 모듈 구조 예시

```typescript
// base/app/utils/api/v2/module/paid-db/admin.ts
import type { V2CallOptions } from '../../types'

export const createPaidDbAdminModule = (client: ReturnType<typeof createV2Client>) => {
  const request = (options?: V2CallOptions) => client

  return {
    /** 유형 목록 조회 */
    getTypes: (): Promise<PaidDbType[]> =>
      request().get('/v2/paid-db/admin/types'),

    /** 유형 생성 */
    createType: (body: PaidDbTypeCreate): Promise<PaidDbType> =>
      request({ successMessage: '유형이 생성되었습니다.' }).post('/v2/paid-db/admin/types', { body }),
  }
}
```

## v2Api.ts 등록 예시

```typescript
// base/app/composables/v2Api.ts
import { createPaidDbModule } from '@base/utils/api/v2/module/paid-db'

export const useV2Api = () => {
  const client = createV2Client(useRequestFetch())
  return {
    $v2: {
      paidDb: createPaidDbModule(client),
      // 새 모듈 추가 시 여기에 등록
    },
  }
}
```

## 위반 시 수정 방법

| 위반 | 수정 |
|------|------|
| `$fetch('/api/v2/...')` 직접 사용 | `createV2Client()` 메서드 사용 |
| 리턴 타입 누락 | `(): Promise<MyType[]> =>` 추가 |
| v2Api.ts 미등록 | composables/v2Api.ts에 모듈 등록 |
| `useRequestFetch()<V2Response<T>>()` 직접 사용 | `createV2Client()` 팩토리 사용 |

## nuxi prepare 필요

새 composable 추가 후 auto-import 갱신:
```bash
npx nuxi prepare base && npx nuxi prepare web
```

## 참조
- 규칙 출처: `wcloud-front/.claude/rules/api-layer.md` → "v2 API" 섹션
