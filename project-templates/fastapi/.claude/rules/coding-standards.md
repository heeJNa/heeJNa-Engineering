# FastAPI 코딩 표준

## Python 스타일

### 네이밍 규칙
- 함수/변수: `snake_case`
- 클래스: `PascalCase`
- 상수: `UPPER_SNAKE_CASE`
- private: `_prefix`
- 모듈: `snake_case.py`

### 타입 힌트 (필수)
```python
# 함수 시그니처에 타입 명시
async def get_items(
    user_id: int,
    status: str | None = None,
    page: int = 1,
) -> list[dict]:
    ...

# 변수 타입 (복잡한 경우만)
items: list[ItemResponse] = []
```

### Import 순서
```python
# 1. 표준 라이브러리
from datetime import datetime
from typing import Any

# 2. 서드파티
from fastapi import APIRouter, Depends, HTTPException

# 3. 프로젝트 공통
from api.v2.db import PgQuery
from api.v2.deps import requireSession

# 4. 같은 도메인
from .service import ItemService
from .schema import ItemResponse
```

## Pydantic 모델

### 요청 모델
```python
from pydantic import BaseModel, Field

class ItemCreate(BaseModel):
    name: str = Field(..., min_length=1, max_length=100)
    description: str | None = None
    price: int = Field(..., ge=0)
```

### 응답 모델
```python
class ItemResponse(BaseModel):
    id: int
    name: str
    description: str | None
    price: int
    created_at: datetime

    model_config = {"from_attributes": True}
```

## 에러 처리

### HTTPException 사용
```python
# 400: 잘못된 요청
raise HTTPException(400, "잘못된 입력값입니다")

# 403: 권한 없음
raise HTTPException(403, "이 작업을 수행할 권한이 없습니다")

# 404: 찾을 수 없음
raise HTTPException(404, "항목을 찾을 수 없습니다")
```

### 절대 하지 말 것
```python
# ❌ 예외를 삼키지 않기
try:
    ...
except Exception:
    pass  # 금지!

# ❌ 너무 넓은 예외 처리
try:
    ...
except Exception as e:
    return {"error": str(e)}  # 금지!
```

## 비동기 규칙

### async 일관성
- 라우터 핸들러: 항상 `async def`
- DB 호출하는 서비스: `async def`
- 순수 계산만 하는 유틸: `def` (async 불필요)

### DB 커넥션
- `with` 또는 컨텍스트 매니저로 관리
- 커넥션 풀 사용 (단일 커넥션 금지)

## 검증 명령어

```bash
# 린트
ruff check api/v2/

# 타입 검사
npx pyright api/v2/

# 테스트
pytest tests/v2/ -v
```
