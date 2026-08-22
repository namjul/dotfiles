#!/usr/bin/env -S deno run --allow-all

import { createHash } from "node:crypto";
import { basename, join, relative } from "node:path";
// deno-lint-ignore-file no-external-imports
import remarkParse from "npm:remark-parse";
import { unified } from "npm:unified";
import { Database } from "jsr:@db/sqlite";
import JSZip from "npm:jszip";

const ROOT = Deno.args.find((a) => !a.startsWith("--")) ?? Deno.cwd();
const OUTPUT_PATH = join(ROOT, "anki-decks.apkg");
const DECK_NAME = basename(ROOT);
const BASIC_MODEL_ID = 1342697561;
const CLOZE_MODEL_ID = 1045689296;
const DECK_ID = 1;
type SkipRule =
  | { kind: "prefix"; pattern: string; reason: string }
  | { kind: "suffix"; pattern: string; reason: string };

const SKIP_RULES: readonly SkipRule[] = [
  { kind: "prefix", pattern: "node_modules", reason: "dependency tree" },
  { kind: "prefix", pattern: "scripts", reason: "build/tooling" },
  { kind: "prefix", pattern: "assets", reason: "non-text assets" },
  { kind: "prefix", pattern: "anki-decks", reason: "sync output" },
  { kind: "prefix", pattern: "template", reason: "memex /template folder (template.*)" },
  { kind: "suffix", pattern: ".template.md", reason: "co-located entry templates" },
];

const shouldSkipPath = (rel: string): boolean =>
  SKIP_RULES.some((rule) =>
    rule.kind === "prefix"
      ? rel.startsWith(rule.pattern)
      : rel.endsWith(rule.pattern)
  );
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
  const deckName = m?.[1]?.trim();
  const body = content.slice(end + 5);
  return deckName ? { deck: deckName, body } : { body };
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
    if (!rel.endsWith(".md") || shouldSkipPath(rel)) continue;
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

/** Reverse `{{cN::text}}` → `{text}` so cloze GUID matches scan hashing. */
const fromClozeText = (clozeText: string): string =>
  clozeText.replace(/\{\{c\d+::([^}]+)\}\}/g, "{$1}");

interface AnkiNoteSnapshot {
  readonly noteId: number;
  readonly modelName: string;
  readonly fields: Record<string, { value: string }>;
}

const fieldValue = (
  fields: Record<string, { value: string }>,
  name: string,
): string | undefined => fields[name]?.value;

/** Recompute content GUID from notesInfo fields; model name is ignored (Anki renames on conflict). */
const guidFromAnkiFields = (
  _modelName: string,
  fields: Record<string, { value: string }>,
): string | undefined => {
  const front = fieldValue(fields, "Front");
  const back = fieldValue(fields, "Back");
  if (front !== undefined && back !== undefined) {
    return makeGuid(front + "\x1f" + back);
  }
  const text = fieldValue(fields, "Text");
  if (text !== undefined) {
    return makeGuid(fromClozeText(text));
  }
  return undefined;
};

const orphanNoteIds = (
  ankiNotes: ReadonlyArray<AnkiNoteSnapshot>,
  scanGuids: ReadonlySet<string>,
): number[] => {
  const orphans: number[] = [];
  for (const note of ankiNotes) {
    const guid = guidFromAnkiFields(note.modelName, note.fields);
    if (guid === undefined || !scanGuids.has(guid)) orphans.push(note.noteId);
  }
  return orphans;
};

/** Partition scan notes against Anki content GUIDs: new = scan-only, same = in both. */
const partitionScanAgainstAnki = (
  scanNotes: ReadonlyArray<Note>,
  ankiGuids: ReadonlySet<string>,
): { newNotes: Note[]; sameNotes: Note[] } => {
  const newNotes: Note[] = [];
  const sameNotes: Note[] = [];
  for (const note of scanNotes) {
    if (ankiGuids.has(note.guid)) sameNotes.push(note);
    else newNotes.push(note);
  }
  return { newNotes, sameNotes };
};

const ankiGuidsFromSnapshots = (
  ankiNotes: ReadonlyArray<AnkiNoteSnapshot>,
): Set<string> => {
  const guids = new Set<string>();
  for (const note of ankiNotes) {
    const guid = guidFromAnkiFields(note.modelName, note.fields);
    if (guid !== undefined) guids.add(guid);
  }
  return guids;
};

const formatScanNote = (
  note: Note,
  decks: Map<number, string>,
): string => {
  const deck = decks.get(note.deckId) ?? DECK_NAME;
  if (note.type === "basic") {
    return `[${deck}][${note.tag}] Q. ${note.question} / A. ${note.answer}`;
  }
  return `[${deck}][${note.tag}] ${note.text}`;
};

const deckSearchQuery = (name: string): string => {
  const escaped = name.replaceAll("\\", "\\\\").replaceAll('"', '\\"');
  return `deck:"${escaped}" -deck:"${escaped}::*"`;
};

const listManagedNotesViaConnect = async (
  deckNames: ReadonlyArray<string>,
): Promise<AnkiNoteSnapshot[]> => {
  const noteIds = new Set<number>();
  for (const name of deckNames) {
    const found = await ankiConnect("findNotes", {
      query: deckSearchQuery(name),
    }) as number[];
    for (const id of found) noteIds.add(id);
  }
  if (noteIds.size === 0) return [];
  return (await ankiConnect("notesInfo", {
    notes: [...noteIds],
  }) as AnkiNoteSnapshot[]).filter((n) => typeof n.noteId === "number");
};

const listOrphansViaConnect = async (
  deckNames: ReadonlyArray<string>,
  scanGuids: ReadonlySet<string>,
): Promise<AnkiNoteSnapshot[]> => {
  const infos = await listManagedNotesViaConnect(deckNames);
  const orphanIds = new Set(orphanNoteIds(infos, scanGuids));
  return infos.filter((n) => orphanIds.has(n.noteId));
};

const main = async (): Promise<void> => {
  const dry = Deno.args.includes("--dry");
  const debug = Deno.args.includes("--debug");
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
  if (debug && !dry) {
    for (const note of notes) {
      console.error(formatScanNote(note, decks));
    }
  }
  console.log(`${notes.length} notes -> ${OUTPUT_PATH}`);

  const scanGuids = new Set(notes.map((n) => n.guid));
  const deckNames = [...decks.values()];

  if (dry) {
    try {
      const ankiNotes = await listManagedNotesViaConnect(deckNames);
      const ankiGuids = ankiGuidsFromSnapshots(ankiNotes);
      const { newNotes, sameNotes } = partitionScanAgainstAnki(notes, ankiGuids);
      const orphanIds = new Set(orphanNoteIds(ankiNotes, scanGuids));
      const orphans = ankiNotes.filter((n) => orphanIds.has(n.noteId));

      console.log(
        `${newNotes.length} new, ${sameNotes.length} same, ${orphans.length} orphan`,
      );
      for (const note of newNotes) {
        console.error(`[new] ${formatScanNote(note, decks)}`);
      }
      if (debug) {
        for (const note of sameNotes) {
          console.error(`[same] ${formatScanNote(note, decks)}`);
        }
      }
      for (const o of orphans) {
        const front = fieldValue(o.fields, "Front") ??
          fieldValue(o.fields, "Text") ??
          "";
        console.error(`[orphan][${o.modelName}] #${o.noteId} ${front}`);
      }
    } catch {
      console.log("AnkiConnect unavailable — orphan preview skipped");
    }
    return;
  }

  await buildApkg(notes, decks);

  try {
    await ankiConnect("importPackage", { path: OUTPUT_PATH });
    console.log("imported via AnkiConnect");
    const orphans = await listOrphansViaConnect(deckNames, scanGuids);
    if (orphans.length > 0) {
      await ankiConnect("deleteNotes", {
        notes: orphans.map((o) => o.noteId),
      });
      console.log(`deleted ${orphans.length} orphan note(s)`);
    } else {
      console.log("no orphan notes");
    }
    await ankiConnect("sync");
    console.log("synced");
  } catch {
    console.log("AnkiConnect unavailable — import manually");
  }
};

Deno.test("guidFromAnkiFields: basic matches makeGuid", () => {
  const q = "What is the default HTTP port?";
  const a = "80.";
  const guid = makeGuid(q + "\x1f" + a);
  const got = guidFromAnkiFields("Basic", {
    Front: { value: q },
    Back: { value: a },
  });
  if (got !== guid) throw new Error(`expected ${guid}, got ${got}`);
});

Deno.test("guidFromAnkiFields: cloze round-trips toClozeText guid", () => {
  const full = "The mitochondria is the {powerhouse of the cell}.";
  const masked = full;
  const cloze = toClozeText(full, masked)!;
  const expected = makeGuid(full);
  const got = guidFromAnkiFields("Cloze", {
    Text: { value: cloze },
    Extra: { value: "" },
  });
  if (got !== expected) throw new Error(`expected ${expected}, got ${got}`);
});

Deno.test("guidFromAnkiFields: renamed Basic-* model still matches", () => {
  const q = "What is the default HTTP port?";
  const a = "80.";
  const guid = makeGuid(q + "\x1f" + a);
  const got = guidFromAnkiFields("Basic-e35f9", {
    Front: { value: q },
    Back: { value: a },
  });
  if (got !== guid) throw new Error(`expected ${guid}, got ${got}`);
});

Deno.test("orphanNoteIds: missing from scan is orphan", () => {
  const keep = makeGuid("keep\x1fA");
  const drop = makeGuid("drop\x1fA");
  const ids = orphanNoteIds(
    [
      {
        noteId: 1,
        modelName: "Basic-e35f9",
        fields: { Front: { value: "keep" }, Back: { value: "A" } },
      },
      {
        noteId: 2,
        modelName: "Basic-e35f9",
        fields: { Front: { value: "drop" }, Back: { value: "A" } },
      },
    ],
    new Set([keep]),
  );
  if (ids.length !== 1 || ids[0] !== 2) {
    throw new Error(`expected [2], got ${JSON.stringify(ids)}`);
  }
  if (drop === keep) throw new Error("fixture guids collided");
});

Deno.test("orphanNoteIds: no Front/Back/Text fields is orphan", () => {
  const ids = orphanNoteIds(
    [{
      noteId: 9,
      modelName: "Image Occlusion",
      fields: { Image: { value: "x.png" } },
    }],
    new Set([makeGuid("anything")]),
  );
  if (ids.length !== 1 || ids[0] !== 9) {
    throw new Error(`expected [9], got ${JSON.stringify(ids)}`);
  }
});

Deno.test("orphanNoteIds: empty scan orphans all", () => {
  const ids = orphanNoteIds(
    [{
      noteId: 3,
      modelName: "Basic",
      fields: { Front: { value: "a" }, Back: { value: "b" } },
    }],
    new Set(),
  );
  if (ids.length !== 1 || ids[0] !== 3) {
    throw new Error(`expected [3], got ${JSON.stringify(ids)}`);
  }
});

Deno.test("partitionScanAgainstAnki: new vs same by content GUID", () => {
  const keepGuid = makeGuid("keep\x1fA");
  const newGuid = makeGuid("fresh\x1fA");
  const scan: Note[] = [
    {
      type: "basic",
      question: "keep",
      answer: "A",
      guid: keepGuid,
      tag: "t",
      deckId: DECK_ID,
      createdMs: 1,
    },
    {
      type: "basic",
      question: "fresh",
      answer: "A",
      guid: newGuid,
      tag: "t",
      deckId: DECK_ID,
      createdMs: 2,
    },
  ];
  const { newNotes, sameNotes } = partitionScanAgainstAnki(
    scan,
    new Set([keepGuid]),
  );
  if (sameNotes.length !== 1 || sameNotes[0]!.guid !== keepGuid) {
    throw new Error(`same expected [keep], got ${JSON.stringify(sameNotes)}`);
  }
  if (newNotes.length !== 1 || newNotes[0]!.guid !== newGuid) {
    throw new Error(`new expected [fresh], got ${JSON.stringify(newNotes)}`);
  }
});

Deno.test("ankiGuidsFromSnapshots: skips notes without Front/Back/Text", () => {
  const keep = makeGuid("keep\x1fA");
  const guids = ankiGuidsFromSnapshots([
    {
      noteId: 1,
      modelName: "Basic",
      fields: { Front: { value: "keep" }, Back: { value: "A" } },
    },
    {
      noteId: 2,
      modelName: "Image Occlusion",
      fields: { Image: { value: "x.png" } },
    },
  ]);
  if (guids.size !== 1 || !guids.has(keep)) {
    throw new Error(`expected {${keep}}, got ${JSON.stringify([...guids])}`);
  }
});

if (import.meta.main) {
  main();
}
