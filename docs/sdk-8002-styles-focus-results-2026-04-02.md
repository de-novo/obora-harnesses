# SDK_8002 Styles-Focus Results — 2026-04-02

## 한줄 결론

styles 단계가 직접 원인이라는 가설은 약해졌다.
오히려 **component generation 단계 또는 component-rich setup 이후의 generator workload**가 더 유력한 원인 후보로 올라왔다.

---

## 실행 결과

| workflow | 목적 | 결과 |
|---|---|---|
| styles-only-heavy | heavy style migration 단독 | success |
| components-plus-styles | setup + components + styles | failed (SDK_8002 at migrate_components) |
| styles-ladder-small | small style write | success |
| styles-ladder-medium | medium style write | incomplete due outer session termination |

---

## 핵심 관찰

### 1. heavy styles 단독은 성공
- `styles-only-heavy` 에서 heavy style migration은 성공
- `migrate_styles_heavy` step duration은 138초였음
- 즉, 스타일 생성이 오래 걸린다는 사실만으로 SDK_8002가 발생하지는 않음

### 2. components-plus-styles 는 `migrate_components`에서 실패
- `setup_minimal_context` 는 성공
- `migrate_components` 시작 후 `SDK_8002 / Execution cancelled`
- styles step까지 도달하지도 못함

### 3. small style write는 성공
- 가벼운 style write는 정상

---

## 해석

이 결과는 이전 가설을 수정하게 만든다.

기존 가설:
- migrate_styles 단계가 핵심일 수 있다

수정된 가설:
- **component generation 단계**가 더 핵심일 가능성
- 혹은 setup 이후 component-rich generation workload가 핵심일 가능성

즉,
문제는 styles 자체보다:
- 여러 컴포넌트 파일 동시 생성
- 서비스/api/types까지 포함한 다중 파일 생성
- component 구조 설계 + 구현을 한 step에서 처리하는 generator 부담
에 가까워 보인다.

---

## 현재 가장 유력한 원인 후보

1. **다중 파일 component generation workload**
2. **component structure + implementation + supporting files(api/types) 동시 생성**
3. **generator step 하나에 걸린 구현 범위가 넓을 때 발생하는 cancellation**

---

## 다음 추천 실험

### 1. components ladder
- small: 1 component file
- medium: 3 component files
- heavy: 3 components + api + types + app

### 2. split-components repro
- TodoForm / TodoList / TodoItem 을 step별로 분리
- 한 step당 파일 1~2개만 생성
- 목적: file-count vs step-scope 분리

### 3. same-files smaller-prompts repro
- 생성 파일 수는 유지
- 프롬프트를 짧게 압축
- 목적: instruction density vs output scope 분리

---

## 결론

현재까지의 strongest signal은 이것이다.

> SDK_8002는 styles 단계 단독 문제라기보다,
> **component generation scope가 넓은 generator 단계**에서 더 잘 나타난다.

따라서 다음 단계는 styles 축이 아니라 **components 축 ladder / split repro** 로 가는 것이 맞다.
