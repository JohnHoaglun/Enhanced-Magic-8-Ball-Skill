# PLAN.md — Enhanced Magic 8 Ball (Skill)

Target version: 0.0.1 · Status: approved (2026-09-24)

## Objective
Implement the AI-skill build target as an opencode skill: a **text-only** conversational
Magic 8 Ball. It triggers on the pinned phrases, runs a bundled selection script
(Node, true OS entropy), and the model returns the script's stdout verbatim — exactly one
saying from the 101-saying catalog, weighted 50/25/25. No question collection, no images,
no animations, no state persistence.

## Strategy
Solo implementation of one indivisible unit:

- `.opencode/skills/enhanced-magic-8-ball/SKILL.md` — frontmatter (`name` matching folder;
  `description` front-loading the pinned trigger phrases) plus strict instructions: run the
  selection script, reply with its stdout and nothing else; never improvise, paraphrase,
  label, or ask for the question.
- `.opencode/skills/enhanced-magic-8-ball/select.mjs` — zero-dependency Node: loads
  `catalog.json` from its own directory; picks the category by weight
  (`r < 0.5` yes, `r < 0.75` maybe, else no), then uniformly within the category; prints
  exactly the saying + one newline. No state, no network.
- `.opencode/skills/enhanced-magic-8-ball/catalog.json` — copied byte-for-byte from the web
  sibling (`Enhanced Magic 8 Ball/src/data/catalog.json`): 101 sayings, 42 yes / 28 maybe /
  31 no.
- `.opencode/skills/enhanced-magic-8-ball/test/select.test.mjs` — node:test, zero deps.
- `scripts/verify.sh` — canonical verification entry point (gates below).

Docs in the same commit: PROJECT.md (status 0.0.1), TODOS.md, SUMMARY.md,
VERSIONS_LOCATIONS.md (registers the new `metadata.version` location).

## Parallelization decision
Independent parts enumerated: (1) SKILL.md, (2) select.mjs, (3) catalog.json, (4) tests,
(5) verify.sh. All five share one unpinned surface — the exact CLI/stdout contract of
select.mjs and the exact catalog shape — which every other file depends on, and the total
work is a few hundred lines.

**Decision: no parallel agents — solo work.** Decomposability blockers: single global pass
(skill definition ↔ script contract ↔ catalog verification is one atomic unit) and work
below delegation overhead.

## Shared surfaces
Single lane — no cross-lane surfaces. The internal contract is pinned as testable
invariants (each is a gate):

1. **Catalog integrity** — `catalog.json` parses; `answers.yes|maybe|no` are string arrays;
   counts 42/28/31; total 101; byte-identical to the web sibling source file.
2. **Weighting** — with an injected deterministic RNG: `r < 0.5` → yes, `r < 0.75` → maybe,
   else no; within-category index is uniform over that category. `select.mjs` exports
   `select(rng, answers)` for tests; the CLI entry uses `node:crypto` OS entropy.
3. **Output purity** — CLI stdout is exactly the saying plus one trailing newline; nothing
   else (no quotes, labels, disclaimers, extra whitespace).
4. **Statelessness** — running select.mjs creates or modifies no files; every invocation
   is a fresh cycle (spec: fresh no-repeat cycle per conversation/invocation).
5. **Frontmatter** — `name` is `enhanced-magic-8-ball` and matches the folder name;
   `description` is non-empty and contains all three pinned trigger phrases: "Magic 8
   ball?", "What does the magic 8 ball think?", "What does the magic 8 ball say?".
6. **Distribution** — 10,000 draws with real entropy: yes 45–55%, maybe 17–33%, no 17–33%.
7. **Test:production ratio** — test lines ≤ 75% of hand-maintained production lines
   (production = select.mjs + catalog.json; test = test/select.test.mjs).

## Gate (stop condition)
`bash scripts/verify.sh` green (invariants 1–7) → version bump 0.0.0 → 0.0.1 at every
registered location + grep for stale 0.0.0 → one atomic commit (code, tests, docs) → push
to `origin/main`.

## Blockers
(None.)
