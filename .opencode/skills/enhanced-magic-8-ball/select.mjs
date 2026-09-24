import { readFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
import { randomInt } from "node:crypto";

const here = dirname(fileURLToPath(import.meta.url));
const catalog = JSON.parse(readFileSync(join(here, "catalog.json"), "utf8"));

export const cryptoRng = () => randomInt(1_000_000_000) / 1_000_000_000;

export function select(rng, answers = catalog.answers) {
  const r = rng();
  const key = r < 0.5 ? "yes" : r < 0.75 ? "maybe" : "no";
  const list = answers[key];
  return list[Math.floor(rng() * list.length)];
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  process.stdout.write(select(cryptoRng) + "\n");
}
