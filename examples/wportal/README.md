# WPortal 적용 예시

heejuna-engineering 프레임워크를 WPortal ERP 시스템에 적용한 예시입니다.

## 구조

```
wportal/
├── .claude/
│   └── rules/
│       ├── domain-knowledge.md    # 도메인 용어, 기술 규칙
│       └── frontend-patterns.md   # 프론트엔드 패턴
├── wcloud-front/                  # Nuxt Monorepo 프론트엔드
│   └── CLAUDE.md                  # 프론트엔드 상세 규칙
└── wportal-backend/               # FastAPI 백엔드
    └── CLAUDE.md                  # 백엔드 상세 규칙
```

## 적용된 패턴

### Quality Gate
- 프론트엔드: ESLint + Nuxt TypeCheck
- 백엔드: Ruff + Pyright

### Domain Rules
- 계약/정산은 마이그레이션 제외
- SQL 바인딩 필수 (f-string 금지)
- 새 테이블 생성 시 DB 권한 부여 필수
- main.py 포트 8080 절대 변경 금지

### Skills 활용
| Skill | 용도 |
|-------|------|
| `/v2-api` | 백엔드 v2 API 모듈 생성 |
| `/v2-frontend` | 프론트엔드 v2 모듈 + 컴포넌트 |
| `/v2-feature` | 풀스택 통합 생성 |
| `/wr-component` | Wr 디자인 시스템 컴포넌트 |
| `/wr-dialog` | WrDialog 패턴 가이드 |

## 이 예시를 자신의 프로젝트에 적용하기

1. `.claude/rules/` 디렉토리에 프로젝트 도메인 규칙 작성
2. 용어 사전(Ubiquitous Language) 정의
3. 기술 규칙 명시 (금지사항, 필수 패턴)
4. Skills로 반복 작업 자동화
