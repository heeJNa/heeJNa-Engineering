---
description: "v2 서비스 파일 검증. /verify-api-service로 수동 호출 가능."
---
# v2 Service 검증 체크리스트

## 트리거
- 파일 패턴: `*/api/v2/*/*service*.py`
- 훅 메시지에 핵심 체크리스트가 직접 주입됨

## 상세 체크리스트

- [ ] **DB 직접 접근 금지** — `PgQuery`, `PgOrm`, `Query`, `Orm` 임포트 및 사용 금지. 반드시 Repository를 통해서만 DB 접근.
- [ ] **`fail()` 사용** — `HTTPException` 직접 raise 금지. `from ..utils import fail` 등 공통 에러 유틸 사용.
- [ ] **WHERE 빌더 패턴** — 동적 필터 조건은 `(where_clauses, params)` 튜플 빌드 후 Repository에 전달.
- [ ] **params: tuple 타입** — list로 빌드 후 `tuple(params)`로 변환하여 Repository에 전달.
- [ ] **비즈니스 로직 집중** — 검증, 가공, 비즈니스 규칙은 Service에서 처리.
- [ ] **N+1 방지** — 반복문 안 개별 조회 대신 일괄 조회 후 캐시 활용.
- [ ] **트랜잭션 인식** — 다중 테이블 변경 시 Repository에 트랜잭션 처리 위임.

## WHERE 빌더 패턴 예시

```python
def getFilteredList(userid: str, status: str | None, page: int, per_page: int):
    where_clauses = ["r.userid = %s"]
    params: list = [userid]

    if status:
        where_clauses.append("r.status = %s")
        params.append(status)

    where_sql = " AND ".join(where_clauses)
    params_tuple = tuple(params)

    total = Repository.count(where_sql, params=params_tuple)
    offset = (page - 1) * per_page
    rows = Repository.findAll(where_sql, per_page, offset, params=params_tuple)
    return {"rows": rows, "total": total}
```

## 위반 시 수정 방법

| 위반 | 수정 |
|------|------|
| `from ..db import PgQuery` in service | Repository 메서드 호출로 대체 |
| `raise HTTPException(403, ...)` | `fail(403, "message")` |
| `f"WHERE name = '{name}'"` | WHERE 빌더 패턴으로 `(where_clauses, params)` 빌드 |
| `for item in items: repo.find(item.id)` | `repo.findByIds([i.id for i in items])` |

## 참조
- 규칙 출처: `wportal-backend/CLAUDE.md` → "v2 코딩 표준", "WHERE 빌더 패턴" 섹션
