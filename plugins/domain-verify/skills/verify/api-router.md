---
description: "v2 라우터 파일 검증. /verify-api-router로 수동 호출 가능."
---
# v2 Router 검증 체크리스트

## 트리거
- 파일 패턴: `*/api/v2/*/router*.py`
- 훅 메시지에 핵심 체크리스트가 직접 주입됨

## 상세 체크리스트

- [ ] **`def` 사용 (async def 금지)** — psycopg2(sync) + redis-py(sync) 사용 환경. `async def`로 정의하면 이벤트 루프 스레드에서 sync I/O를 실행하게 되어 전체 워커의 다른 요청을 블로킹한다. `def`로 정의하면 Starlette가 자동으로 스레드 풀에서 실행.
- [ ] **`requireSession(sessionid)` 의존성 주입** — `from app import credential_dependency` + `Depends(credential_dependency)` 사용
- [ ] **응답 형식** — `ok(data=...)` / `created(data=...)` 사용. 직접 dict 반환 금지.
- [ ] **Service 계층만 호출** — Router에서 Repository 직접 접근 금지. `Service.method()` 호출.
- [ ] **app.py 등록** — `routers` dict에 라우터 alias + 모듈 경로 추가 (알파벳 정렬)
- [ ] **prefix 규칙** — `APIRouter(prefix="/v2/{resource}", tags=["v2-{resource}"])`
- [ ] **네이밍** — 함수명은 camelCase (예: `getList`, `createItem`)

## 위반 시 수정 방법

| 위반 | 수정 |
|------|------|
| `async def get_list(...)` | `def get_list(...)` |
| `return {"status": "ok"}` | `return ok(data={"status": "ok"})` |
| `Repository.findAll(...)` in router | Service 메서드로 래핑 후 호출 |
| app.py 미등록 | `routers` dict에 추가 |

## async def 허용 예외

함수 본문에서 DB/Redis 접근 없이 `httpx.AsyncClient`, `aiofiles` 등 async 라이브러리만 사용할 때만 `async def` 허용. 판단이 어려우면 사용자에게 확인.

## 참조
- 규칙 출처: `wportal-backend/CLAUDE.md` → "v2 라우터 함수 정의" 섹션
