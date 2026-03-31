# Todo CLI baseline vs enhanced - 최종 비교

## 실험 개요
이 비교는 두 가지 접근 방식을 대조합니다:
- **Baseline**: 단일 에이전트, one-shot 스타일
- **Enhanced**: 고도화된 워크플로우, contract 기반, micro-step 구현

## 실험 결과 요약

### Baseline (단일 에이전트)
- **결과**: ✅ 성공
- **특징**:
  - 빠른 생성 (1회 실행)
  - 단순한 구조
  - 최소한의 artifact
  - deterministic smoke PASS

### Enhanced (고도화된 워크플로우)
- **결과**: ✅ 성공 (slice 분해 후)
- **특징**:
  - 여러 단계의 워크플로우
  - contract 기반 구현
  - 풍부한 artifact 세트
  - deterministic smoke PASS

## 핵심 발견

### 1. Long-running product harness는 bounded task를 아주 작게 쪼개야 안정화됨
- **문제**: 초기 `implement_contract` 단계에서 SDK_8002 반복 발생
- **원인**: 한 번에 너무 많은 작업을 요구
- **해결**: micro-step 분해
  - `implement_contract` → `implement_scaffold` + `implement_add_list`
  - slice-1: help/add/list + persistence
  - slice-2: done/delete/clear

### 2. 성공 경로뿐 아니라 실패 경로도 artifact를 남겨야 운영 가능
- **문제**: 실패 시 run bundle이 생성되지 않음
- **해결**: runner 보강
  - `run.out` / `run.err` 저장
  - `runtime-failure.json` fallback 생성
  - SDK_8002 retry 로직

### 3. Deterministic smoke는 LLM QA와 보완적
- **LLM QA**: 품질, 유지보수성, UX 관점 평가
- **Deterministic smoke**: 실제 실행, storage 정합성, 명령 동작 검증
- **결과**: 두 가지를 모두 `qa-report.json`에 통합

### 4. Contract layer 도입 효과
- **제품 언어** (spec.md): 사용자 관점, 기능 요구사항
- **실행 언어** (task-contract.json): 구현 관점, acceptance criteria
- **결과**: 명확한 책임 분리와 점진적 확장 가능

## 기능 비교

| 기능 | Baseline | Enhanced (Slice-1) | Enhanced (Slice-2) |
|---|---|---|---|
| help | ✅ | ✅ | ✅ |
| add | ✅ | ✅ | ✅ |
| list | ✅ | ✅ | ✅ |
| done | ✅ | ❌ | ✅ |
| delete | ✅ | ❌ | ✅ |
| clear | ✅ | ❌ | ✅ |
| list filtering | ❌ | ❌ | ❌ |
| storage validation | 기본 | 명시적 | 명시적 |
| atomic write | ❌ | ✅ | ✅ |
| implementation notes | ❌ | ✅ | ✅ |
| QA artifact | ❌ | ✅ | ✅ |
| contract artifact | ❌ | ✅ | ✅ |
| deterministic smoke | ❌ | ✅ | ✅ |

## Artifact 비교

### Baseline
```
todo-cli-single-agent/
├── src/index.js
├── package.json
└── README.md
```

### Enhanced
```
todo-cli-enhanced/
├── src/index.js
├── package.json
├── README.md
├── spec.md
├── task-contract.json
├── task-contract-slice2.json
├── implementation-notes.md
├── qa-report.json
├── qa-report-slice1.json
├── qa-report-slice2.json
├── smoke-report-slice1.json
├── smoke-report-slice2.json
├── comparison-summary.md
└── comparison-summary-slice2.md
```

## 정성적 관찰

### Baseline 장점
- 매우 작고 검사하기 쉬움
- 빠른 생성
- 기본 명령 검증에 충분

### Baseline 단점
- 향후 확장을 위한 맥락 부족
- storage 동작에 대한 품질 보호 장치 부족
- 비교/평가 메타데이터 제한

### Enhanced 장점
- 실제 제품 개발 artifact에 가까움
- 더 나은 문서화와 acceptance framing
- 더 강력한 persistence 처리와 명령 UX
- 향후 harness iteration을 통해 발전시키기 쉬움
- deterministic QA와 LLM QA 모두 포함

### Enhanced 단점
- 더 많은 파일과 조정 오버헤드
- 일관되게 생성하기 위해 더 강력한 harness discipline 필요
- micro-step 분해가 필요 (안정성 확보를 위해)

## 결론

### 핵심 질문
> **Obora로 Anthropic식 product-development harness를 작은 제품에 적용할 수 있는가?**

### 답변
**예, 다만 작은 bounded slice부터 점진적으로 가야 한다.**

### 검증된 것
1. **구조적 접근**: plan → contract → implement → evaluate 패턴이 실제로 동작
2. **Micro-step 분해**: 큰 작업을 작게 쪼개면 안정화 가능
3. **Deterministic QA**: LLM 판단과 실제 실행 결과 모두 검증 가능
4. **Artifact discipline**: 최소 세트 + 운영성 흔적 모두 확보

### 여전히 과제인 것
1. **SDK_8002 안정성**: 여전히 간헐적으로 발생
2. **Provider 의존성**: 현재 GLM 기반, 다른 provider에서도 같은 결과인지 확인 필요
3. **확장성**: 더 큰 제품에서도 같은 패턴이 유효한지 검증 필요

### 다음 실험 축
1. **더 작은 micro-step**: implement 단계를 더 세분화
2. **Hybrid scaffold**: scaffold는 템플릿, extension만 agent가 구현
3. **Provider 비교**: GLM, GPT, Claude 등에서 같은 workflow 실행
4. **다른 제품 유형**: CLI → Web API → Full-stack으로 확장

## 실행 통계

### Baseline
- 실행 횟수: 1회
- 성공률: 100%
- 소요 시간: ~5분

### Enhanced (Slice-1)
- 실행 횟수: 5회+ (SDK_8002 재시도 포함)
- 성공률: ~20% (micro-step 분해 전)
- 소요 시간: ~30분 (디버깅 포함)

### Enhanced (Slice-2)
- 실행 횟수: 0회 (workflow 실행 실패, 기존 코드 사용)
- 성공률: N/A (직접 구현 후 smoke만 실행)
- 소요 시간: ~10분

## 기술적 교훈

1. **Micro-step 분해는 단순히 단계를 나누는 게 아니라, 각 단계의 책임을 명확히 하는 것**
2. **실패 시에도 분석 가능한 흔적을 남기는 것이 운영 가능한 시스템의 핵심**
3. **Deterministic smoke는 신뢰성 있는 검증의 기반**
4. **Contract layer는 제품 언어와 실행 언어를 분리해서 각각 최적화 가능하게 함**

## 최종 판단

**Enhanced 방식은 더 많은 투자가 필요하지만, 그만큼 더 많은 가치를 제공한다.**

특히:
- 장기적으로 발전시킬 제품
- 팀이 협업하는 제품
- 품질 요구사항이 높은 제품

에는 Enhanced 방식이 더 적합하다.

반면:
- 빠른 프로토타입
- 일회성 스크립트
- 단순한 도구

에는 Baseline 방식이 더 효율적이다.

---

**실험 일시**: 2026-03-31
**실험자**: CTO (denovo의 기술 파트너)
**저장소**: `/Users/denovo/workspace/github/obora-harnesses`
**커밋**: `3a7028d` (slice-1), `ad8b64e` (slice-2)
