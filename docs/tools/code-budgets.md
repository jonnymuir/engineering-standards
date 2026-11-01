# Code budgets

Hard limits on size and complexity, enforced in CI, with a baseline for existing code that may
only shrink.

| Budget | Limit | Enforced by |
|---|---|---|
| C# file | 400 lines | `scripts/check-policies.mjs` |
| C# method | 60 lines | `scripts/check-policies.mjs` |
| TypeScript/JavaScript file | 500 lines | `scripts/check-policies.mjs` |
| `as unknown as` casts | none | `scripts/check-policies.mjs` |
| C# cyclomatic complexity | 15 | Analyzer CA1502 |
| C# class coupling | 40 per method, 60 per type | Analyzer CA1506 |
| TypeScript function | 80 lines | Biome `noExcessiveLinesPerFunction` |
| TypeScript cognitive complexity | 15 | Biome `noExcessiveCognitiveComplexity` |

## Build settings

`Directory.Build.props` turns analyzer warnings into build failures:

```xml
<AnalysisLevel>latest-recommended</AnalysisLevel>
<EnforceCodeStyleInBuild>true</EnforceCodeStyleInBuild>
<TreatWarningsAsErrors>true</TreatWarningsAsErrors>
```

`CodeMetricsConfig.txt` sets the CA1502 and CA1506 thresholds and is passed to the analyzers as an
`AdditionalFiles` item. `.editorconfig` raises both rules to `warning`, which
`TreatWarningsAsErrors` makes fatal.

Turning `TreatWarningsAsErrors` on in an existing repo means first clearing or baselining its
current warnings. Do it as its own PR.

## The size script

```sh
node scripts/check-policies.mjs           # fail if anything grew past its budget or baseline
node scripts/check-policies.mjs --update  # lower baseline entries to today's sizes
```

`.policy/size-baseline.json` lists files already over budget at their current size. Growing a
listed file fails, adding a new file over budget fails, and so does a stale entry (a file that
shrank without the baseline being lowered). `--update` only ever lowers or removes entries;
adding one is a deliberate, reviewed edit.

## Baselines for analyzer and Biome findings

- **C#:** existing CA1502/CA1506 offenders go in a block at the end of `.editorconfig`, between
  `# BEGIN complexity baseline` and `# END complexity baseline`, one section per file setting both
  rules to `none`.
- **TypeScript:** the last entry in `biome.jsonc`'s `overrides` lists files that may exceed the
  Biome complexity rules.

Both lists only shrink. When you split a file, remove its entry.

## When a budget fails

Split the code. Extract a class with one concern, or move a group of methods to a new file. Do not
add to a baselined file; add a new one.
