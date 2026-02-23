# domain-verify Plugin

**"Verify Always, Trust Never"** — 5대 원칙 #2를 코드화한 도메인 검증 시스템.

---

## 개요

AI가 v2 패턴의 파일을 편집할 때, PostToolUse 훅이 해당 도메인의 검증 체크리스트를 **Claude 컨텍스트에 직접 주입**한다. Claude는 주입된 체크리스트를 읽고, 위반 사항이 있으면 즉시 수정한다.

### 왜 필요한가?

AI가 코드를 작성할 때 도메인별 규칙(SQL 바인딩, 3계층 분리, Quasar 금지 등)을 **매번 기억하지 못한다**. 이 시스템은:

- 파일 패턴으로 도메인을 자동 감지
- 해당 도메인의 핵심 규칙을 체크리스트로 주입
- Claude가 즉시 자가 검증 → 위반 시 자동 수정

## 작동 원리

```
Claude가 파일 편집 (Edit/Write)
    ↓
PostToolUse 훅 (domain-verify.sh) 실행
    ↓
case 매칭: file_path가 v2 패턴인가?
    ↓  YES                    ↓  NO
체크리스트 전문을             exit 0 (무시)
Claude 컨텍스트에 직접 주입
    ↓
Claude가 즉시 검증 → 위반 시 자동 수정
```

## 지원 도메인

| 도메인 | 파일 패턴 | 핵심 검증 |
|--------|----------|----------|
| v2 Router | `*/api/v2/*/router*.py` | def 사용, Service 호출, ok() 응답 |
| v2 Service | `*/api/v2/*/*service*.py` | DB 직접 접근 금지, WHERE 빌더 |
| v2 Repository | `*/api/v2/*/*repository*.py` | **SQL 안전성 (CRITICAL)** |
| v2 Model | `*/api/v2/*/*model*.py` | WooriModel/BaseModel 상속 규칙 |
| v2 Component | `*/app/components/v2/*/*.vue` | Quasar 금지, 디자인 토큰 |
| v2 API Module | `*/app/utils/api/v2/module/*/*.ts` | createV2Client 사용 |
| DB Migration | `*/sql/*.sql` | GRANT 권한 부여 |

## 설치

### 1. 훅 파일 복사

```bash
# 프로젝트 루트에 훅 파일 배치
mkdir -p /path/to/project/.claude/hooks
cp hooks/domain-verify.sh /path/to/project/.claude/hooks/
chmod +x /path/to/project/.claude/hooks/domain-verify.sh
```

### 2. settings.json 등록

`/path/to/project/.claude/settings.json`:

```json
{
  "hooks": {
    "PostToolUse": [{
      "matcher": "Write|Edit",
      "hooks": [{
        "type": "command",
        "command": ".claude/hooks/domain-verify.sh",
        "timeout": 5
      }]
    }]
  }
}
```

> **Note**: 플러그인으로 설치한 경우 `hooks/hooks.json`이 자동으로 훅을 등록하므로 수동 설정이 불필요합니다.

### 3. (선택) 스킬 참조 문서 복사

수동 호출(`/verify-api-router` 등)이 필요하면 `skills/verify/` 파일을 프로젝트의 `.claude/skills/` 에 복사.

## Kill Switch

환경변수로 훅 비활성화:

```bash
SKIP_DOMAIN_VERIFY=1
```

## 커스터마이징

### 새 도메인 추가

1. `hooks/domain-verify.sh`에 case 블록 추가
2. `skills/verify/<domain>.md`에 상세 규칙 작성
3. `_template.md`를 참고하여 구조 통일

### 기존 규칙 수정

- 훅 체크리스트: `domain-verify.sh`의 해당 MSG 블록 수정
- 상세 문서: `skills/verify/<domain>.md` 수정

## 디렉토리 구조

```
domain-verify/
├── .claude-plugin/
│   └── plugin.json           # 플러그인 매니페스트
├── hooks/
│   └── domain-verify.sh      # 통합 디스패처 (모든 도메인)
├── skills/
│   └── verify/
│       ├── _template.md      # 새 도메인용 템플릿
│       ├── api-router.md     # v2 라우터 검증 참조
│       ├── api-service.md    # v2 서비스 검증 참조
│       ├── api-repository.md # SQL 안전성 검증 참조 (CRITICAL)
│       ├── api-model.md      # v2 모델 검증 참조
│       ├── vue-component.md  # v2 컴포넌트 검증 참조
│       ├── vue-api-module.md # v2 API 모듈 검증 참조
│       └── db-migration.md   # DB 마이그레이션 검증 참조
└── README.md                 # 이 문서
```

## 설계 결정

| 결정 | 이유 |
|------|------|
| 새 에이전트 없음 | OMC/Superpowers 에이전트와 충돌 방지 |
| 훅이 체크리스트 직접 주입 | 스킬 호출에 의존하면 비결정적 (Claude가 무시할 수 있음) |
| 단일 훅 스크립트 | 2개 분리 시 매 편집마다 jq 파싱 2회 → 단일로 합체 |
| v2 경로에만 한정 | v1 레거시 파일 오탐 방지 |

## 참조

- Heejuna Engineering Framework 5대 원칙: [docs/philosophy.md](../../docs/philosophy.md)
- Methodology: [docs/methodology.md](../../docs/methodology.md)
