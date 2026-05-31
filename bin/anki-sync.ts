#!/usr/bin/env -S deno run --allow-all

import { createHash } from "node:crypto";
import { basename, join, relative } from "node:path";
// deno-lint-ignore-file no-external-imports
import remarkParse from "npm:remark-parse";
import { unified } from "npm:unified";
import { Database } from "jsr:@db/sqlite";
import JSZip from "npm:jszip";

const ROOT = Deno.args.find((a) => !a.startsWith("--")) ?? Deno.cwd();
const OUTPUT_PATH = join(Deno.cwd(), "anki-decks.apkg");
const DECK_NAME = basename(Deno.cwd());
const BASIC_MODEL_ID = 1342697561;
const CLOZE_MODEL_ID = 1045689296;
const DECK_ID = 1;
const SKIP: readonly string[] = [
  "node_modules",
  "scripts",
  "assets",
  "anki-decks",
  "template.",
];
const ALIASES: Record<string, string> = {
  lang: "language",
  proj: "project",
  mv: "movement",
};

interface BasicNote {
  readonly type: "basic";
  readonly question: string;
  readonly answer: string;
  readonly guid: string;
  readonly tag: string;
  readonly deckId: number;
  readonly createdMs: number;
}

interface ClozeNote {
  readonly type: "cloze";
  readonly text: string;
  readonly guid: string;
  readonly tag: string;
  readonly deckId: number;
  readonly createdMs: number;
}

type Note = BasicNote | ClozeNote;

type MdastNode = { type: string; value?: string; children?: MdastNode[] };
type MdastRoot = { type: "root"; children: MdastNode[] };

const sha256hex = (s: string): string =>
  createHash("sha256").update(s).digest("hex");

const sha1hex = (s: string): string =>
  createHash("sha1").update(s).digest("hex");

const makeGuid = (s: string): string => sha256hex(s).slice(0, 16);

const makeCsum = (sfld: string): number =>
  parseInt(sha1hex(sfld.toLowerCase()).slice(0, 8), 16);

const makeDeckId = (name: string): number =>
  (parseInt(sha1hex(name).slice(0, 8), 16) % 2_000_000_000) + 1_000_000;

const parseFrontmatter = (content: string): { deck?: string; body: string } => {
  if (!content.startsWith("---\n")) return { body: content };
  const end = content.indexOf("\n---\n", 4);
  if (end === -1) return { body: content };
  const fm = content.slice(4, end);
  const m = fm.match(/^deck:\s*(.+)$/m);
  return { deck: m?.[1]?.trim(), body: content.slice(end + 5) };
};

const pathToTag = (filePath: string): string =>
  relative(ROOT, filePath)
    .replace(/\.md$/, "")
    .split(/[/.]/)
    .map((s) => ALIASES[s] ?? s)
    .join("::");

const extractNodeTexts = (node: MdastNode): [string, string] => {
  if (node.type === "text") return [node.value ?? "", node.value ?? ""];
  if (node.type === "inlineCode") {
    const w = `\`${node.value ?? ""}\``;
    return [w, "\0".repeat(w.length)];
  }
  if (node.children) {
    const pairs = node.children.map(extractNodeTexts);
    return [pairs.map(([f]) => f).join(""), pairs.map(([, m]) => m).join("")];
  }
  return ["", ""];
};

const toClozeText = (full: string, masked: string): string | undefined => {
  const re = /(?<![${])\{([^{}\n]+)\}(?!\})/g;
  const hits: Array<{ i: number; len: number }> = [];
  let m: RegExpExecArray | null;
  while ((m = re.exec(masked)) !== null) {
    hits.push({ i: m.index, len: m[0].length });
  }
  if (!hits.length) return undefined;

  let out = "";
  let cur = 0;
  for (let n = 0; n < hits.length; n++) {
    const { i, len } = hits[n]!;
    out += full.slice(cur, i) +
      `{{c${n + 1}::${full.slice(i + 1, i + len - 1)}}}`;
    cur = i + len;
  }
  return out + full.slice(cur);
};

const parseFile = (
  content: string,
  tag: string,
  deckId: number,
  baseMs: number,
): Note[] => {
  const tree = unified().use(remarkParse).parse(content) as MdastRoot;
  const kids = tree.children;
  const consumed = new Set<number>();
  const notes: Note[] = [];

  for (let i = 0; i < kids.length; i++) {
    if (kids[i]!.type !== "paragraph") continue;
    const [full] = extractNodeTexts(kids[i]!);
    const qm = full.match(/^Q\. (.+)/);
    if (!qm) continue;

    const lines = full.split("\n");
    let done = false;
    let foundNonA = false;
    for (let j = 1; j < lines.length; j++) {
      if (!lines[j]!.trim()) continue;
      const am = lines[j]!.match(/^A\. (.+)/);
      if (am) {
        notes.push({
          type: "basic",
          question: qm[1]!,
          answer: am[1]!,
          guid: makeGuid(qm[1]! + "\x1f" + am[1]!),
          tag,
          deckId,
          createdMs: baseMs + notes.length,
        });
        consumed.add(i);
        done = true;
      } else {
        foundNonA = true;
      }
      break;
    }
    if (done || foundNonA) continue;

    for (let j = i + 1; j < kids.length; j++) {
      if (kids[j]!.type !== "paragraph") continue;
      const [nf] = extractNodeTexts(kids[j]!);
      const am = nf.match(/^A\. (.+)/);
      if (am) {
        notes.push({
          type: "basic",
          question: qm[1]!,
          answer: am[1]!,
          guid: makeGuid(qm[1]! + "\x1f" + am[1]!),
          tag,
          deckId,
          createdMs: baseMs + notes.length,
        });
        consumed.add(i);
        consumed.add(j);
      }
      break;
    }
  }

  for (let i = 0; i < kids.length; i++) {
    if (kids[i]!.type !== "paragraph" || consumed.has(i)) continue;
    const [full, masked] = extractNodeTexts(kids[i]!);
    if (/^[QA]\. /.test(full)) continue;
    const clozeText = toClozeText(full, masked);
    if (!clozeText) continue;
    notes.push({
      type: "cloze",
      text: clozeText,
      guid: makeGuid(full),
      tag,
      deckId,
      createdMs: baseMs + notes.length,
    });
  }

  return notes;
};

const isPlainText = async (path: string): Promise<boolean> => {
  let file: Deno.FsFile;
  try {
    file = await Deno.open(path);
  } catch {
    return false;
  }
  const buf = new Uint8Array(512);
  const n = await file.read(buf);
  file.close();
  return !buf.slice(0, n ?? 0).includes(0);
};

async function* walkMdFiles(): AsyncGenerator<string> {
  const { stdout } = await new Deno.Command("git", {
    args: ["ls-files", "--cached", "--others", "--exclude-standard"],
    cwd: ROOT,
    stdout: "piped",
  }).output();
  for (
    const rel of new TextDecoder().decode(stdout).split("\n").filter(Boolean)
  ) {
    if (!rel.endsWith(".md")) continue;
    if (SKIP.some((s) => rel.startsWith(s))) continue;
    const fullPath = join(ROOT, rel);
    if (await isPlainText(fullPath)) yield fullPath;
  }
}

const buildModels = (now: number) => ({
  [BASIC_MODEL_ID]: {
    id: BASIC_MODEL_ID,
    name: "Basic",
    type: 0,
    mod: now,
    usn: -1,
    sortf: 0,
    did: DECK_ID,
    flds: [
      {
        name: "Front",
        ord: 0,
        sticky: false,
        rtl: false,
        font: "Arial",
        size: 20,
      },
      {
        name: "Back",
        ord: 1,
        sticky: false,
        rtl: false,
        font: "Arial",
        size: 20,
      },
    ],
    tmpls: [{
      name: "Card 1",
      ord: 0,
      qfmt: "{{Front}}",
      afmt: "{{FrontSide}}<hr id=answer>{{Back}}",
      did: null,
      bqfmt: "",
      bafmt: "",
    }],
    css:
      ".card { font-family: arial; font-size: 20px; text-align: center; color: black; background-color: white; }",
    latexPre:
      "\\documentclass[12pt]{article}\n\\special{papersize=3in,5in}\n\\usepackage[utf8]{inputenc}\n\\usepackage{amssymb,amsmath}\n\\pagestyle{empty}\n\\setlength{\\parindent}{0in}\n\\begin{document}\n",
    latexPost: "\\end{document}",
    req: [[0, "any", [0]]],
    tags: [],
    vers: [],
  },
  [CLOZE_MODEL_ID]: {
    id: CLOZE_MODEL_ID,
    name: "Cloze",
    type: 1,
    mod: now,
    usn: -1,
    sortf: 0,
    did: DECK_ID,
    flds: [
      {
        name: "Text",
        ord: 0,
        sticky: false,
        rtl: false,
        font: "Arial",
        size: 20,
      },
      {
        name: "Extra",
        ord: 1,
        sticky: false,
        rtl: false,
        font: "Arial",
        size: 20,
      },
    ],
    tmpls: [{
      name: "Cloze",
      ord: 0,
      qfmt: "{{cloze:Text}}",
      afmt: "{{cloze:Text}}<br>{{Extra}}",
      did: null,
      bqfmt: "",
      bafmt: "",
    }],
    css:
      ".card { font-family: arial; font-size: 20px; text-align: center; color: black; background-color: white; }\n.cloze { font-weight: bold; color: blue; }",
    latexPre:
      "\\documentclass[12pt]{article}\n\\special{papersize=3in,5in}\n\\usepackage[utf8]{inputenc}\n\\usepackage{amssymb,amsmath}\n\\pagestyle{empty}\n\\setlength{\\parindent}{0in}\n\\begin{document}\n",
    latexPost: "\\end{document}",
    req: [[0, "any", [0]]],
    tags: [],
    vers: [],
  },
});

const buildDecks = (decks: Map<number, string>, now: number) => {
  const result: Record<number, unknown> = {};
  for (const [id, name] of decks) {
    result[id] = {
      id,
      name,
      desc: "",
      mod: now,
      usn: -1,
      collapsed: false,
      browserCollapsed: false,
      extendNew: 0,
      extendRev: 0,
      conf: 1,
      newToday: [0, 0],
      timeToday: [0, 0],
      revToday: [0, 0],
      lrnToday: [0, 0],
      dyn: 0,
    };
  }
  return result;
};

const buildDconf = (now: number) => ({
  1: {
    id: 1,
    name: "Default",
    replayq: true,
    lapse: { delays: [10], mult: 0, minInt: 1, leechFails: 8, leechAction: 0 },
    rev: {
      perDay: 200,
      ease4: 1.3,
      fuzz: 0.05,
      minSpace: 1,
      ivlFct: 1,
      maxIvl: 36500,
      bury: true,
    },
    new: {
      delays: [1, 10],
      separate: true,
      perDay: 20,
      ints: [1, 4, 7],
      initialFactor: 2500,
      bury: true,
      order: 1,
    },
    maxTaken: 60,
    timer: 0,
    autoplay: true,
    mod: now,
    usn: -1,
    dynamic: 0,
  },
});

const buildTagsJson = (notes: Note[]): string => {
  const tags: Record<string, number> = {};
  for (const note of notes) tags[note.tag] = -1;
  return JSON.stringify(tags);
};

const buildDatabase = (
  notes: Note[],
  decks: Map<number, string>,
  now: number,
): Uint8Array => {
  const tmp = Deno.makeTempFileSync({ suffix: ".anki2" });
  const db = new Database(tmp);

  db.exec(`
    CREATE TABLE col (id INTEGER NOT NULL, crt INTEGER NOT NULL, mod INTEGER NOT NULL, scm INTEGER NOT NULL, ver INTEGER NOT NULL, dty INTEGER NOT NULL, usn INTEGER NOT NULL, ls INTEGER NOT NULL, conf TEXT NOT NULL, models TEXT NOT NULL, decks TEXT NOT NULL, dconf TEXT NOT NULL, tags TEXT NOT NULL);
    CREATE TABLE notes (id INTEGER NOT NULL, guid TEXT NOT NULL, mid INTEGER NOT NULL, mod INTEGER NOT NULL, usn INTEGER NOT NULL, tags TEXT NOT NULL, flds TEXT NOT NULL, sfld TEXT NOT NULL, csum INTEGER NOT NULL, flags INTEGER NOT NULL, data TEXT NOT NULL);
    CREATE TABLE cards (id INTEGER NOT NULL, nid INTEGER NOT NULL, did INTEGER NOT NULL, ord INTEGER NOT NULL, mod INTEGER NOT NULL, usn INTEGER NOT NULL, type INTEGER NOT NULL, queue INTEGER NOT NULL, due INTEGER NOT NULL, ivl INTEGER NOT NULL, factor INTEGER NOT NULL, reps INTEGER NOT NULL, lapses INTEGER NOT NULL, left INTEGER NOT NULL, odue INTEGER NOT NULL, odid INTEGER NOT NULL, flags INTEGER NOT NULL, data TEXT NOT NULL);
    CREATE TABLE graves (usn INTEGER NOT NULL, oid INTEGER NOT NULL, type INTEGER NOT NULL);
    CREATE TABLE revlog (id INTEGER NOT NULL, cid INTEGER NOT NULL, usn INTEGER NOT NULL, ease INTEGER NOT NULL, ivl INTEGER NOT NULL, lastIvl INTEGER NOT NULL, factor INTEGER NOT NULL, time INTEGER NOT NULL, type INTEGER NOT NULL);
    CREATE INDEX ix_notes_usn ON notes (usn);
    CREATE INDEX ix_cards_usn ON cards (usn);
    CREATE INDEX ix_cards_nid ON cards (nid);
    CREATE INDEX ix_cards_sched ON cards (did, queue, due);
    CREATE INDEX ix_revlog_usn ON revlog (usn);
    CREATE INDEX ix_revlog_cid ON revlog (cid);
  `);

  db.prepare("INSERT INTO col VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)").run(
    1,
    now,
    now,
    now,
    11,
    0,
    -1,
    0,
    JSON.stringify({
      nextPos: 1,
      estTimes: true,
      activeDecks: [DECK_ID],
      sortType: "noteFld",
      timeLim: 0,
      sortBackwards: false,
      addToCur: true,
      curDeck: DECK_ID,
      newBury: true,
      newSpread: 0,
      dueCounts: true,
      curModel: String(BASIC_MODEL_ID),
      collapseTime: 1200,
    }),
    JSON.stringify(buildModels(now)),
    JSON.stringify(buildDecks(decks, now)),
    JSON.stringify(buildDconf(now)),
    buildTagsJson(notes),
  );

  const noteStmt = db.prepare(
    "INSERT INTO notes VALUES (?,?,?,?,?,?,?,?,?,?,?)",
  );
  const cardStmt = db.prepare(
    "INSERT INTO cards VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",
  );
  let due = 1;

  for (const note of notes) {
    const noteId = note.createdMs;
    const noteMod = Math.floor(note.createdMs / 1000);
    const tagStr = ` ${note.tag} `;
    if (note.type === "basic") {
      noteStmt.run(
        noteId,
        note.guid,
        BASIC_MODEL_ID,
        noteMod,
        -1,
        tagStr,
        `${note.question}\x1f${note.answer}`,
        note.question,
        makeCsum(note.question),
        0,
        "",
      );
      cardStmt.run(
        note.createdMs * 10,
        noteId,
        note.deckId,
        0,
        noteMod,
        -1,
        0,
        0,
        due++,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        "",
      );
    } else {
      noteStmt.run(
        noteId,
        note.guid,
        CLOZE_MODEL_ID,
        noteMod,
        -1,
        tagStr,
        `${note.text}\x1f`,
        note.text,
        makeCsum(note.text),
        0,
        "",
      );
      const ords = [
        ...new Set(
          [...note.text.matchAll(/\{\{c(\d+)::/g)].map((m) =>
            parseInt(m[1]!) - 1
          ),
        ),
      ];
      for (const [i, ord] of ords.entries()) {
        cardStmt.run(
          note.createdMs * 10 + i,
          noteId,
          note.deckId,
          ord,
          noteMod,
          -1,
          0,
          0,
          due++,
          0,
          0,
          0,
          0,
          0,
          0,
          0,
          0,
          "",
        );
      }
    }
  }

  db.close();
  const bytes = Deno.readFileSync(tmp);
  Deno.removeSync(tmp);
  return bytes;
};

const buildApkg = async (
  notes: Note[],
  decks: Map<number, string>,
): Promise<void> => {
  const now = Math.floor(Date.now() / 1000);
  const dbBytes = buildDatabase(notes, decks, now);
  await Deno.mkdir(join(ROOT, "anki-decks"), { recursive: true });
  const zip = new JSZip();
  zip.file("collection.anki2", dbBytes);
  zip.file("media", "{}");
  await Deno.writeFile(
    OUTPUT_PATH,
    await zip.generateAsync({ type: "uint8array" }),
  );
};

const ankiConnect = async (
  action: string,
  params?: Record<string, unknown>,
): Promise<unknown> => {
  const res = await fetch("http://localhost:8765", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ action, version: 6, ...(params ? { params } : {}) }),
  });
  const { error, result } = await res.json();
  if (error) throw new Error(error);
  return result;
};

const main = async (): Promise<void> => {
  const dry = Deno.args.includes("--dry");
  const debug = dry || Deno.args.includes("--debug");
  const notes: Note[] = [];
  const decks = new Map<number, string>([[DECK_ID, DECK_NAME]]);
  for await (const path of walkMdFiles()) {
    const [raw, stat] = await Promise.all([
      Deno.readTextFile(path),
      Deno.stat(path),
    ]);
    const baseMs = stat.mtime?.getTime() ?? Date.now();
    const { deck, body } = parseFrontmatter(raw);
    let deckId = DECK_ID;
    if (deck) {
      deckId = makeDeckId(deck);
      decks.set(deckId, deck);
    }
    notes.push(...parseFile(body, pathToTag(path), deckId, baseMs));
  }
  if (debug) {
    for (const note of notes) {
      const deck = decks.get(note.deckId) ?? DECK_NAME;
      if (note.type === "basic") {
        console.error(`[${deck}][${note.tag}] Q. ${note.question} / A. ${note.answer}`);
      } else {
        console.error(`[${deck}][${note.tag}] ${note.text}`);
      }
    }
  }
  console.log(`${notes.length} notes -> ${OUTPUT_PATH}`);
  if (dry) return;

  await buildApkg(notes, decks);

  try {
    await ankiConnect("importPackage", { path: OUTPUT_PATH });
    console.log("imported via AnkiConnect");
    await ankiConnect("sync");
    console.log("synced");
  } catch {
    console.log("AnkiConnect unavailable — import manually");
  }
};

main();
