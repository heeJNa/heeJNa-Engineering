#!/bin/bash
# domain-verify.sh — PostToolUse hook
# 파일 편집 시 해당 도메인의 검증 체크리스트를 Claude 컨텍스트에 직접 주입
#
# 작동 원리:
#   1. Edit/Write 도구 사용 후 실행
#   2. file_path를 case 패턴으로 매칭
#   3. v2 패턴에 해당하면 도메인별 체크리스트를 JSON message로 출력
#   4. Claude가 즉시 검증 → 위반 시 자동 수정
#
# Kill switch: SKIP_DOMAIN_VERIFY=1 로 비활성화

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# 파일 경로가 없으면 종료
[ -z "$FILE_PATH" ] && exit 0

# Kill switch
[ -n "$SKIP_DOMAIN_VERIFY" ] && exit 0

FILENAME=$(basename "$FILE_PATH")
MSG=""

case "$FILE_PATH" in

  # ── Backend: v2 Router ──
  */api/v2/*/router*.py)
    MSG="[Domain Verify: v2 Router] '${FILENAME}' 검증:
1. def 사용 (async def 금지 — psycopg2 sync I/O 블로킹 방지)
2. requireSession(sessionid) 의존성 주입
3. 응답: ok(data=...) / created(data=...) 사용
4. Service 함수 직접 호출 (Repository 직접 접근 금지)
5. app.py routers dict에 라우터 등록 확인
위반 발견 시 즉시 수정하세요." ;;

  # ── Backend: v2 Service ──
  */api/v2/*/*service*.py)
    MSG="[Domain Verify: v2 Service] '${FILENAME}' 검증:
1. DB 직접 접근 금지 (PgQuery/PgOrm 사용 금지 — Repository만 호출)
2. fail() 사용 (HTTPException 직접 raise 금지)
3. 동적 필터: (where_clauses, params) 튜플 패턴 빌드 후 Repository에 전달
4. params: tuple 타입 사용
위반 발견 시 즉시 수정하세요." ;;

  # ── Backend: v2 Repository (CRITICAL: SQL Safety) ──
  */api/v2/*/*repository*.py|*/api/v2/*/*repo*.py)
    MSG="[Domain Verify: SQL 안전성] '${FILENAME}' — CRITICAL 검증:
금지 패턴 (발견 시 즉시 수정):
  - f\"col = '\${val}'\" → col = %s + params
  - replace(\"'\", \"''\") → %s 바인딩
  - f\"IN (\${ids})\" → = ANY(%s) + [리스트]
  - f\"LIMIT \${n}\" → LIMIT %s + params 확장
  - f\"INTERVAL '\${m} months'\" → %s * INTERVAL '1 month'
필수 패턴:
  - PgQuery (읽기) / PgOrm (쓰기) — from ..db import
  - params: tuple = () 시그니처
  - (*params, per_page, offset) 튜플 확장
  - 테이블명/컬럼명 f-string은 허용 (코드 상수)
위반 발견 시 즉시 수정하세요." ;;

  # ── Backend: v2 Model ──
  */api/v2/*/*model*.py)
    MSG="[Domain Verify: v2 Model] '${FILENAME}' 검증:
1. DB 테이블 모델: WooriModel 상속 + UPPERCASE 클래스명 (예: PAIDDBTYPENEW)
2. Request/Response 모델: BaseModel 상속 + PascalCase
3. Optional[] 필드에 = None 기본값
4. 날짜 필드: date 타입 사용 (str 금지)
위반 발견 시 즉시 수정하세요." ;;

  # ── Frontend: v2 Component ──
  */app/components/v2/*/*.vue)
    MSG="[Domain Verify: v2 Component] '${FILENAME}' 검증:
1. Quasar 금지: q-btn/q-input/useQuasar()/\$q 사용 불가 → Wr 컴포넌트 사용
2. 색상: var(--wr-*) 토큰만 사용 (하드코딩 #hex 금지)
3. 반응형: @use 'breakpoints' as bp 믹스인 사용 + flex-wrap
4. scoped SCSS
5. Composition API order 준수
위반 발견 시 즉시 수정하세요." ;;

  # ── Frontend: v2 API Module ──
  */app/utils/api/v2/module/*/*.ts)
    MSG="[Domain Verify: v2 API Module] '${FILENAME}' 검증:
1. createV2Client() 의 get/post/put/del 메서드 사용
2. Public 메서드에 Promise<T> 리턴 타입 명시
3. base/app/composables/v2Api.ts에 모듈 등록 확인
4. 내부 request() non-generic, 외부만 generic
위반 발견 시 즉시 수정하세요." ;;

  # ── DB Migration ──
  */sql/*.sql)
    MSG="[Domain Verify: DB Migration] '${FILENAME}' 검증:
1. GRANT SELECT, INSERT, UPDATE, DELETE ON {table} TO backend
2. 시퀀스: GRANT USAGE, SELECT ON SEQUENCE {seq} TO backend
3. 테이블명: t_ 접두사
4. 인덱스명: idx_ 접두사
위반 발견 시 즉시 수정하세요." ;;

  *) exit 0 ;;
esac

if [ -n "$MSG" ]; then
  jq -n --arg msg "$MSG" '{"continue": true, "message": $msg}'
fi
exit 0
