# Obora DX Execution Plan

## 목표

Obora의 초기 통합 경험을 개선하여,
다음 상태를 만든다.

1. 실행 전 resolution이 보인다
2. 실패 원인이 짧게 드러난다
3. judge 같은 단건 inference는 얇게 붙일 수 있다
4. structured input/output path가 더 명시적이다

---

## Track A. Resolution Summary

### Deliverables
- resolution summary output spec
- source precedence table
- execution start summary

### First implementation target
- provider
- model
- auth source
- config source
- fallback/stub flag

### Done when
실행 전에 사용자가 실제 provider/model/auth source를 볼 수 있다.

---

## Track B. Diagnostics Taxonomy

### Deliverables
- error code map
- message templates
- short-path diagnostics

### First implementation target
- unsupported model
- missing auth
- fallback to stub
- unresolved binding

### Done when
실패 시 사용자가 원인과 fix 방향을 한 번에 이해할 수 있다.

---

## Track C. Judge Mode Prototype

### Deliverables
- minimal judge mode spec
- example workflow or command
- JSON input/output sample

### First implementation target
- one-step inference
- optional output schema
- direct result path

### Done when
신규 사용자가 JSON→JSON judge task를 workflow 이해 없이 실행할 수 있다.

---

## Track D. Input Binding Contract

### Deliverables
- binding contract draft
- explicit bindings syntax proposal
- prompt preview or input preview

### First implementation target
- input.json
- input.schema
- output.schema
- output.path

### Done when
step author가 input/task 외에도 contract-first로 작성 가능하다.

---

## Track E. Documentation Refresh

### Deliverables
- judge quickstart
- workflow quickstart
- troubleshooting guide
- JSON in/out recipe

### Done when
새 사용자가 quickstart 하나만 따라도 first success를 낼 수 있다.

---

## Implementation Sequence

### Step 1
Resolution summary spec

### Step 2
Diagnostics taxonomy spec

### Step 3
Judge mode minimal spec

### Step 4
Resolution + diagnostics 구현

### Step 5
Judge mode prototype

### Step 6
Binding contract 개선 초안

### Step 7
Docs refresh

---

## Validation Scenarios

1. wrong model ref를 넣으면 즉시 unsupported model 진단이 나오는가
2. auth가 없으면 fallback/stub 이유가 바로 보이는가
3. json input → json output judge sample이 10분 내 성공 가능한가
4. binding source를 step 기준으로 설명 가능한가

---

## Immediate Next Deliverable

다음 바로 만들 문서는 아래 3개가 적절하다.

1. `obora-resolution-summary-spec.md`
2. `obora-diagnostics-taxonomy.md`
3. `obora-judge-mode-spec.md`
