# Discovery Materialization Policy

## 목적

modify concretizer가 glob/pattern 기반 modify unit을 concrete file shortlist로 내리려면,
실행 디렉토리 내부에 discovery inventories가 반드시 존재해야 한다.

필수 inventories:
- `artifacts/discovery/tree-structure.md`
- `artifacts/discovery/documentation-catalog.md`
- `artifacts/discovery/workflow-inventory.md`
- `artifacts/discovery/script-inventory.md`

---

## 문제

현재 concretizer는 discovery artifacts가 없으면 review-ready까지만 만들고,
`targetFile`을 `null`로 둘 수밖에 없다.

즉 문제는 concretizer 자체보다,
**concretizer 입력의 materialization 보장 부재**다.

---

## 원칙

1. concretizer는 외부 경로나 가정에 의존하지 않는다.
2. 필요한 discovery inventories는 실행 전 또는 선행 step에서 생성/주입한다.
3. discovery inventories가 없으면 concrete shortlist를 만들 수 없다고 명시한다.
4. actual modify-safe 흐름 전에는 discovery materialization이 baseline prerequisite다.

---

## 권장 구조

### Option A. pre-step generation
concretizer 앞에 `materialize_discovery_inventories` step을 둔다.

### Option B. separate workflow
별도 discovery workflow가 inventories를 만들고,
concretizer는 그 산출물을 소비한다.

현재는 Option A가 더 단순하다.

---

## 결과 목표

discovery materialization 이후 concretizer는 다음을 할 수 있어야 한다.
- docs pattern → concrete markdown files shortlist
- workflows pattern → concrete workflow files shortlist
- scripts pattern → concrete script files shortlist
