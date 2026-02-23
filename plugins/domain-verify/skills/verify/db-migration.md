---
description: "DB 마이그레이션 스크립트 검증. /verify-db-migration으로 수동 호출 가능."
---
# DB Migration 검증 체크리스트

## 트리거
- 파일 패턴: `*/sql/*.sql`
- 훅 메시지에 핵심 체크리스트가 직접 주입됨

## 상세 체크리스트

- [ ] **GRANT 권한 부여** — 새 테이블 생성 시 `backend` 사용자에게 권한 부여 필수
- [ ] **시퀀스 권한** — SERIAL/BIGSERIAL 컬럼 사용 시 시퀀스 권한도 부여
- [ ] **테이블 접두사** — `t_` (일반) 또는 `mt_` (마스터/계약) 접두사 사용
- [ ] **인덱스 접두사** — `idx_` 접두사 사용
- [ ] **ICU 로케일** — 한글 정렬이 필요한 컬럼은 ICU ko-KR 로케일 인식

## GRANT 템플릿

### 새 테이블 생성 시
```sql
CREATE TABLE t_example (
    idx BIGSERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

-- 필수: backend 사용자에게 권한 부여
GRANT SELECT, INSERT, UPDATE, DELETE ON t_example TO backend;
GRANT USAGE, SELECT ON SEQUENCE t_example_idx_seq TO backend;
```

### 기존 테이블에 인덱스 추가 시
```sql
CREATE INDEX idx_example_name ON t_example (name);
```

## 왜 GRANT가 필수인가?

PostgreSQL에서 `backend` DB 사용자는 테이블 생성자가 아니므로 **자동으로 권한을 받지 않는다**. GRANT 없이 테이블을 만들면:
- API가 200 OK를 반환하지만 데이터가 빈 배열 `[]`로 나옴
- 에러 메시지가 없어 원인 파악이 어려움
- 실제 증상: "API는 정상인데 데이터가 안 나온다"

## 네이밍 규칙

| 대상 | 접두사 | 예시 |
|------|--------|------|
| 일반 테이블 | `t_` | `t_paid_db_type` |
| 마스터/계약 테이블 | `mt_` | `mt_long_cont` |
| 인덱스 | `idx_` | `idx_paid_db_type_name` |
| 시퀀스 | 자동생성 | `t_paid_db_type_idx_seq` |

## 위반 시 수정 방법

| 위반 | 수정 |
|------|------|
| GRANT 누락 | `GRANT SELECT, INSERT, UPDATE, DELETE ON {table} TO backend;` 추가 |
| 시퀀스 GRANT 누락 | `GRANT USAGE, SELECT ON SEQUENCE {table}_{col}_seq TO backend;` 추가 |
| `CREATE TABLE example` | `CREATE TABLE t_example` (t_ 접두사) |
| `CREATE INDEX example_idx` | `CREATE INDEX idx_example_col` (idx_ 접두사) |

## 참조
- 규칙 출처: MEMORY.md → "DB Permissions for New Tables"
- `wportal-backend/CLAUDE.md` → "네이밍 컨벤션" 섹션
