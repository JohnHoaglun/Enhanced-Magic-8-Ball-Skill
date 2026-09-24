#!/usr/bin/env bash
# Canonical local verification entry point.
set -euo pipefail
cd "$(dirname "$0")/.."

SKILL=".opencode/skills/enhanced-magic-8-ball"
CATALOG_SHA="202d84e9146a3a39e06059a3cfaa921530c1df3337f3ed8af663a8d3a9043620"

echo "== 1. catalog integrity (counts + byte-identity) =="
node --input-type=module -e "
import { readFileSync } from 'node:fs';
const c = JSON.parse(readFileSync('$SKILL/catalog.json', 'utf8'));
const [y, m, n] = [c.answers.yes, c.answers.maybe, c.answers.no];
const ok = (cond, msg) => { if (!cond) { console.error('FAIL: ' + msg); process.exit(1); } };
ok(Array.isArray(y) && y.length === 42, 'yes count 42, got ' + y.length);
ok(Array.isArray(m) && m.length === 28, 'maybe count 28, got ' + m.length);
ok(Array.isArray(n) && n.length === 31, 'no count 31, got ' + n.length);
ok(y.length + m.length + n.length === 101, 'total 101');
ok([...y, ...m, ...n].every(s => typeof s === 'string' && s.trim().length > 0), 'all sayings are non-empty strings');
console.log('ok: 101 sayings (42/28/31)');
"
ACTUAL_SHA="$(shasum -a 256 "$SKILL/catalog.json" | cut -d' ' -f1)"
[ "$ACTUAL_SHA" = "$CATALOG_SHA" ] || { echo "FAIL: catalog.json does not match pinned catalog hash"; exit 1; }
echo "ok: catalog.json matches pinned hash (byte-identical to web sibling source)"

echo "== 2. deterministic tests =="
node --test "$SKILL/test/"

echo "== 3. output purity (CLI emits exactly the saying) =="
OUT="$(node "$SKILL/select.mjs")"
node --input-type=module -e "
import { readFileSync } from 'node:fs';
const c = JSON.parse(readFileSync('$SKILL/catalog.json', 'utf8'));
const all = [...c.answers.yes, ...c.answers.maybe, ...c.answers.no];
const out = process.argv[1];
const ok = (cond, msg) => { if (!cond) { console.error('FAIL: ' + msg); process.exit(1); } };
ok(all.includes(out), 'CLI output is exactly a catalog saying');
console.log('ok: CLI output pure: ' + JSON.stringify(out));
" "$OUT"

echo "== 4. 10k-draw distribution (yes 45-55%, maybe/no 17-33%) =="
node --input-type=module -e "
import { select, cryptoRng } from './$SKILL/select.mjs';
const n = 10000; const c = { yes: 0, maybe: 0, no: 0 };
for (let i = 0; i < n; i++) { const r = cryptoRng(); c[r < 0.5 ? 'yes' : r < 0.75 ? 'maybe' : 'no']++; }
const ok = (cond, msg) => { if (!cond) { console.error('FAIL: ' + msg); process.exit(1); } };
ok(c.yes >= 4500 && c.yes <= 5500, 'yes ' + c.yes + ' outside 45-55%');
ok(c.maybe >= 1700 && c.maybe <= 3300, 'maybe ' + c.maybe + ' outside 17-33%');
ok(c.no >= 1700 && c.no <= 3300, 'no ' + c.no + ' outside 17-33%');
console.log('ok: ' + c.yes + ' yes / ' + c.maybe + ' maybe / ' + c.no + ' no');
"

echo "== 5. SKILL.md frontmatter (name matches folder; description carries trigger phrases) =="
node --input-type=module -e "
import { readFileSync } from 'node:fs';
const t = readFileSync('$SKILL/SKILL.md', 'utf8');
const m = t.match(/^---\r?\n([\s\S]*?)\r?\n---/);
const ok = (cond, msg) => { if (!cond) { console.error('FAIL: ' + msg); process.exit(1); } };
ok(m, 'frontmatter block present');
const fm = m[1];
ok(/^name: enhanced-magic-8-ball$/m.test(fm), 'name is enhanced-magic-8-ball (matches folder)');
ok(fm.includes('description:'), 'description present');
for (const p of ['Magic 8 ball?', 'What does the magic 8 ball think?', 'What does the magic 8 ball say?'])
  ok(fm.includes(p), 'description carries trigger phrase: ' + p);
console.log('ok: frontmatter valid');
"

echo "== 6. test:production ratio <= 75% =="
PROD=$(( $(wc -l < "$SKILL/select.mjs") + $(wc -l < "$SKILL/catalog.json") ))
TESTS="$(wc -l < "$SKILL/test/select.test.mjs")"
node --input-type=module -e "
const [prod, tests] = process.argv.slice(1).map(Number);
if (tests > 0.75 * prod) { console.error('FAIL: test lines ' + tests + ' exceed 75% of production ' + prod); process.exit(1); }
console.log('ok: ' + tests + ' test lines <= 75% of ' + prod + ' production lines');
" "$PROD" "$TESTS"

echo "ALL CHECKS PASSED"
