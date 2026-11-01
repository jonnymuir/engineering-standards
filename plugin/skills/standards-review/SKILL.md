---
name: standards-review
description: Review the current branch's changes against the estate's engineering standards (security mandate, simplicity budgets, testing charter, docs and writing rules) before opening or merging a PR. Use when asked to check a change against the standards, or before a PR in a repo whose CLAUDE.md links to jonnymuir/engineering-standards.
---

Review the diff of the current branch against `origin/main` for the rules below. Read the repo's
`CLAUDE.md` too: repo-specific rules add to these.

```bash
git fetch origin main
git diff origin/main...HEAD
git status --short
```

Report each finding with file and line, the rule it breaks, and the fix. Say plainly when there
are none. Do not fix anything unless asked.

## Security

- A new route, endpoint or tool without an explicit authorization requirement, or anonymous access
  without a written reason.
- An auth or token flow that departs from the spec.
- A hardcoded actor, tenant or allow-all default in library code.
- A secret, key or connection string with credentials in a tracked file, log message or fixture.
  Check config files changed by running the app (Umbraco writes `Imaging:HMACSecretKey` into
  `appsettings.json` on first boot).
- Data flowing into `innerHTML`, `insertAdjacentHTML` or `unsafeHTML` without an
  `// html-sink-ok:` reason.
- Workflow changes: unpinned actions, missing `persist-credentials: false`, `${{ }}` inlined into
  `run:`, broader `permissions:` than needed.
- A boundary touched without a regression test.
- A threat-surface change not called out in the commit body.

## Simplicity

- Speculative abstraction, an unused option, a back-compat shim or alias.
- A file or method over budget (C# file 400, C# method 60, TS/JS file 500), or growth in a
  baselined file. Run `node scripts/check-policies.mjs` if the repo has it.
- A type hand-mirrored across languages, or `as unknown as`.
- Duplication of something that already exists in a shared package or `ci-security`.

## Testing

- Tests asserting implementation details, private state or mocks of the database.
- New `InternalsVisibleTo`.
- Playwright selectors using CSS classes or tag names.
- Error-state tests that check only one of the summary and the field message.
- Behaviour changed without a test that would catch its regression.

## Docs and writing

- Em dashes anywhere in the diff.
- Docs narrating history ("originally", "verified live") instead of current state.
- A new doc not added to `docs/README.md`.
- A commit subject that isn't a Conventional Commit, or a breaking change without a
  `BREAKING CHANGE:` line saying how to upgrade.
- Generated runtime state staged by mistake (`git status` after running the app).
