# 12개 에이전트 상세 가이드

> 각 에이전트의 역할, 적합한 모델, 사용 시점, 비용 고려사항을 정리한다.

## 에이전트 전체 요약

```
                    ┌─────────────────────┐
                    │    Opus (최고 비용)    │
                    │  oracle, momus,      │
                    │  metis, prometheus   │
                    └──────────┬──────────┘
                               │
                    ┌──────────v──────────┐
                    │   Sonnet (중간 비용)   │
                    │  sisyphus-junior,    │
                    │  frontend-engineer,  │
                    │  librarian,          │
                    │  multimodal-looker,  │
                    │  orchestrator,       │
                    │  qa-tester           │
                    └──────────┬──────────┘
                               │
                    ┌──────────v──────────┐
                    │   Haiku (최저 비용)    │
                    │  explore,            │
                    │  document-writer     │
                    └─────────────────────┘
```

---

## Opus 티어 에이전트 (아키텍처/분석/계획)

가장 강력하지만 비용도 가장 높다. 복잡한 추론이 필요한 작업에만 사용한다.

### 1. Oracle

| 항목 | 내용 |
|------|------|
| **모델** | Opus |
| **역할** | 아키텍처 분석, 복잡한 디버깅, 근본 원인 분석 |
| **비용** | 높음 |

**사용 시점**

- 원인을 알 수 없는 버그가 발생했을 때
- 시스템 아키텍처 결정이 필요할 때
- 여러 모듈에 걸친 복잡한 문제를 분석할 때
- 성능 병목 지점을 찾아야 할 때

**사용하지 말아야 할 때**

- 단순한 코드 수정 (sisyphus-junior 사용)
- 파일 검색 (explore 사용)
- 문서 작성 (document-writer 사용)

**예시**

```
상황: API 응답이 빈 배열 []을 반환하지만 에러는 없음

[oracle 분석]
1. 라우터 확인 -> 정상
2. 서비스 로직 확인 -> 정상
3. DB 쿼리 직접 실행 -> 데이터 존재
4. DB 권한 확인 -> backend 유저에 SELECT 권한 없음!

근본 원인: 새 테이블에 대한 GRANT가 누락됨
해결: GRANT SELECT, INSERT, UPDATE, DELETE ON new_table TO backend;
```

---

### 2. Momus

| 항목 | 내용 |
|------|------|
| **모델** | Opus |
| **역할** | 계획 리뷰, 비판적 평가, 문제점 발견 |
| **비용** | 높음 |

**사용 시점**

- Prometheus가 작성한 계획을 검토할 때
- 중요한 아키텍처 변경 전 리뷰가 필요할 때
- 기존 코드의 설계 문제를 발견하고 싶을 때

**특징**

Momus는 의도적으로 비판적이다. "괜찮아 보인다"보다는 "이 부분이 문제다"를 찾는 데 최적화되어 있다. Writer/Reviewer 패턴에서 Reviewer 역할을 담당한다.

**예시**

```
/review migration-plan.md

[momus 리뷰]
1. 위험: 롤백 전략이 명시되어 있지 않습니다.
2. 누락: 동시 접근 시 데이터 정합성 처리가 없습니다.
3. 의문: Phase 2와 Phase 3를 병렬로 실행할 수 있지 않나요?
4. 개선: 각 Phase에 완료 기준(exit criteria)을 추가하세요.
```

---

### 3. Metis

| 항목 | 내용 |
|------|------|
| **모델** | Opus |
| **역할** | 사전 계획, 숨겨진 요구사항 분석, 리스크 분석 |
| **비용** | 높음 |

**사용 시점**

- 새로운 기능을 시작하기 전 숨겨진 요구사항을 찾고 싶을 때
- 프로젝트의 리스크를 사전에 파악하고 싶을 때
- "이것도 고려해야 하지 않나?" 싶은 것들을 발굴할 때

**Momus와의 차이**

| Metis | Momus |
|-------|-------|
| 사전 분석 (계획 전) | 사후 리뷰 (계획 후) |
| "이런 것도 생각해봤나요?" | "이 계획의 문제점은..." |
| 발산적 사고 | 수렴적 사고 |

**예시**

```
[metis 분석] "v2 API에 파일 업로드 기능을 추가한다고요?"

숨겨진 요구사항:
1. 파일 크기 제한은? 운영 환경 Nginx에 client_max_body_size 설정 필요
2. 동시 업로드 제한은? 서버 메모리 고려
3. 바이러스 스캔은? 보안 정책 확인
4. 기존 파일과 이름 충돌 시 처리?
5. 업로드 중 네트워크 끊김 시 임시 파일 정리?

리스크:
- 높음: 대용량 파일 업로드 시 서버 OOM 가능
- 중간: 동시 다발 업로드 시 디스크 I/O 병목
- 낮음: 파일명 인코딩 이슈 (한글 파일명)
```

---

### 4. Prometheus

| 항목 | 내용 |
|------|------|
| **모델** | Opus |
| **역할** | 전략적 계획 수립, 인터뷰 워크플로우 |
| **비용** | 높음 |

**사용 시점**

- 복잡한 기능을 체계적으로 계획해야 할 때
- 여러 모듈에 걸친 대규모 작업을 시작하기 전
- 요구사항이 모호하여 구체화가 필요할 때

**워크플로우**

```
/plan <설명>
   |
   v
[인터뷰] 요구사항 구체화 질문 3-5개
   |
   v
[사용자 답변]
   |
   v
"Create the plan"
   |
   v
[계획서 생성] Phase별, 파일별, 검증 기준 포함
```

**예시**

```
/plan WrTable 컴포넌트 설계

[prometheus] "다음 질문에 답해주세요:
1. 가상 스크롤(대량 데이터)이 필요한가요?
2. 열 정렬/필터링이 필요한가요?
3. 행 선택(체크박스) 기능이 필요한가요?
4. 반응형(모바일)에서는 어떻게 표시하나요?
5. 기존 Quasar QTable을 대체하는 건가요?"

사용자 답변 후 -> 구체적인 구현 계획서 생성
```

---

## Sonnet 티어 에이전트 (구현/조율)

비용과 성능의 균형이 좋다. 대부분의 코드 구현 작업에 사용한다.

### 5. Sisyphus-Junior

| 항목 | 내용 |
|------|------|
| **모델** | Sonnet |
| **역할** | 직접 작업 구현, 코드 작성/수정 |
| **비용** | 중간 |

**사용 시점**

- 구체적인 코드 작성이 필요할 때
- 버그 수정, 기능 추가, 리팩토링
- Todo 목록의 개별 항목 실행

**특징**

가장 자주 사용되는 에이전트다. Orchestrator가 분배한 작업을 실제로 수행하는 "일꾼" 역할이다. Todo 추적, 파일 수정, 검증까지 전 과정을 담당한다.

**예시**

```
[sisyphus-junior] Todo: "v2 customer router 생성"

1. 기존 패턴 확인 (paid-db router 참조)
2. api/v2/customer/router.py 생성
3. api/v2/customer/service.py 생성
4. api/v2/customer/repository.py 생성
5. ruff check 실행 -> 통과
6. pytest 실행 -> 통과
7. Todo 완료 체크
```

---

### 6. Frontend-Engineer

| 항목 | 내용 |
|------|------|
| **모델** | Sonnet |
| **역할** | UI/UX 구현, 컴포넌트 설계, 스타일링 |
| **비용** | 중간 |

**사용 시점**

- Vue/Nuxt 컴포넌트를 작성할 때
- SCSS 스타일링, 반응형 디자인 구현
- Woori DS 컴포넌트 개발
- 접근성(a11y) 관련 작업

**예시**

```
[frontend-engineer] "WrDatePicker 컴포넌트 구현"

1. _tokens.scss에 날짜 관련 토큰 정의
2. WrDatePicker.vue 컴포넌트 작성
3. 반응형 처리 (respond-below 믹스인 활용)
4. 키보드 네비게이션 구현
5. ESLint 통과 확인
```

---

### 7. Librarian

| 항목 | 내용 |
|------|------|
| **모델** | Sonnet |
| **역할** | 문서 검색, 코드 이해, 라이브러리 조사 |
| **비용** | 중간 |

**사용 시점**

- 코드베이스에서 특정 패턴이나 구현을 찾을 때
- 외부 라이브러리의 사용법을 조사할 때
- 기존 코드의 동작 방식을 이해해야 할 때

**Oracle과의 차이**

| Librarian | Oracle |
|-----------|--------|
| "이 코드가 무엇을 하는지" 이해 | "이 코드에 무엇이 잘못됐는지" 분석 |
| 정보 수집 | 문제 해결 |
| Sonnet (중간 비용) | Opus (높은 비용) |

**예시**

```
[librarian] "v1 인증 흐름을 파악해줘"

조사 결과:
1. 로그인: POST /api/auth/login -> JWT 토큰 발급
2. 세션: Redis에 저장 (키: session:{user_id})
3. 미들웨어: requireSession에서 Redis 조회
4. 권한: curUserInfo['permission']['perms'] 경로로 접근
5. OAuth: Google, Apple, Kakao, Naver 지원
```

---

### 8. Multimodal-Looker

| 항목 | 내용 |
|------|------|
| **모델** | Sonnet |
| **역할** | 스크린샷 분석, 다이어그램 분석, 시각적 비교 |
| **비용** | 중간 |

**사용 시점**

- UI 스크린샷을 분석하여 구현해야 할 때
- 디자인 시안과 실제 구현의 차이를 비교할 때
- 에러 스크린샷을 분석할 때
- 아키텍처 다이어그램을 코드로 변환할 때

**예시**

```
[multimodal-looker] "이 스크린샷의 레이아웃을 구현해줘"

분석 결과:
- 상단: 헤더 바 (높이 ~56px, 흰 배경, 그림자)
- 좌측: 사이드 네비게이션 (너비 ~240px, 회색 배경)
- 중앙: 컨텐츠 영역 (카드 그리드, 3열)
- 하단: 페이지네이션 (가운데 정렬)

추천 구현: CSS Grid + WrCard 컴포넌트
```

---

### 9. Orchestrator-Sisyphus

| 항목 | 내용 |
|------|------|
| **모델** | Sonnet |
| **역할** | 복잡한 다단계 작업 조율, 하위 에이전트 관리 |
| **비용** | 중간 |

**사용 시점**

- 여러 에이전트가 동시에 작업해야 할 때
- 작업 간 의존성이 복잡할 때
- 대규모 마이그레이션이나 리팩토링을 진행할 때

**특징**

자신은 코드를 직접 작성하지 않는다. 대신 sisyphus-junior, frontend-engineer 등 실행 에이전트에게 작업을 분배하고 결과를 취합한다.

**예시**

```
[orchestrator-sisyphus] "v2 마이그레이션 전체 조율"

분배:
  -> [sisyphus-junior #1] 백엔드 API 마이그레이션
  -> [sisyphus-junior #2] 프론트엔드 API 클라이언트 마이그레이션
  -> [frontend-engineer] 컴포넌트 v2 패턴 적용
  -> [document-writer] API 문서 업데이트

취합:
  -> 전체 통합 테스트 실행
  -> 결과 보고
```

---

### 10. QA-Tester

| 항목 | 내용 |
|------|------|
| **모델** | Sonnet |
| **역할** | 인터랙티브 CLI 테스트, 기능 검증 |
| **비용** | 중간 |

**사용 시점**

- 구현된 기능의 동작을 검증할 때
- E2E 테스트 시나리오를 실행할 때
- 사용자 시나리오 기반으로 테스트할 때

**예시**

```
[qa-tester] "로그인 -> 대시보드 -> 고객 목록 플로우 테스트"

Step 1: 로그인 페이지 접속 -> 200 OK
Step 2: 인증 정보 입력 -> JWT 토큰 발급 확인
Step 3: 대시보드 API 호출 -> 데이터 로딩 확인
Step 4: 고객 목록 API 호출 -> 필터링 동작 확인
Step 5: 페이지네이션 -> 다음 페이지 데이터 확인

결과: 5/5 통과
```

---

## Haiku 티어 에이전트 (빠른 작업)

비용이 가장 낮고 응답이 빠르다. 단순한 작업에 적합하다.

### 11. Explore

| 항목 | 내용 |
|------|------|
| **모델** | Haiku |
| **역할** | 빠른 파일 검색, 패턴 매칭, 코드 탐색 |
| **비용** | 최저 |

**사용 시점**

- 특정 파일이나 함수를 빠르게 찾을 때
- 코드베이스에서 패턴을 검색할 때
- "이 함수가 어디에서 사용되는지" 확인할 때

**다른 에이전트를 쓰기 전에 explore로 먼저 검색**하는 것이 비용 효율적이다.

**예시**

```
[explore] "useV2Api가 사용되는 모든 파일"

검색 결과:
- base/app/composables/v2Api.ts (정의)
- web/app/pages/v2/paid-db/index.vue (사용)
- web/app/pages/v2/batch-db/index.vue (사용)
- web/app/components/v2/dashboard/Chart.vue (사용)
총 4개 파일
```

---

### 12. Document-Writer

| 항목 | 내용 |
|------|------|
| **모델** | Haiku |
| **역할** | README 작성, API 문서, 코드 주석 |
| **비용** | 최저 |

**사용 시점**

- 코드에 JSDoc/docstring 주석을 추가할 때
- README나 CHANGELOG를 작성할 때
- API 엔드포인트 문서를 생성할 때

**예시**

```
[document-writer] "v2 customer API 문서 작성"

## Customer API

### GET /api/v2/customer/list
고객 목록을 조회합니다.

**Query Parameters**
| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| page | int | N | 페이지 번호 (기본값: 1) |
| per_page | int | N | 페이지 크기 (기본값: 20) |
| search | string | N | 검색어 |

**Response**
{ "status": "success", "data": [...], "message": "" }
```

---

## 비용 최적화 팁

### 원칙: 가장 저렴한 에이전트부터 시도

```
비용 순서: Haiku << Sonnet << Opus

질문: "이 함수 어디에 있지?"
  X oracle (Opus) -- 과도한 비용
  X librarian (Sonnet) -- 불필요한 비용
  O explore (Haiku) -- 적절한 비용
```

### 모델 티어별 사용 가이드

| 작업 유형 | 적절한 모델 | 에이전트 예시 |
|----------|-----------|------------|
| 파일/패턴 검색 | Haiku | explore |
| 문서 작성 | Haiku | document-writer |
| 코드 구현 | Sonnet | sisyphus-junior, frontend-engineer |
| 코드 이해 | Sonnet | librarian |
| UI 분석 | Sonnet | multimodal-looker |
| 작업 조율 | Sonnet | orchestrator-sisyphus |
| 아키텍처 분석 | Opus | oracle |
| 계획 수립 | Opus | prometheus |
| 비판적 리뷰 | Opus | momus |
| 리스크 분석 | Opus | metis |

### 비용 절약 패턴

1. **검색 먼저**: 구현 전에 explore로 기존 코드 확인 (중복 방지)
2. **단계별 에스컬레이션**: explore -> librarian -> oracle 순서로 복잡도 증가 시에만 상위 에이전트 사용
3. **병렬 실행**: Sonnet 에이전트 여러 개를 병렬로 돌리는 것이 Opus 하나를 오래 돌리는 것보다 빠르고 저렴할 수 있다
4. **자동 검증 우선**: momus(Opus)를 호출하기 전에 Quality Gate(자동화)로 먼저 검증

---

## 에이전트 조합 패턴

### 패턴 1: 조사 -> 구현

```
[librarian] 기존 코드 패턴 파악
     |
     v
[sisyphus-junior] 파악된 패턴에 맞춰 구현
```

**사용 시점**: 기존 코드베이스의 패턴을 따라야 하는 새 기능 개발

---

### 패턴 2: 분석 -> 수정

```
[oracle] 근본 원인 분석
     |
     v
[sisyphus-junior] 원인에 맞는 수정 구현
```

**사용 시점**: 원인 불명의 버그 수정

---

### 패턴 3: 계획 -> 리뷰 -> 구현

```
[prometheus] 전략적 계획 수립
     |
     v
[momus] 계획 리뷰 및 개선
     |
     v
[orchestrator-sisyphus] 작업 분배 및 실행
     |
     v
[sisyphus-junior x N] 병렬 구현
```

**사용 시점**: 대규모 기능 개발 또는 아키텍처 변경

---

### 패턴 4: 병렬 구현

```
[ultrawork]
     |
     +---> [sisyphus-junior #1] 모듈 A
     |
     +---> [sisyphus-junior #2] 모듈 B
     |
     +---> [frontend-engineer] UI 컴포넌트
     |
     +---> [document-writer] API 문서
```

**사용 시점**: 독립적인 여러 모듈을 동시에 개발할 때

---

### 패턴 5: 풀스택 기능 개발

```
[explore] 기존 코드 구조 파악
     |
     v
[sisyphus-junior #1] 백엔드 API (router/service/repository)
[sisyphus-junior #2] 프론트엔드 API 클라이언트 (v2 모듈)
     |
     v (둘 다 완료 후)
[frontend-engineer] UI 컴포넌트 (v2 디렉토리)
     |
     v
[qa-tester] E2E 테스트
```

**사용 시점**: 백엔드부터 프론트엔드까지 전체를 한 번에 개발할 때
