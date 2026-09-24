# Project Summary: Enhanced Magic 8 Ball (Skill)
## 📝 Overview
Conversational Magic 8 Ball as an opencode AI skill — full 101-saying catalog, 50/25/25 outcome weighting, fresh no-repeat cycle per conversation, no question collection.
## 📈 Change Log
- [2026-09-24 08:35] [Build] - v0.0.1 — Implemented the opencode skill `.opencode/skills/enhanced-magic-8-ball/`: `SKILL.md` (frontmatter with the three pinned trigger phrases; strict text-only answer contract), `select.mjs` (50/25/25 weighted selection via `node:crypto` OS entropy, uniform within category, stateless, zero dependencies), `catalog.json` (101 sayings, 42/28/31 — byte-identical to the web sibling source, hash pinned in `scripts/verify.sh`); 7 deterministic tests; `scripts/verify.sh` gates (catalog integrity, weighting, output purity, 10k-draw distribution, frontmatter, test:production ratio 51.1%)
- [2026-09-24 08:10] [Init] - v0.0.0 — Project created from `JohnHoaglun/Enhanced-Magic-8-Ball-Skill` (`main`); rewrote the repo AGENTS.md from the iOS template to a skill delivery contract; scaffolded project docs (PROJECT.md, VERSIONS_LOCATIONS.md, SUMMARY.md, TODOS.md) at baseline 0.0.0
