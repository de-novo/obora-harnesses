# Modify Concretization Policy

## 목적

`modify-safe v1`이 실제 exact-replace 가능한 입력을 받으려면,
modify unit이 glob/wildcard 수준이 아니라 **concrete file path 수준**으로 먼저 좁혀져야 한다.

이 정책은 그 중간 단계인 `modify concretization`의 기준을 정의한다.

---

## 문제 정의

현재 modify unit은 다음처럼 추상적일 수 있다.

- `docs/**/*.md`
- `scripts/**/*.sh`
- `*`

이 표현은 planning 단계에는 유용하지만,
actual modify-safe apply 단계에는 너무 broad 하다.

즉 applier는 다음이 필요하다.
- 실제 파일 경로
- 단일 파일 기준
- 수정 후보 우선순위
- exact replace 가능성 판단 근거

---

## 목표 출력

concretization 결과는 아래를 만들어야 한다.

1. concrete single-file modify candidates
2. 각 candidate의 source unit id
3. 왜 이 파일이 선택되었는지 근거
4. candidate별 risk/priority
5. exact-replace readiness 여부

---

## 허용 규칙

concretization은 다음만 수행한다.

- glob/pattern을 실제 파일 후보 목록으로 축소
- 후보를 single-file 단위로 분해
- broad modify를 smaller file-level units로 재구성

concretization은 다음을 하지 않는다.

- 실제 파일 수정
- destructive apply
- multi-file combined patch generation

---

## selection rules

우선순위가 높은 candidate:
1. 명시적 문서 파일 (`README.md`, `docs/foo.md`)
2. 명시적 workflow 파일 (`.github/workflows/x.yaml`)
3. 명시적 script 파일 (`scripts/x.sh`, `scripts/x.py`)
4. broad wildcard 매칭 결과 중 작은 파일

제외 대상:
- binary file
- generated file
- vendor/dependency file
- lockfile
- directory path
- wildcard 자체 (`*`)

---

## candidate shape

각 concrete candidate는 최소 아래 형태를 가진다.

```json
{
  "unitId": "u17",
  "sourcePattern": "docs/**/*.md",
  "targetFile": "docs/architecture.md",
  "reason": "Matches pattern and is a concrete markdown doc candidate",
  "priority": "high|medium|low",
  "exactReplaceReady": false
}
```

---

## 핵심 원칙

- planning의 broadness는 concretization에서 줄인다
- applier에서 broad pattern을 직접 해석하지 않는다
- actual modify-safe apply 전에는 반드시 concrete file layer를 거친다
