# Enhanced Magic 8 Ball

## Purpose
A conversational digital Magic 8 Ball (AI-skill build target). The user privately thinks of a yes-or-no question, invokes the skill, and receives one randomly selected saying from the full curated catalog. The question is never collected and never influences the outcome. (The product spec also defines web-app and mobile-app formats; those live in separate build-target repositories.)

## Source of Truth
- `Magic 8 Ball -- Product Spec.md` — complete product requirements (all formats; this repo implements the AI-skill column)
- `Magic 8 Ball -- Approved Idle UI Concept.png` — approved visual reference shared across product variants; not used in this text-only build
- `README.md` — skill experience summary
- `AGENTS.md` (repo) — skill agent delivery contract

## Architecture
- **Format:** AI skill, text only — the user invokes the ball in conversation; the skill returns one randomly selected saying as plain text (no images, no animations)
- **Skill shape:** opencode skill — `SKILL.md` (frontmatter `name`/`description`) plus a bundled Node selection script and catalog data
- **Invocation:** explicit conversational ask — trigger phrases include "Magic 8 ball?", "What does the magic 8 ball think?", "What does the magic 8 ball say?"; no question text is collected or requested
- **Randomness:** true OS entropy from the bundled script (the model never improvises answers); category selected at 50% affirmative / 25% noncommittal / 25% negative, then a uniform no-repeat selection within the category
- **Cycle:** fresh no-repeat cycle per conversation/invocation; no answer-state persistence between conversations; no user-facing reset
- **Output:** the selected saying only, original capitalization preserved — never its category, theme, source, outcome label, analysis, or a disclaimer
- **Catalog:** bundled JSON theme packs (original 20 + Sarcastic, Surfer, Sports, Weather, Tech, Movie-Inspired, Rock-Inspired); full 101-saying catalog (42 yes / 28 maybe / 31 no)
- **Privacy:** no question text, analytics, telemetry, or identifiers; no network access

## Status
**Version:** 0.0.0
**Phase:** Scaffolded. Product requirements and design direction complete; implementation pending.

## Repository
Source of truth: https://github.com/JohnHoaglun/Enhanced-Magic-8-Ball-Skill
Branch: `main`

## Credentials
N/A — no credentials required (fully local, offline skill)
