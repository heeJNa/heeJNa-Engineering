---
description: "v2 레포지토리 SQL 안전성 검증 (CRITICAL). /verify-api-repository로 수동 호출 가능."
---
# v2 Repository SQL 안전성 검증 (CRITICAL)

## 트리거
- 파일 패턴: `*/api/v2/*/*repository*.py` | `*/api/v2/*/*repo*.py`
- 훅 메시지에 핵심 체크리스트가 직접 주입됨
- **이 검증은 보안 관련이므로 가장 엄격하게 적용한다.**

## 금지 패턴 (발견 시 즉시 수정)

### 1. f-string 값 삽입
```python
# 금지
sql = f"SELECT * FROM t WHERE name = '{name}'"
sql = f"SELECT * FROM t WHERE idx = {idx}"

# 수정
sql = "SELECT * FROM t WHERE name = %s AND idx = %s"
Query.select(sql, (name, idx))
```

### 2. replace sanitize
```python
# 금지
safe = value.replace("'", "''")
sql = f"SELECT * FROM t WHERE name = '{safe}'"

# 수정
sql = "SELECT * FROM t WHERE name = %s"
Query.select(sql, (value,))
```

### 3. f-string IN절
```python
# 금지
ids = ",".join(str(i) for i in id_list)
sql = f"SELECT * FROM t WHERE idx IN ({ids})"

# 수정: = ANY(%s) + 리스트 파라미터
sql = "SELECT * FROM t WHERE idx = ANY(%s)"
Query.select(sql, (id_list,))
```

### 4. f-string NOT IN
```python
# 금지
sql = f"SELECT * FROM t WHERE idx NOT IN ({ids})"

# 수정: != ALL(%s)
sql = "SELECT * FROM t WHERE idx != ALL(%s)"
Query.select(sql, (exclude_ids,))
```

### 5. f-string LIMIT/OFFSET
```python
# 금지
sql = f"SELECT * FROM t LIMIT {limit} OFFSET {offset}"

# 수정
sql = "SELECT * FROM t LIMIT %s OFFSET %s"
Query.select(sql, (limit, offset))
```

### 6. f-string INTERVAL
```python
# 금지
sql = f"... WHERE date > NOW() - INTERVAL '{months} months'"

# 수정
sql = "... WHERE date > NOW() - %s * INTERVAL '1 month'"
Query.select(sql, (months,))
```

### 7. f-string LIKE/ILIKE
```python
# 금지
sql = f"SELECT * FROM t WHERE name ILIKE '%{keyword}%'"

# 수정: 와일드카드는 Python 문자열로 조합
sql = "SELECT * FROM t WHERE name ILIKE %s"
Query.select(sql, (f"%{keyword}%",))
```

## 필수 패턴

- [ ] **DB 접근**: `from ..db import PgOrm, PgQuery` (v2 싱글턴 풀, include/database.py 아님)
- [ ] **params 시그니처**: `params: tuple = ()` 형태
- [ ] **LIMIT/OFFSET 확장**: `(*params, per_page, offset)` 튜플 확장
- [ ] **테이블명/컬럼명 f-string 허용**: 코드 상수이므로 OK
- [ ] **트랜잭션**: 다중 테이블 변경 시 `Orm.transaction()` 컨텍스트 매니저 사용
- [ ] **V2BatchResult**: 일괄 처리 응답은 `{inserted, successes, errors}` 표준 형식

## Repository 메서드 시그니처 예시

```python
from ..db import PgOrm as Orm, PgQuery as Query

class ItemRepository:
    @staticmethod
    def count(where_sql: str, params: tuple = ()) -> int:
        sql = f"SELECT COUNT(*) as total FROM t_item WHERE {where_sql}"
        result = Query.select(sql, params)
        return result[0]['total'] if result else 0

    @staticmethod
    def findAll(where_sql: str, per_page: int, offset: int, params: tuple = ()) -> list:
        sql = f"SELECT * FROM t_item WHERE {where_sql} ORDER BY idx DESC LIMIT %s OFFSET %s"
        return Query.select(sql, (*params, per_page, offset))
```

## 참조
- 규칙 출처: `wportal-backend/CLAUDE.md` → "SQL 안전성 규칙 (MANDATORY)" 섹션
