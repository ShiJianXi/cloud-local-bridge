// Self-check for wiki.html: `node skills/orchestrator-wiki/test_wiki_page.mjs` from the plugin root.
// Runs the page's script against a tiny fake DOM and a fake db, then checks what it shows.
import { readFileSync } from "node:fs";
import assert from "node:assert/strict";

const html = readFileSync(new URL("./wiki.html", import.meta.url), "utf8");
const script = html.match(/<script>([\s\S]*)<\/script>/)[1];

class Node {
  constructor(tag) { this.tag = tag; this.kids = []; this.text = ""; this.hidden = false; }
  append(...k) { this.kids.push(...k.map((x) => (typeof x === "string" ? Object.assign(new Node("#text"), { text: x }) : x))); }
  replaceChildren() { this.kids = []; }
  set textContent(v) { this.text = String(v); this.kids = []; }
  get textContent() { return this.text + this.kids.map((k) => k.textContent).join(" "); }
}
const ids = {};
for (const [, id] of html.matchAll(/id="([\w-]+)"/g)) ids[id] = new Node("div");
const document = {
  getElementById: (id) => ids[id],
  createElement: (t) => new Node(t),
  createTextNode: (t) => Object.assign(new Node("#text"), { text: t }),
};

function run(wiki, pages) {
  const snap = (docs) => ({ docs: Object.entries(docs).map(([id, v]) => ({ id, data: () => v })) });
  const db = {
    collection: (name) => ({
      onSnapshot: (cb) => cb(snap(name === "wiki" ? wiki : name === "pages" ? pages : {})),
      orderBy: () => ({ limit: () => ({ onSnapshot: (cb) => cb(snap({})) }) }),
    }),
  };
  const window = { claude: { use: async () => db } };
  new Function("window", "document", "setTimeout", "clearTimeout", script)(window, document, () => 0, () => {});
  return new Promise((r) => setImmediate(r));
}

// A wiki with a review, a learned rule and two archive months.
await run(
  {
    meta: { domain: "Billing", orchestrator: "Billing lead", format: 3 },
    review: { at: "2026-11-04T09:00:00Z", changed: ["Archived 2 gotchas."], proposals: [{ text: "Make no-draft PRs a rule", why: "You said it twice." }] },
    "archive-2026-10": { month: "2026-10", items: [{ at: "2026-10-30", from: "gotchas", reason: "Not hit in 30 days.", item: { topic: "CI", text: "Lockfile drifts" } }] },
    "archive-2026-11": { month: "2026-11", items: [] },
  },
  { charter: { summary: "Own billing.", rules: ["No drafts"], learned: [{ text: "Run npm ci before pushing", why: "Lockfile CI failed 3 times." }] } },
);
const t = (id) => ids[id].textContent;
assert.equal(t("domain"), "Billing");
assert.match(t("charter"), /Learned rules.*Run npm ci before pushing.*Lockfile CI failed 3 times/s);
assert.equal(ids["review-s"].hidden, false);
assert.match(t("review"), /Archived 2 gotchas/);
assert.equal(ids.ask.hidden, false);
assert.match(t("ask-list"), /Review proposal: Make no-draft PRs a rule/);
assert.equal(ids["archive-s"].hidden, false);
assert.match(t("archive"), /2026-11 · 0 items.*2026-10 · 1 item\b.*Gotcha.*Lockfile drifts.*Not hit in 30 days/s);

// A format 2 wiki: no review, no archive, nothing extra shown.
await run({ meta: { domain: "Docs", format: 2 } }, { charter: { summary: "Own docs.", rules: [] } });
assert.equal(ids["review-s"].hidden, true);
assert.equal(ids["archive-s"].hidden, true);
assert.equal(ids.ask.hidden, true);
assert.doesNotMatch(t("charter"), /Learned rules/);

console.log("wiki page: ok");
