# FastAPI 아키텍처 규칙

## 3계층 분리 (필수)

모든 API 엔드포인트는 반드시 3계층으로 분리한다:

```
Router (라우터) → Service (서비스) → Repository (리포지토리)
```

### Router (라우터)
- HTTP 요청/응답 처리만 담당
- 비즈니스 로직 금지
- 인증/인가는 Depends()로 처리
- 응답 모델(Pydantic) 명시

```python
@router.get("/items", response_model=list[ItemResponse])
async def get_items(
    session: dict = Depends(requireSession),
    service: ItemService = Depends(),
):
    return await service.get_items(session)
```

### Service (서비스)
- 비즈니스 로직 담당
- 여러 Repository 조합 가능
- 트랜잭션 관리
- WHERE 조건 빌더 (clauses, params)

```python
class ItemService:
    def __init__(self, repo: ItemRepository = Depends()):
        self.repo = repo

    async def get_items(self, session: dict) -> list[dict]:
        clauses, params = [], []
        if not session.get("is_admin"):
            clauses.append("user_id = %s")
            params.append(session["user_id"])
        return await self.repo.find_all(clauses, params)
```

### Repository (리포지토리)
- 데이터베이스 접근만 담당
- SQL 쿼리 실행
- 비즈니스 로직 금지
- params는 항상 tuple 타입

```python
class ItemRepository:
    async def find_all(
        self, clauses: list[str] = [], params: tuple = ()
    ) -> list[dict]:
        where = " AND ".join(clauses) if clauses else "1=1"
        sql = f"SELECT * FROM items WHERE {where}"
        return await Query.fetch(sql, params)
```

## 디렉토리 구조

```
api/v2/{domain}/
├── __init__.py
├── router.py       # API 엔드포인트
├── service.py      # 비즈니스 로직
├── repository.py   # DB 접근
├── schema.py       # Pydantic 모델 (요청/응답)
└── model.py        # 도메인 모델 (선택)
```

## 공통 모듈 사용

```python
from api.v2.db import PgOrm, PgQuery, ErpRedis  # DB 접근
from api.v2.deps import requireSession            # 인증
from api.v2.date import today, firstOfMonth       # 날짜
from api.v2.logger import logger                  # 로깅
```

## 에러 처리

```python
from fastapi import HTTPException

# Service 계층에서 비즈니스 에러 발생
raise HTTPException(status_code=404, detail="항목을 찾을 수 없습니다")
raise HTTPException(status_code=403, detail="권한이 없습니다")
```
