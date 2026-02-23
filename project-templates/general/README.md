# General 프로젝트 템플릿

heejuna-engineering 프레임워크의 범용 프로젝트 템플릿입니다.
파일 확장자를 자동 감지하여 적절한 린트 도구를 실행합니다.

## 지원 언어

| 언어 | 도구 |
|------|------|
| TypeScript/JavaScript/Vue/Svelte | ESLint |
| Python | Ruff |
| Go | go vet |
| Rust | Clippy |

## 적용 방법

```bash
./install.sh /path/to/project --template general
```

또는 수동 설치:

```bash
mkdir -p .claude/hooks
cp path/to/heejuna-engineering/project-templates/general/.claude/hooks/quality-gate.sh .claude/hooks/
chmod +x .claude/hooks/quality-gate.sh
```

## 커스터마이징

`.claude/rules/` 디렉토리를 생성하고 프로젝트에 맞는 규칙을 추가하세요.
