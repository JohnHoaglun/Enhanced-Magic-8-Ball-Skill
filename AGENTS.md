# Skill Agent Delivery Contract

This repository is the **AI skill** build target for Enhanced Magic 8 Ball. Treat the product
specification, README, and approved visual reference as source of truth. Do not invent
requirements.

## Delivery loop

For every completed, file-changing delivery:

1. Inspect `git status`, existing documentation, current implementation, and relevant issues.
2. Make the smallest coherent change that satisfies the accepted task.
3. Update documentation whose factual state changed: `PROJECT.md`, `PLAN.md`, `TODOS.md`, `SUMMARY.md`.
4. Run verification appropriate to the change (`scripts/verify.sh` once it exists).
5. Review the diff and confirm no unrelated user changes are included.
6. Commit code, tests, and documentation together.
7. Push to the configured remote. If no remote exists or push fails, state that clearly.

A task is complete only when its relevant checks have passed or a concrete blocker is recorded in `PLAN.md`.

## Bootstrap requirements

Before the first implementation delivery, create these files if absent:

- `scripts/verify.sh` — canonical local verification entry point (catalog integrity + draw tests)
- Version bump per the versioning rules below (first build: 0.0.0 → 0.0.1)

## Skill implementation rules

- Implement the deliverable as an opencode skill: a `SKILL.md` in its own folder named after
  the skill (`.opencode/skills/<name>/SKILL.md` for project scope; `~/.config/opencode/skills/<name>/SKILL.md`
  for global scope). Frontmatter requires `name` (lowercase hyphen-separated, ≤64 chars,
  matching the folder name) and `description` (third person; covers what the skill does AND
  when to trigger it; front-load the literal trigger phrases users will say). Skills without
  a description are filtered out and never surfaced.
- Answers must be produced by a bundled deterministic helper script using true OS entropy —
  the model must never improvise, paraphrase, or weight a saying itself. `SKILL.md` must
  instruct the model to run the script and return its output verbatim as the entire reply.
- Build to the AI-skill requirements in `Magic 8 Ball -- Product Spec.md`: explicit
  conversational "ask" invocation (e.g. "ask the ball"); no question text is collected or
  requested; plain-text answer is the accessibility baseline; an optional ball image or
  animation only if the host supports it.
- Preserve the 50% affirmative / 25% noncommittal / 25% negative weighting: select the
  outcome category by weight, then draw uniformly from that category. Never use the user's
  question to select, weight, or generate an answer.
- No-repeat deck within a cycle: start a fresh cycle for each conversation/invocation; do not
  persist answer-deck state between conversations; no user-facing reset control.
- Return only the selected saying with its original capitalization — never its category,
  theme, source pack, outcome label, analysis, or any disclaimer text.
- Collect no question text, analytics, telemetry, usage events, or identifiers.
- Keep the saying catalog as data (JSON theme packs) separate from code. The complete
  built-in catalog (original 20 + Sarcastic, Surfer, Sports, Weather, Tech, Movie-Inspired,
  and Rock-Inspired packs — 101 sayings) ships with the skill; no theme selector at launch.
- Keep production behavior testable with a deterministic seam (injectable RNG, in-memory
  fixtures); no network access of any kind.

## Verification and versioning

Discover the existing tooling before choosing commands; never guess a tool or package name.
Keep `scripts/verify.sh` as the canonical local verification entry point once created.

`VERSIONS_LOCATIONS.md` is the canonical version registry. The version is a semantic version,
incremented by exactly +0.0.1 for each file-changing delivery: update every registered
location, grep the repo for the old version, and record the change in `SUMMARY.md`. If new
files carry version references (e.g. skill metadata), register them in the same change set.

## Git safety

- Never force-push, rewrite history, destructively reset, or discard unrelated working-tree changes.
- Never commit secrets, build artifacts, or editor/OS junk files.
- Use one atomic commit per completed delivery.
