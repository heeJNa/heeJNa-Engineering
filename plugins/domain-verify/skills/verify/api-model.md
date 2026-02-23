---
description: "v2 모델 파일 검증. /verify-api-model로 수동 호출 가능."
---
# v2 Model 검증 체크리스트

## 트리거
- 파일 패턴: `*/api/v2/*/*model*.py`
- 훅 메시지에 핵심 체크리스트가 직접 주입됨

## 상세 체크리스트

- [ ] **DB 테이블 모델** — `WooriModel` 상속 + UPPERCASE 클래스명
- [ ] **Request/Response 모델** — `BaseModel` 상속 + PascalCase 클래스명
- [ ] **Optional 필드** — `Optional[]` 필드에 `= None` 기본값 필수
- [ ] **날짜 필드** — `date` 타입 사용 (`str` 금지)
- [ ] **Field 사용** — `Field(...)` 또는 `Field(None, title="설명")`으로 문서화
- [ ] **WooriModel 자동 변환** — userid 계열은 자동 대문자, contdate 계열은 자동 YYYY-MM-DD 변환

## 모델 유형별 예시

### DB 테이블 모델 (WooriModel)
```python
from include.global_validator import WooriModel, Field

class PAIDDBTYPENEW(WooriModel):
    userid: str = Field(..., title="사용자ID")
    type_name: str = Field(..., title="유형명")
    sort_order: int = Field(0, title="정렬순서")
```

### Request 모델 (BaseModel)
```python
from pydantic import BaseModel
from typing import Optional
from datetime import date

class PaidDbCreateRequest(BaseModel):
    type_idx: int
    target_month: date
    memo: Optional[str] = None
```

### Response 모델 (BaseModel)
```python
class PaidDbResponse(BaseModel):
    idx: int
    type_name: str
    target_month: date
    created_at: str
```

## 위반 시 수정 방법

| 위반 | 수정 |
|------|------|
| `class PaidDbType(WooriModel)` | `class PAIDDBTYPE(WooriModel)` (UPPERCASE) |
| `class CREATEREQUEST(BaseModel)` | `class CreateRequest(BaseModel)` (PascalCase) |
| `target_month: Optional[str]` | `target_month: Optional[date] = None` |
| `memo: Optional[str]` (기본값 없음) | `memo: Optional[str] = None` |

## 참조
- 규칙 출처: `wportal-backend/CLAUDE.md` → "모델 정의", "v2 네이밍 컨벤션" 섹션
