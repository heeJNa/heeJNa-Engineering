# FastAPI 프로젝트 템플릿

heejuna-engineering 프레임워크의 FastAPI 프로젝트 템플릿입니다.

## 적용 방법

```bash
./install.sh /path/to/project --template fastapi
```

또는 수동 설치:

```bash
mkdir -p .claude/hooks .claude/rules
cp path/to/heejuna-engineering/project-templates/fastapi/.claude/hooks/* .claude/hooks/
cp path/to/heejuna-engineering/project-templates/fastapi/.claude/rules/* .claude/rules/
chmod +x .claude/hooks/*.sh
```

프로젝트 `.claude/settings.json`에 Hook 등록:

```json
{
  "hooks": {
    "Stop": [{
      "hooks": [{
        "type": "command",
        "command": ".claude/hooks/quality-gate.sh"
      }]
    }]
  }
}
```

## 포함된 파일

| 파일 | 용도 |
|------|------|
| `hooks/quality-gate.sh` | Ruff + Pyright 자동 실행 |
| `rules/architecture.md` | Router→Service→Repository 3계층 규칙 |
| `rules/sql-safety.md` | SQL Injection 방지 규칙 |
| `rules/coding-standards.md` | Python 네이밍, 타입 힌트, import 규칙 |

## 커스터마이징

프로젝트에 맞게 rules 파일을 수정하세요:
- DB 스키마 관련 규칙 추가
- API 응답 형식 규칙 추가
- 도메인 특화 규칙 추가
