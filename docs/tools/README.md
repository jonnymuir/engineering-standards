# Tools

What each tool catches, when it runs, and whether it can block a merge.

| Tool | Catches | Runs | Blocks merge? | Guide |
|---|---|---|---|---|
| NuGet vulnerability gate | Known High/Critical vulnerabilities in direct and transitive packages | PR, push to main, weekly | Yes (`security / security-all`) | [supply-chain.md](supply-chain.md) |
| Secret scan (gitleaks) | Credentials and generated keys committed to any file | PR, push to main, weekly | Yes (`security / security-all`) | [secret-scanning.md](secret-scanning.md) |
| Dependency review | A PR that adds a vulnerable dependency | PR | Yes (`security / security-all`) | [supply-chain.md](supply-chain.md) |
| Dependabot | Outdated packages and actions | Weekly, 7-day cooldown | No (opens PRs) | [supply-chain.md](supply-chain.md) |
| CodeQL | Injection, unsafe data flow and other code-level security bugs (C#, JS/TS) | PR, push to main, weekly | Yes (`CodeQL`) | [codeql.md](codeql.md) |
| Zizmor | Insecure GitHub Actions workflows | PR, push to main, weekly | Yes (`zizmor`) | [zizmor.md](zizmor.md) |
| OWASP ZAP baseline | Missing security headers, cookie flags, info disclosure in the running app | PR, push to main, nightly | Yes once tuned (`baseline / DAST baseline`) | [zap.md](zap.md) |
| CodeScene | A PR that lowers the Code Health of a file it touches | PR | No (advisory `delta` check) | [codescene.md](codescene.md) |
| Code budgets | Files, methods and functions over their size or complexity budget | PR (in CI) | Yes (via the CI `all` gate) | [code-budgets.md](code-budgets.md) |
| k6 | Order-of-magnitude performance regressions | Nightly, on demand | No | [k6.md](k6.md) |
| Playwright and Storybook | Broken user-visible behaviour and accessibility | PR (in CI) | Yes (via the CI `all` gate) | [playwright-and-storybook.md](playwright-and-storybook.md) |
| Doc link checker | Broken relative links and heading anchors | PR (in CI) | Yes (via the CI `all` gate) | [doc-links.md](doc-links.md) |
| NuGet Trusted Publishing | Stored API keys that could leak | On a `v*` tag | Not a check | [trusted-publishing.md](trusted-publishing.md) |
| Branch ruleset | Direct pushes, force pushes, merging red or out-of-date branches | Always | Yes | [branch-protection.md](branch-protection.md) |

## Where the checks live

- **Shared reusable workflows** (vulnerability gate, dependency review, secret scan, CodeQL, Zizmor, ZAP) live in
  [`jonnymuir/ci-security`](https://github.com/jonnymuir/ci-security). A repo calls them from
  small `security.yml` and `dast.yml` files, pinned to a commit SHA.
- **Repo-level workflows** (CI, CodeScene, k6, release) are copied from [`template/`](../../template/)
  and edited for the repo.
