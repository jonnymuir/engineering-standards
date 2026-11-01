# Engineering standards

How the repos in this estate are built to be safe, secure and simple, and the tooling that holds
them to it.

| | |
|---|---|
| [STANDARDS.md](STANDARDS.md) | The handbook: security, simplicity, testing, change flow, docs, writing style, agent guidance |
| [docs/tools/](docs/tools/README.md) | One guide per tool: CodeQL, Zizmor, supply-chain gates, ZAP, CodeScene, code budgets, k6, Playwright and Storybook, doc links, Trusted Publishing, branch protection |
| [template/](template/) | The files a repo starts with: build settings, workflows, policy scripts, Dependabot, ZAP rules, `SECURITY.md`, a `CLAUDE.md` skeleton |
| [scripts/](scripts/) | `adopt.sh` copies the template into a repo; `apply-ruleset.sh` protects `main` |
| [plugin/](plugin/) | A Claude Code plugin with `/release` and the `standards-review` skill |

Shared CI workflows (vulnerability gate, dependency review, CodeQL, Zizmor, ZAP) live in
[`jonnymuir/ci-security`](https://github.com/jonnymuir/ci-security), which repos pin by commit.
This repo holds the rules and the starting files; `ci-security` holds the reusable checks.

## Adopting

For a new repo, or an existing one being brought up to standard:

1. **Copy the template.** Existing files are never overwritten; the script lists what it skipped,
   so you can compare those by hand.

   ```sh
   scripts/adopt.sh ~/Documents/Projects/MyRepo MyRepo
   ```

2. **Fill in the placeholders** in `CLAUDE.md` (what the repo is, its projects, its Releasing
   section) and `SECURITY.md` (scope).
3. **Edit the workflows** for the repo: the solution and project paths in `ci.yml`, `security.yml`,
   `dast.yml` and `perf.yml`, any client `node-build` directories, and an npm entry per client in
   `dependabot.yml`. Delete `perf.yml` and `tests/perf/` if the repo has no app to load.
4. **One-time GitHub setup:**

   ```sh
   gh api -X PATCH repos/OWNER/REPO/code-scanning/default-setup -f state=not-configured
   gh secret set CS_ACCESS_TOKEN --repo OWNER/REPO        # CodeScene
   gh api -X PATCH repos/OWNER/REPO -F delete_branch_on_merge=true
   ```

   Turn on private vulnerability reporting under Settings, Security.
5. **Open the adoption PR** and let every workflow run once.
6. **Protect `main`** with the checks that reported on that PR:

   ```sh
   scripts/apply-ruleset.sh OWNER/REPO "security / security-all" all zizmor CodeQL
   ```

   Add `baseline / DAST baseline` once `.zap/rules.tsv` is triaged and `fail-action: true`.
7. **Install the plugin** in Claude Code:

   ```text
   /plugin marketplace add jonnymuir/engineering-standards
   /plugin install engineering-standards@jonnymuir-standards
   ```

## Where each repo stands

| Practice | Umbraco.Prism | Wayfinder | Wayfinder.Umbraco | ServiceDesignCompanion |
|---|---|---|---|---|
| `ci-security` SAST and supply chain | ✅ | ✅ | ✅ | ❌ |
| ZAP baseline | ✅ | ✅ (with signed-in leg) | ✅ | ❌ |
| Ruleset on `main` | ✅ | ✅ | ✅ | ❌ |
| CodeScene delta | ✅ | ✅ | ✅ | ❌ |
| `TreatWarningsAsErrors` and analyzers | ❌ | ✅ | ❌ | ❌ |
| Size and complexity budgets | ❌ | ✅ | ❌ | ❌ |
| k6 performance tripwire | ❌ | ❌ | ✅ | ❌ |
| `CLAUDE.md` links to `STANDARDS.md` | ❌ | ❌ | ❌ | ❌ |
| `/release` from the plugin | ❌ (own copy) | ❌ | ❌ | ❌ |

## Known gaps in the standards themselves

- **No secret scanner across all files.** Only Prism has a guard test, and it covers one key. A
  gitleaks job in `ci-security` would cover every repo.
- **Two changelog styles.** Wayfinder adds `[Unreleased]` entries in each PR; Prism writes the
  entry at release time from commits. These standards follow the release-time style.
- **Prism carries 91 skills and leftovers of an earlier Copilot setup** (`.squad/`, `.copilot/`,
  `.agents/`). Pruning them to the procedures that still apply follows the agent guidance in
  [STANDARDS.md](STANDARDS.md#7-agent-guidance).
