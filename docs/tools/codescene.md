# CodeScene

Code Health analysis. CodeScene scores each file from 1 to 10 on maintainability signals: long
methods, deep nesting, complex conditionals, duplication, low cohesion, too many arguments.

## How it is wired

`.github/workflows/code-health.yml` (from [the template](../../template/.github/workflows/code-health.yml))
runs the CodeScene CLI's **delta** analysis on every pull request. It compares each file the PR
touches against the base branch and fails only when a file ends up with a **lower** score than
before.

- New files, untouched debt and findings that leave the score no lower never block.
- Nothing is uploaded. The CLI analyses the checkout on the runner and uses the token only to
  confirm the licence.
- The check is called `delta`. It is advisory: not in the ruleset's required checks, but a red
  `delta` is a reason to fix the change before merging.

## One-time setup

Add a CodeScene access token as the repository secret `CS_ACCESS_TOKEN`. Fork and Dependabot PRs
don't receive secrets, so the job skips itself for them with a notice.

## Day to day

Check a change before pushing it:

```sh
cs delta origin/main          # what this branch does to Code Health
cs review path/to/File.cs     # findings for one file
```

The CodeScene IDE extension shows the same findings inline while editing.

CodeScene and the [code budgets](code-budgets.md) overlap on purpose. Budgets are hard limits on
size and complexity that CI enforces; CodeScene catches the softer signals (nesting, duplication,
cohesion) and stops a PR making any file worse.
