# Polysona First Modify-Safe Pilot

## Summary

The first realistic `modify-safe` pilot on `polysona` should target:
- `skills/content/SKILL.md`
- `skills/interview/SKILL.md`

The pilot should remain extremely conservative:
- exact replace only
- one sentence or one bullet at a time
- no structural rewrite
- no semantic expansion
- readability improvement only

---

## Proposed first patches

### File 1: `skills/content/SKILL.md`
Best first patch:
- `confirmed saved path` → `confirmed saved file path`

Why:
- sharper output contract wording
- minimal semantic risk
- exact-replace friendly

### File 2: `skills/interview/SKILL.md`
Best first patch:
- `appends results` → `appends the results`

Why:
- bounded wording refinement
- preserves behavior and policy meaning
- exact-replace friendly

---

## Why these first

These two patches satisfy the current modify-safe baseline best:
1. concrete single files
2. exact text replacement possible
3. low runtime risk
4. low semantic blast radius
5. no cross-file coupling

---

## Recommended next step

If proceeding beyond dry-run, apply one exact-replace patch per file and verify the resulting text only.
Do not batch multiple wording changes into one first pilot.
