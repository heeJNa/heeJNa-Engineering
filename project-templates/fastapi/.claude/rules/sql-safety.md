# SQL 안전성 규칙 (MANDATORY)

## 절대 금지 패턴

다음 패턴은 SQL Injection 취약점을 유발한다. **절대 사용하지 않는다.**

```python
# ❌ 금지: f-string 직접 삽입
f"WHERE name = '{name}'"
f"WHERE id IN ({id_list})"
f"LIMIT {limit}"

# ❌ 금지: 수동 이스케이핑
name.replace("'", "''")

# ❌ 금지: format()
"WHERE name = '{}'".format(name)
```

## 필수 패턴

### 기본 바인딩
```python
# ✅ 올바른: %s 파라미터 바인딩
sql = "SELECT * FROM items WHERE name = %s AND status = %s"
params = (name, status)
await Query.fetch(sql, params)
```

### IN절
```python
# ✅ 올바른: = ANY(%s) 사용
sql = "SELECT * FROM items WHERE id = ANY(%s)"
params = (id_list,)  # list를 tuple에 담아서

# ✅ 올바른: NOT IN → != ALL(%s)
sql = "SELECT * FROM items WHERE id != ALL(%s)"
params = (exclude_list,)
```

### LIMIT / OFFSET
```python
# ✅ 올바른: %s 바인딩
sql = "SELECT * FROM items WHERE 1=1 LIMIT %s OFFSET %s"
params = (*existing_params, per_page, offset)
```

### 날짜 연산
```python
# ✅ 올바른: INTERVAL 바인딩
sql = "WHERE created_at > NOW() - %s * INTERVAL '1 month'"
params = (months,)
```

## WHERE 빌더 패턴

Service 계층에서 WHERE 조건을 동적으로 조립:

```python
# Service
clauses: list[str] = []
params: list = []

if name:
    clauses.append("name ILIKE %s")
    params.append(f"%{name}%")

if status:
    clauses.append("status = %s")
    params.append(status)

if ids:
    clauses.append("id = ANY(%s)")
    params.append(ids)

return await repo.find_all(clauses, tuple(params))
```

```python
# Repository
async def find_all(self, clauses: list[str] = [], params: tuple = ()):
    where = " AND ".join(clauses) if clauses else "1=1"
    sql = f"SELECT * FROM items WHERE {where} ORDER BY id"
    return await Query.fetch(sql, params)
```

## 검증 명령어

```bash
# f-string SQL 패턴 검출
ruff check --select S608 api/v2/

# 또는 수동 검색
grep -rn "f\".*SELECT\|f\".*INSERT\|f\".*UPDATE\|f\".*DELETE" api/v2/
```
