# WPortal 도메인 지식

## 프로젝트 개요
WPortal은 우리인슈만라이프 ERP 시스템의 웹 포털입니다.

## Bounded Context (도메인 경계)

### 핵심 도메인
- **계약(Contract)**: 보험 계약 관리 — 마이그레이션 제외 (비즈니스 임팩트 큼)
- **정산(Settlement)**: 수수료/실적 정산 — 마이그레이션 제외
- **유료DB(Paid-DB)**: 고객 DB 배분/관리 — v2 마이그레이션 완료
- **일괄DB(Batch-DB)**: 일괄 배분 관리 — v2 마이그레이션 완료

### 지원 도메인
- **인증(Auth)**: OAuth + JWT + Redis 세션
- **권한(Permission)**: 메뉴별/기능별 접근 제어
- **대시보드(Dashboard)**: 실적/통계 시각화

## Ubiquitous Language (용어 통일)

| 용어 | 의미 | 코드에서 |
|------|------|---------|
| 설계사 | 보험 영업 직원 | `user`, `planner` |
| 지사 | 영업 지점 | `branch` |
| 유료DB | 구매한 고객 정보 | `paid_db` |
| 배분 | DB를 설계사에게 할당 | `distribute`, `assign` |
| 계약 | 보험 상품 가입 | `contract` |
| 정산 | 수수료 계산/지급 | `settlement` |

## 기술 규칙

### 프론트엔드
- Woori DS 디자인 시스템 사용 (`Wr-` 접두사)
- 신규 기능은 v2 API 패턴 필수 (`useV2Api()`)
- base 레이어 우선 배치 (공통 컴포넌트)
- Quasar는 레거시, 점진적 제거 중

### 백엔드
- v2/ prefix API (Router → Service → Repository 3계층)
- SQL 바인딩 필수 (%s 파라미터, f-string 금지)
- main.py 포트 8080 절대 변경 금지

### 데이터베이스
- PostgreSQL (ICU: ko-KR)
- 새 테이블 생성 시 `backend` 유저에게 GRANT 필수
- Redis: 세션 + 캐시
