---
description: Wochenbericht zur Schwangerschaftswoche (SSW) — faktisch, ruhig, strukturiert
---

Du schreibst einen kurzen, faktisch korrekten Wochenbericht zur Schwangerschaftswoche.

## Input

$ARGUMENTS

Establish from the input (or ask if missing):

- **SSW** — Wochennummer (z. B. `8`, `12`, `22`)
- **NOTES** — optionale Quellenhinweise oder Fakten, die priorisiert werden sollen (sonst leer lassen)

Im Folgenden: `{{SSW}}` = die ermittelte Wochennummer; `{{NOTES}}` = die optionalen Hinweise.

## Zielgruppe & Ton

Werdende Eltern. Ruhig und klar, ohne Alarmismus. Keine medizinischen Diagnosen, keine Therapieempfehlungen; bei Symptomen nur typische Empfindungen nennen und ggf. andeuten, dass Ungewöhnliches ärztlich abgeklärt werden sollte — ohne das in den Vordergrund zu stellen.

Sprache: Deutsch (Sie-Form oder neutrales „die Mutter“ / „viele Frauen“). Fachbegriffe sparsam; bei Bedarf einmal erklären.

## Struktur — exakt einhalten

Ausgabe immer als **Markdown in einem fenced Codeblock** (` ```md ` … ` ``` `). Kein Plain-Text ohne Markdown-Markierung; nichts außerhalb des Codeblocks.

1) Einleitungsabsatz (3–5 Sätze), ohne Überschrift:
   - Beginne mit: „In der {{SSW}}. Schwangerschaftswoche (SSW {{SSW}}) …“
   - Embryo/Fötus: ungefähre Größe (mm oder cm, realistisch für diese Woche), sichtbare äußere Entwicklung, wichtige innere Entwicklung.
   - Terminologie: bis ca. SSW 8 „Embryo“, danach „Fötus“, sofern üblich.

2) Leerzeile, dann Markdown-Überschrift genau:
   `## Was interessant ist`
   - 3–5 kurze Absätze, jeweils als `**Titel:**` gefolgt von 1–2 Sätzen.
   - Fokus: Entwicklung des Kindes, Mutterleib, Fruchtwasser, Plazenta, Ultraschall-Sichtbarkeit — überraschende, beruhigende oder wissenswerte Fakten.

3) Leerzeile, dann Markdown-Überschrift genau:
   `## Was Aufmerksamkeit verdient`
   - 3–5 kurze Absätze im gleichen `**Titel:**` Erklärung-Format.
   - Fokus: typische körperliche und emotionale Veränderungen der Schwangeren in dieser Woche (Atemnot, Harndrang, Müdigkeit, Stimmung, Ziehen im Bauch usw. — nur was für diese Woche typisch/plausibel ist).

4) Leerzeile, dann Markdown-Überschrift genau:
   `## Was die Woche {{SSW}} ermöglicht`
   - 2–4 kurze Absätze im gleichen Format.
   - Fokus: Chancen, Meilensteine, sinnvolle nächste Schritte (z. B. Ultraschall-Details, Tempo drosseln, Unterstützung holen, Vorsorge-Termine — nur wenn für diese Woche passend). In Österreich ggf. Eltern-Kind-Pass / typische Untersuchungsfenster nur erwähnen, wenn sie wirklich in/nahe dieser Woche liegen.

## Stilregeln

- Sachlich, warm, nicht kitschig; keine Emojis.
- Keine Aufzählungszeichen; nur die `**Titel:**` Erklärung-Absätze wie im Vorbild.
- Keine Längenvergleiche mit Lebensmitteln, außer sie sind üblich und präzise.
- Keine erfundenen Zahlen; Größen und Entwicklungsmeilensteine müssen zur SSW {{SSW}} passen. Wenn unsicher: weicher formulieren („etwa“, „häufig“).
- Keine Wiederholung derselben Information über die drei Abschnitte hinweg.

## Vorbild (Struktur und Ton — Inhalt ist SSW 8, nicht kopieren)

In the 8th week of pregnancy (SSW 8), the embryo measures between 9 and 16 millimeters and has taken on the recognizable shape of a "mini-human". During this time, the outer ears, tip of the nose, and upper lip are formed, and the buds for fingers and toes become visible. Internally, the liver appears as a bulge, and the heart and intestines continue their rapid development.

## What is Interesting

**Physiological Umbilical Hernia:** …

**Invisible Gender:** …

## What Calls for Attention

**Shortness of Breath:** …

## What Week 8 Affords

**Ultrasound Milestones:** …

## Ausgabe

Nur den fertigen deutschen Wochenbericht — als **Markdown in einem fenced Codeblock** (` ```md ` … ` ``` `), keine Meta-Kommentare außerhalb des Blocks. Abschnittsüberschriften als `## …`, Absatztitel als `**Titel:**`.

Wenn NOTES gesetzt sind, priorisiere sie:

{{NOTES}}
