# Branch protection

`main` is protected by a repository **ruleset** named "Main branch rules", applied to the default
branch with no bypass actors:

- No deletion and no force push.
- A pull request is required (no approvals, since this is a solo estate; the PR is where checks run).
- Required status checks, with **"branch must be up to date before merging"** on.

## Applying it

```sh
scripts/apply-ruleset.sh OWNER/REPO "security / security-all" all zizmor CodeQL
```

The script creates or replaces the ruleset from [`scripts/ruleset.base.json`](../../scripts/ruleset.base.json)
with the checks you name. Only name checks that already report on PRs; requiring a check that
never runs blocks every merge.

## Which checks to require

| Check | Require when |
|---|---|
| `security / security-all` | From the first PR. |
| `all` (or the repo's aggregate gate name) | From the first PR. |
| `zizmor` | From the first PR in a new repo; after triage in an existing one. |
| `CodeQL` | Once existing alerts are triaged to zero. |
| `baseline / DAST baseline` | Once `.zap/rules.tsv` is triaged and `fail-action: true`. |
| `delta` (CodeScene) | Never: advisory by design. |

## Merging

Auto-merge is off, so a PR is merged by hand once its checks are green:

```sh
gh pr checks 123 --watch
gh pr merge 123 --squash --delete-branch
```

An emergency merge means deliberately and visibly disabling the ruleset, then re-enabling it.
