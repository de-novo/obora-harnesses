# Third Real Repo Candidate Decision

## Decision

The third real repo replication target should be **`plant-companion`**.

---

## Why not `pencil-skill` first?

`pencil-skill` is still a viable future target, but it is less ideal as the immediate third replication repo because:
- it has strong README + scripts, but no `docs/` directory
- the docs-first lane is narrower
- modify gradient would rely more heavily on README + SKILL/spec style content only

This is not bad, but it gives us less surface diversity for the next proof.

---

## Why `plant-companion` is better now

`plant-companion` has:
- `README.md`
- `docs/architecture.md`
- `docs/local-smoke-flow.md`
- `docs/stack.md`
- `scripts/`
- `apps/`
- `device/`
- `services/`
- `packages/`

This makes it a stronger third replication target because:
1. docs-first lane is clearly present
2. hold lane is clearly separable (`apps/`, `device/`, `services/`, `packages/`, scripts)
3. there are multiple real documentation files for exact-replace / block / paragraph replace
4. repo shape differs from both `polysona` and `obora-todoapp`

---

## Replication value

- `polysona` = mixed-surface repo
- `obora-todoapp` = workflow/docs-heavy repo
- `plant-companion` = product/app/device/service monorepo with explicit docs lane

This makes `plant-companion` a better third data point for cross-repo generalization.

---

## Recommended next scope

### include
- `README.md`
- `docs/*.md`

### hold
- `apps/**`
- `device/**`
- `services/**`
- `packages/**`
- `scripts/**`
- infra/runtime/config layers

---

## Recommendation

Proceed with `plant-companion` as repo #3 for baseline replication.
