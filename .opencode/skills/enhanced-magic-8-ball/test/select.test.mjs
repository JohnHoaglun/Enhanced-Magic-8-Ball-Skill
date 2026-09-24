import { test } from "node:test";
import assert from "node:assert/strict";
import { readdirSync, readFileSync } from "node:fs";
import { execFileSync } from "node:child_process";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const here = dirname(fileURLToPath(import.meta.url));
const skillDir = join(here, "..");
const catalog = JSON.parse(readFileSync(join(skillDir, "catalog.json"), "utf8"));
const A = catalog.answers;
const ALL = [...A.yes, ...A.maybe, ...A.no];

const seq = (vals) => {
  let i = 0;
  return () => vals[i++];
};

const { select } = await import(join(skillDir, "select.mjs"));

test("catalog integrity: 101 sayings, 42 yes / 28 maybe / 31 no", () => {
  assert.equal(A.yes.length, 42);
  assert.equal(A.maybe.length, 28);
  assert.equal(A.no.length, 31);
  assert.equal(ALL.length, 101);
  for (const list of [A.yes, A.maybe, A.no]) {
    for (const s of list) {
      assert.equal(typeof s, "string");
      assert.ok(s.trim().length > 0);
    }
  }
});

test("weighting: r < 0.5 selects yes", () => {
  assert.equal(select(seq([0.499, 0])), A.yes[0]);
});

test("weighting: r in [0.5, 0.75) selects maybe", () => {
  assert.equal(select(seq([0.5, 0])), A.maybe[0]);
  assert.equal(select(seq([0.6, 0])), A.maybe[0]);
});

test("weighting: r >= 0.75 selects no", () => {
  assert.equal(select(seq([0.75, 0])), A.no[0]);
  assert.equal(select(seq([0.999, 0])), A.no[0]);
});

test("within-category index is uniform over the category", () => {
  assert.equal(select(seq([0.9, 0.5])), A.no[15]);
  assert.equal(select(seq([0.4, 0.99])), A.yes[41]);
  assert.equal(select(seq([0.7, 1 / 28]), A), A.maybe[1]);
});

test("CLI prints exactly one catalog saying plus one newline", () => {
  const out = execFileSync(process.execPath, [join(skillDir, "select.mjs")], {
    encoding: "utf8",
  });
  assert.ok(out.endsWith("\n") && !out.endsWith("\n\n"), "single trailing newline");
  const line = out.slice(0, -1);
  assert.ok(!line.includes("\n"), "no interior newlines");
  assert.ok(ALL.includes(line), `output must be a catalog saying, got: ${line}`);
});

test("CLI is stateless: creates or removes no files", () => {
  const before = readdirSync(skillDir, { recursive: true }).sort();
  execFileSync(process.execPath, [join(skillDir, "select.mjs")], { encoding: "utf8" });
  assert.deepEqual(readdirSync(skillDir, { recursive: true }).sort(), before);
});
