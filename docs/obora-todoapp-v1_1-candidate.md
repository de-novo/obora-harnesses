# Obora TodoApp Baseline v1.1 Candidate

## Goal

Find one low-risk **multi-paragraph bounded replace** candidate on `obora-todoapp`.

---

## Candidate

### File
`docs/architecture/ARCHITECTURE-v1.md`

### Current block
`Taskify는 개인 및 팀의 생산성 향상을 위한 현대적인 태스크 관리 애플리케이션입니다. 프로젝트 관리, 태그 기반 분류, 마크다운 지원 등을 통해 효율적인 업무 관리를 지원합니다.`

`**본 문서는 Phase 1 MVP 범위를 중심으로 작성되었습니다.**`

### Proposed block
`Taskify는 개인과 팀의 생산성 향상을 위한 현대적인 태스크 관리 애플리케이션입니다. 프로젝트 관리, 태그 기반 분류, 마크다운 지원 등을 통해 효율적인 업무 관리를 돕습니다.`

`**본 문서는 Phase 1 MVP 범위를 중심으로 정리되었습니다.**`

### Why it is safe
- one contiguous multi-paragraph block inside `개요`
- wording refinement only
- architecture meaning preserved
- no structural reorder
- no runtime or implementation claim change

## Recommendation

Use this as the second Baseline v1.1 proof.
It is bounded, documentation-only, and lower risk than runtime-adjacent README command sections.
