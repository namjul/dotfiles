# OntoEdit analysis report schema

Normative field names for Markdown sections and optional JSON output. Unknown future rubric rows do not require new report fields — agents ignore rubric sections they do not use.

## Envelope

```typescript
interface OntoEditAnalysisReport {
  readonly meta: {
    readonly rubricVersion: string;
    readonly analyzedAt: string; // ISO 8601 date
    readonly scope: "full" | "level" | "ss" | "ps" | "flags" | "relation";
  };
  readonly levelAnalysis?: LevelAnalysisModule;
  readonly ssBand?: SSBandModule;
  readonly psRubric?: PSRubricModule;
  readonly interpretiveSchema?: InterpretiveSchemaModule;
  readonly yellowFlags?: YellowFlagsModule;
  readonly conjunctiveArguments?: ConjunctiveArgumentsModule;
  readonly synthesis: SynthesisModule;
}
```

## Modules

### LevelAnalysisModule

For each engaged primitive or generator:

```typescript
interface LevelRow {
  readonly name: string;
  readonly levelClaimed?: number; // 1–6, if author implies one
  readonly levelEarned: number; // 1–6
  readonly evidenceQuotes: ReadonlyArray<string>;
  readonly malwarePatterns: ReadonlyArray<string>;
}
```

Top-level: `{ readonly rows: ReadonlyArray<LevelRow>; readonly malwareSummary?: string }`

### SSBandModule

```typescript
interface SSBandModule {
  readonly band: string;
  readonly cardId: string; // "1"–"6" or "X1"–"X4"
  readonly failureMode: string;
  readonly upgradeMove: string;
  readonly contactTestGap?: string;
}
```

### PSRubricModule

Five standards from the rubric pack (causality, mechanism, equivalences, etc. — use rubric names):

```typescript
interface PSStandardResult {
  readonly standard: string;
  readonly passesAtClaimedLevel: boolean;
  readonly evidencePresent: ReadonlyArray<string>;
  readonly evidenceNeeded: ReadonlyArray<string>;
  readonly monotonicityNote?: string;
}
```

Top-level: `{ readonly standards: ReadonlyArray<PSStandardResult> }`

### InterpretiveSchemaModule

```typescript
interface InterpretiveSchemaModule {
  readonly rung: "L1" | "L2" | "L3" | "L4";
  readonly relationType: string;
  readonly evidenceQuotes: ReadonlyArray<string>;
  readonly oneRungUpRequirements: ReadonlyArray<string>;
}
```

### YellowFlagsModule

```typescript
interface YellowFlagRow {
  readonly flagId: `Y${1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | 12}`;
  readonly status: "none" | "yellow" | "red";
  readonly triggerQuote?: string;
  readonly diagnosticAnswer?: string;
  readonly doingArgumentativeWork: boolean;
}
```

Top-level: `{ readonly flags: ReadonlyArray<YellowFlagRow> }` — include only flags with status yellow or red, or explicitly list all twelve with `none` when user requests exhaustive flag scan.

### ConjunctiveArgumentsModule

```typescript
interface ConjunctiveArgumentsModule {
  readonly types: ReadonlyArray<
    | "cross_domain"
    | "cross_level"
    | "philosophy_science"
    | "interpretive_operational"
    | "upward_downward"
  >;
  readonly assessment: string;
  readonly biggerFunnelOrAnalogyRisk: boolean;
}
```

### SynthesisModule

```typescript
interface SynthesisModule {
  readonly claimedVsEarned: ReadonlyArray<{
    readonly dimension: string;
    readonly claimed?: string | number;
    readonly earned: string | number;
    readonly gapNote: string;
  }>;
  readonly upgradeMoves: ReadonlyArray<string>;
}
```

## Error shape

```typescript
interface OntoEditAnalysisError {
  readonly error:
    | "PASSAGE_TOO_SHORT"
    | "RUBRIC_NOT_LOADED"
    | "SCOPE_REQUIRES_COMPARISON"
    | "AMBIGUOUS_PASSAGE";
  readonly message: string;
  readonly remediation: string;
}
```

## Markdown mapping

| JSON key | H2 heading |
|----------|------------|
| `meta` | `## Meta` |
| `levelAnalysis` | `## Level Analysis` |
| `ssBand` | `## SS Level Band and Card` |
| `psRubric` | `## PS Rubric Module` |
| `interpretiveSchema` | `## Interpretive Schema Ladder` |
| `yellowFlags` | `## Yellow and Red Flags` |
| `conjunctiveArguments` | `## Conjunctive Arguments` |
| `synthesis` | `## Synthesis` |
