# Micro-Step Phase Policy

## 목적

이 문서는 Obora workflow가 **작업 요구사항에 따라 phase를 동적으로 선택/확장/축소**할 수 있도록 하는 정책 소스다.

핵심 원칙:
- phase는 고정 pipeline이 아니다.
- phase는 작업 요구사항에 따라 선택된다.
- workflow는 이 문서를 읽고 실행 계획을 만든다.
- 사람은 요구사항과 함께 workflow 하나만 실행한다.
- 새 생성뿐 아니라 기존 프로젝트의 수정/삭제/개선/재구성도 다룬다.

---

## 핵심 원칙

### 1. Phase는 정책 단위다
Phase는 YAML에 하드코딩된 고정 실행 순서가 아니라,
요구사항을 해석할 때 사용하는 **정책적 실행 구간**이다.

### 2. Workflow는 phase plan을 생성해야 한다
Workflow는 요구사항과 이 문서를 읽고,
이번 작업에 필요한 phase만 골라서 `phase-plan.md` 또는 `phase-plan.json` 을 생성해야 한다.

### 3. 모든 phase는 micro-step으로 분해되어야 한다
어떤 phase도 broad scope로 한 번에 실행하면 안 된다.

기본 규칙:
- 한 unit당 책임 1개
- 한 unit당 생성/수정 파일 1~2개 권장
- 많아도 3개 이내
- 구조 결정과 구현을 같은 unit에 과도하게 섞지 않음
- 삭제/이동/병합은 일반 수정보다 더 작은 단위로 다룬다

### 4. 실패 핸들링도 정책이어야 한다
- 429 → backoff/retry
- SDK_8002 → unit scope 축소 또는 phase 재분해
- 실패를 수동 성공으로 덮지 않음

---

## Change Mode Taxonomy

Workflow는 phase 선택 전에 먼저 이번 요청의 change mode를 분류해야 한다.

### 1. Create
- 새 파일/새 구조/새 모듈/새 문서 생성

### 2. Modify
- 기존 파일 일부 수정
- 내용 업데이트
- 구조는 유지하되 내용만 개선

### 3. Delete
- 불필요 파일/섹션/문서/구조 제거

### 4. Refactor
- 동작/의미는 유지하면서 구조 개선
- 복잡도 축소, 분리, 정리

### 5. Restructure
- 파일 위치 변경
- 문서 체계 개편
- 디렉토리 구조 재구성

### 6. Audit
- 현재 상태 분석
- 문제/중복/폐기 후보/위험 식별

### 7. Migrate
- 한 방식에서 다른 방식으로 이동
- 예: HTML → React, legacy docs → new doc structure

### 8. Prune
- stale content 제거
- obsolete rules/workflows/docs 정리

---

## Discovery Rules

기존 프로젝트를 다룰 때는 실행 전에 반드시 현재 상태를 읽어야 한다.

### Discovery가 필요한 경우
- modify
- delete
- refactor
- restructure
- audit
- migrate
- prune

### Discovery에서 확인할 것
- 현재 파일 목록
- 관련 문서/코드/설정
- 수정 대상 범위
- 참조 관계
- 삭제 시 영향 범위
- 대체 경로 존재 여부

### Discovery 산출물
- `current-state.md`
- 필요 시 `impact-notes.md`

---

## Phase Catalog

## 0. Discovery
### 목적
- 현재 상태 파악
- 관련 파일과 영향 범위 식별

### 포함 조건
- create를 제외한 거의 모든 변경 작업
- 특히 delete/refactor/restructure/migrate

### 생략 조건
- 완전 신규 생성이며 기존 상태와 무관한 경우

---

## 1. Research
### 목적
- 선택지 조사
- 비교 기준 수집
- 초기 방향성 확보

### 포함 조건
- 사용자가 조사/비교/선택을 요구함
- 기술 선택 근거가 필요함
- 새로운 도메인/스택 도입이 포함됨

### 생략 조건
- 사용자가 이미 스택을 지정함
- 기존 스택 유지가 명확함
- 조사 없이 구현만 하면 됨

### 축소 규칙
- 비교 대상이 2~4개면 짧게
- 출력은 표 + 추천 정도로 제한

### 확장 규칙
- 의사결정 중요도가 크면
- 비교 기준이 많으면
- 도입 리스크가 크면

---

## 2. Decision
### 목적
- 조사 결과를 실행 가능한 선택으로 압축
- scope와 비목표를 명시

### 포함 조건
- Research가 있었음
- 구현 전에 선택 근거를 고정해야 함

### 생략 조건
- Research를 생략했고 선택이 이미 고정됨

### 출력
- contract json
- definition of done
- acceptance criteria

---

## 3. Setup
### 목적
- 패키지/빌드/엔트리/도구 설정

### 포함 조건
- 새 앱/새 모듈/새 빌드 툴 설정 필요
- 프레임워크 전환 필요

### 생략 조건
- 기존 구조가 이미 준비되어 있음
- 설정 변경이 필요 없음

### 분해 규칙
- metadata
- config
- entry
로 분리 권장

---

## 4. Skeleton
### 목적
- 최소 뼈대 파일 생성
- 타입/루트 컴포넌트/핵심 엔트리 정의

### 포함 조건
- UI/app/module 구조를 새로 세워야 함

### 생략 조건
- 기존 skeleton 유지 가능

---

## 5. Component Generation
### 목적
- 기능 단위 컴포넌트/모듈 생성

### 포함 조건
- UI 또는 코드 구조를 실제로 구현해야 함

### 생략 조건
- 문서 작업
- 설정만 바꾸는 작업

### 주의
이 phase는 SDK_8002 위험도가 높다.

### 강제 규칙
- 한 unit당 컴포넌트 1~2개
- supporting file(api/types/state)를 분리
- App wiring은 별도 unit

---

## 6. Style / Presentation
### 목적
- 레이아웃/스타일/표현 계층 구현

### 포함 조건
- UI 스타일 작업이 요구됨

### 생략 조건
- 비UI 작업
- 스타일 무관한 작업

### 분해 규칙
- base layout
- state styling
- responsive
로 분리 가능

---

## 7. Targeted Modification
### 목적
- 기존 파일 일부를 보존적으로 수정

### 포함 조건
- modify
- small refactor
- 문서/설정/코드 일부 수정

### 규칙
- surgical edit 우선
- broad rewrite 금지
- 변경 전후 영향 범위 기록

---

## 8. Refactor / Restructure
### 목적
- 구조 개선, 이동, 분리, 병합

### 포함 조건
- refactor
- restructure
- migrate

### 규칙
- 구조 변경과 내용 변경을 가능한 분리
- rename/move/delete는 영향 체크와 함께 수행
- 참조 무결성 확인 필요

---

## 9. Deletion / Prune
### 목적
- stale / obsolete 대상 제거

### 포함 조건
- delete
- prune

### 강제 보호 규칙
- 삭제 전 discovery 필수
- 참조 관계 확인
- 삭제 사유 기록
- 가능하면 대체 경로 확인

### 출력
- `deletion-plan.md`
- `deletion-summary.md`

---

## 10. Integration
### 목적
- 각 unit을 연결
- wiring, handlers, composition

### 포함 조건
- 여러 unit이 생성되었고 연결이 필요함

### 생략 조건
- 독립 파일 생성만으로 완료됨

---

## 11. Evaluation
### 목적
- 구조, 존재, 최소 요구사항 충족 여부 검증

### 포함 조건
- 거의 항상 포함

### 생략 조건
- 없음 (최소 형태로라도 유지)

### 규칙
- 구현 step과 분리
- output 형식은 작고 엄격하게 유지

---

## 12. Delivery Summary
### 목적
- 이번 실행에서 선택된 phase와 결과 요약

### 포함 조건
- 거의 항상 포함

### 출력
- phase-plan
- execution-summary
- next-actions

---

## Phase Selection Rules

Workflow는 요구사항을 읽고 아래 규칙으로 phase를 선택한다.

### 규칙 A. 기존 상태를 건드리는가?
- 그렇다면 Discovery 포함

### 규칙 B. 조사 필요 여부
- 비교/선택/근거 요청이 있으면 Research + Decision
- 아니면 생략 가능

### 규칙 C. 새 구조 필요 여부
- 새 프레임워크/새 패키지/새 앱이면 Setup 포함

### 규칙 D. 실제 구현 필요 여부
- 코드/컴포넌트/모듈 생성이면 Skeleton/Component/Integration 포함

### 규칙 E. 기존 파일 일부 수정인가?
- 그렇다면 Targeted Modification 포함

### 규칙 F. 이동/병합/분리/리팩터링인가?
- 그렇다면 Refactor / Restructure 포함

### 규칙 G. 삭제/정리인가?
- 그렇다면 Deletion / Prune 포함

### 규칙 H. UI 여부
- UI가 있으면 Style 포함
- 아니면 생략

### 규칙 I. 검증
- Evaluation은 항상 유지

---

## Expansion Rules

다음 조건이면 phase를 확장한다.
- 파일 수가 많다
- 구현 범위가 넓다
- 새 스택 도입이다
- 선택 근거가 중요하다
- 이전 실험에서 SDK_8002가 난 영역이다
- 삭제/이동 영향 범위가 넓다

확장 방식:
- phase를 더 많은 micro-units로 분해
- unit당 파일 수를 더 줄임
- integration을 별도 phase로 분리
- refactor와 modify를 분리
- deletion을 file-by-file로 축소

---

## Reduction Rules

다음 조건이면 phase를 축소한다.
- 사용자가 스택을 고정했다
- 설정이 이미 존재한다
- 스타일 변경이 필요 없다
- 문서 작업이다
- 단일 파일 수정이다
- 영향 범위가 매우 작다

축소 방식:
- Research 생략
- Decision 생략
- Setup 축소
- Style 생략
- Evaluation 최소화
- Refactor를 Targeted Modification으로 축소

---

## Failure Handling Rules

### 429 / overload
- 동일 unit 즉시 재폭주 금지
- backoff 후 재시도
- 필요하면 phase를 다음 실행으로 미룸

### SDK_8002
- 해당 unit을 더 작은 unit으로 분해
- component generation scope 축소
- multi-file unit을 file-per-unit 수준으로 축소

### deletion/restructure 실패
- destructive action 중단
- discovery/impact 결과 재검토
- 삭제를 보류하고 summary에 남김

### 반복 실패
- 해당 phase를 별도 조사 대상으로 기록
- 수동 성공으로 덮지 않음

---

## Required Runtime Artifacts

각 실행은 가능하면 다음을 남긴다.
- `goal-interpretation.md`
- `phase-plan.md` or `phase-plan.json`
- `micro-units.json`
- `execution-summary.md`
- phase별 핵심 artifact
- debug trace path
- destructive action이 있으면 `impact-notes.md` 또는 `deletion-plan.md`

---

## Workflow Requirements

이 문서를 사용하는 workflow는 다음을 만족해야 한다.
1. 사람은 요구사항만 제공한다
2. workflow는 phase plan을 동적으로 만든다
3. workflow는 micro-step execution만 수행한다
4. broad scope unit 생성 금지
5. 실패 시 축소 또는 backoff 규칙 적용
6. 최종 summary에 선택/생략된 phase를 기록한다
7. 기존 프로젝트 수정/삭제/개선도 처리 가능해야 한다
8. destructive change는 discovery/impact 확인 후에만 수행한다

---

## 결론

이 문서의 목적은 phase를 고정하는 것이 아니다.

> phase를 **정책으로 관리**하고,
> workflow가 실행 시점에 그 정책을 읽어
> 이번 작업에 맞게 **확장/축소된 실행 계획**을 만들게 하는 것이다.
