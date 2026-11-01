# Zizmor

Static analysis for GitHub Actions workflows. Workflows run with repository secrets and write
access, so they are part of the attack surface.

## What it catches

| Finding | Fix |
|---|---|
| `template-injection` | Pass `${{ }}` values through `env:` and use `"$VAR"` in `run:`, never inline them. |
| `artipacked` | `persist-credentials: false` on every `actions/checkout`. |
| `unpinned-uses` | Pin every action to a full commit SHA with the tag in a comment: `uses: actions/checkout@3d3c42e... # v7.0.1`. |
| `excessive-permissions` | Top-level `permissions: contents: read`, and grant more only on the job that needs it. |
| `dangerous-triggers` | Avoid `pull_request_target` and `workflow_run` with untrusted input. |

## How it is wired

Part of `dotnet-security.yml` in [`ci-security`](https://github.com/jonnymuir/ci-security). It
scans the calling repo's `.github/workflows/`, uploads SARIF to the Security tab, and the
`zizmor` check-run is required by the ruleset.

## Day to day

Run it before pushing a workflow change:

```sh
uvx zizmor .github/workflows
```

Suppress only with a reason on the same line, for example
`# zizmor: ignore[template-injection] value is a fixed repo variable`.
