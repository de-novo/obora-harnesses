# Obora TodoApp Dry-Run Candidate Zones

## Review-Ready Candidate Zones

### 1. `README.md`
이유:
- user-facing entry doc
- workflow 설명 / 실행 방법 / 구조 설명이 잘 나뉘어 있음
- single-file bounded modify 후보를 고르기 좋음

### 2. `docs/prd/*.md`
이유:
- 긴 문서이지만 명확한 heading 구조 존재
- wording/consistency review 대상로 적합

### 3. `docs/architecture/*.md`
이유:
- 구조화된 heading/section 풍부
- explanation clarity review 대상로 적합

### 4. `docs/plan/*.md`
이유:
- 계획 문서라 표현 일관성 후보가 나올 가능성 높음

### 5. `docs/task/*.md`
이유:
- 구현 문서지만 승인 문서라 docs lane으로 분류 가능

---

## Hold Zones

### 1. `.obora/**`
이유:
- runtime/workflow engine core

### 2. `scripts/run-workflow.sh`
이유:
- 실행 의미 직접 영향

### 3. `src/**`
이유:
- code/runtime lane

### 4. workflow YAML / provider config
이유:
- docs-first baseline 범위 밖
