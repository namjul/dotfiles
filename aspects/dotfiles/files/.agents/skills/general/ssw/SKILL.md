---
name: ssw
description: >
  Kurzer faktischer Wochenbericht zur Schwangerschaftswoche. Nutzen bei /ssw,
  „SSW N“, oder wenn ein Schwangerschafts-Wochenbericht gewünscht ist.
---

Schreibe einen ruhigen, faktisch korrekten Wochenbericht für werdende Eltern. Keine Diagnose, keine Therapie. Ungewöhnliches darf als ärztlich abklärbar anklingen, ohne in den Vordergrund zu treten.

## Input

Lies `$ARGUMENTS` bzw. die Nutzernachricht zuerst.

- **SSW** — Wochennummer; fehlt sie, einmal nachfragen und nicht raten.
- **NOTES** — optionale Fakten oder Quellen. NOTES schlagen Allgemeinwissen; Sicherheit schlägt NOTES.

## Fakten-Gate (nicht überspringen)

Den Bericht nicht ausgeben, bevor drei geprüfte Punkte feststehen: Scheitel-Steiß-Spanne; ein Entwicklungsmerkmal, das zu dieser Woche gehört; ob ein Vorsorgefenster in oder nahe dieser Woche liegt.

Quellen öffnen, nicht aus dem Gedächtnis mitteln. Lifestyle-Kalender bestätigen einander oft nur. Bei abweichenden Größen eine konservative Spanne mit „etwa“/„häufig“. SSW-Zählung und CRL-Tabellen meinen nicht immer dasselbe; 11+0 ist nicht der Wochenmittelwert.

Eltern-Kind-Pass und Screening (NT, Geschlecht) nur nennen, wenn das Fenster wirklich passt. Mehrling, IVF, Lage nur bei NOTES.

## Grenzen

Deutsch, Sie-Form oder „viele Frauen“ / „die Mutter“. Sachlich, warm, nicht kitschig. Keine Emojis, keine Lebensmittelvergleiche, keine erfundenen Punktzahlen. Bis ca. SSW 8 „Embryo“, danach „Fötus“. Dieselbe Information nicht über Sektionen wiederholen.

## Ausgabe

Nur ein fenced ` ```md ` Block, nichts außerhalb. Nicht fertig, solange der Block fehlt oder Zahlen ungeprüft sind.

```md
In der {{SSW}}. Schwangerschaftswoche (SSW {{SSW}}) …

## Was interessant ist

**Titel:** Kind, Plazenta, Fruchtwasser oder Sichtbarkeit — überraschend oder beruhigend, keine Symptomliste.

## Was Aufmerksamkeit verdient

**Titel:** Typische Empfindungen dieser Phase, nicht aus anderen Wochen gezogen.

## Was die Woche {{SSW}} ermöglicht

**Titel:** Nur Meilensteine, die in oder nahe dieser Woche anstehen.
```

Intro: 3–5 Sätze, Größe plus eine äußere und eine innere Entwicklung. Darunter wenige `**Titel:**`-Absätze (höchstens fünf; letzte Sektion zwei bis vier). Keine Aufzählungszeichen.
