---
name: verify
description: v2 도메인별 검증 체크리스트. 파일 편집 시 PostToolUse 훅이 자동으로 체크리스트를 주입하며, 수동으로도 호출 가능.
user-invocable: true
---

# 도메인 검증 시스템

v2 패턴 파일 편집 시 해당 도메인의 검증 체크리스트를 확인합니다.

## 지원 도메인

| 도메인 | 참조 문서 | 핵심 검증 |
|--------|----------|----------|
| v2 Router | @api-router.md | def 사용, Service 호출, ok() 응답 |
| v2 Service | @api-service.md | DB 직접 접근 금지, WHERE 빌더 |
| v2 Repository | @api-repository.md | **SQL 안전성 (CRITICAL)** |
| v2 Model | @api-model.md | WooriModel/BaseModel 상속 |
| v2 Component | @vue-component.md | Quasar 금지, 디자인 토큰 |
| v2 API Module | @vue-api-module.md | createV2Client 사용 |
| DB Migration | @db-migration.md | GRANT 권한 부여 |

## 사용법

이 스킬은 두 가지 방식으로 동작합니다:

1. **자동**: PostToolUse 훅이 v2 파일 편집을 감지하여 체크리스트를 자동 주입
2. **수동**: `/verify` 명령으로 수동 호출하여 현재 작업 파일의 도메인 규칙 확인
