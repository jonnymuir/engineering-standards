# CodeQL

Static analysis for security bugs: injection, unsafe deserialization, open redirects, unsafe data
flowing into sinks. Runs the `security-extended` query suite over C# and, where a repo has a
client, JavaScript/TypeScript.

## How it is wired

Part of `dotnet-security.yml` in [`ci-security`](https://github.com/jonnymuir/ci-security), called
from the repo's `.github/workflows/security.yml`. C# uses `build-mode: manual` and replays the
real `dotnet build` of the solution named in `solution:`, so it sees the same code the build
compiles. Any `node-build` directories are built first, because their output ships as static
assets.

Results go to the repo's **Security** tab as SARIF. The action never fails its own job; the
`CodeQL` check-run goes red when a PR introduces a new alert, and the ruleset requires that
check.

## One-time setup

1. Turn off CodeQL default setup, which conflicts with this advanced setup:

   ```sh
   gh api -X PATCH repos/OWNER/REPO/code-scanning/default-setup -f state=not-configured
   ```

2. Triage existing alerts to zero, then add `CodeQL` to the ruleset's required checks.

## Day to day

- **Read alerts:** Security tab, Code scanning, or
  `gh api repos/OWNER/REPO/code-scanning/alerts --jq '.[] | [.number, .rule.id, .most_recent_instance.location.path] | @tsv'`.
- **Fix, don't dismiss.** Dismiss only a genuine false positive, choosing "False positive" or
  "Used in tests" with a written comment. Never "Won't fix" for a real finding.
- **Data built into HTML in browser code** is a class CodeQL's JS data flow misses here, which is
  why the `html-sink-ok` convention in [STANDARDS.md](../../STANDARDS.md#1-security-non-negotiable)
  exists.

## Running it locally

Rarely needed, since CI runs it on every PR. To reproduce an alert:

```sh
codeql database create codeql-db --language=csharp --command="dotnet build MyRepo.slnx"
codeql database analyze codeql-db codeql/csharp-queries:codeql-suites/csharp-security-extended.qls \
  --format=sarif-latest --output=codeql.sarif
```
