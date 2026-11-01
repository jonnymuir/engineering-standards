# Engineering standards

How every repo in this estate is built: safe, secure and simple. Each repo's own `CLAUDE.md`
links here and adds only what is specific to that repo.

The tools that enforce these rules are described in [docs/tools/](docs/tools/README.md).

## 1. Security: non-negotiable

Security correctness is a release gate, not a follow-up.

1. **Auth and trust-chain flows are spec-exact.** OAuth 2.0, OIDC, PKCE and discovery handling
   follow the RFCs: no fabricated identifiers, no "works for now" shims. If the spec and an easier
   path conflict, the spec wins or the work stops and the trade-off is raised.
2. **Deny by default at every new seam.** A new route, endpoint or tool ships with an explicit
   authorization requirement documented at the call site. Anonymous access carries a written
   reason in the code.
3. **Libraries take no auth or tenant bypass.** Identity, tenancy and authorization enter through
   a seam the host supplies. Never a hardcoded actor, tenant or allow-all default.
4. **No secrets in source, committed config, logs or test fixtures.** Secrets live in a vault,
   user-secrets or a server-side environment file. Watch for tools that write secrets into
   tracked files on first run (Umbraco writes `Imaging:HMACSecretKey` into `appsettings.json`).
   The secret scan in `security-all` blocks them; a real leak is rotated, not just removed.
5. **Evaluate every change through the CIA lens.** Confidentiality (cross-user or cross-tenant
   leakage), integrity (can input forge state or skip a step), availability (can input force
   unbounded work). Anything that moves the threat surface is called out in the commit body and
   the PR description.
6. **Every boundary you touch gets a regression test** that goes red if the isolation or
   validation regresses.
7. **No unreviewed HTML built from data in browser code.** `innerHTML`, `insertAdjacentHTML`,
   `unsafeHTML` and similar sinks take only literals. Anything built from data needs an
   `// html-sink-ok: <reason naming the escaping>` comment.
8. **Report findings plainly.** No minimising language ("just a hack", "edge case"). Name the
   defect and its impact.
9. **Supply chain:** actions pinned to a full commit SHA, `persist-credentials: false` on every
   checkout, secrets passed through `env:` and never inlined into `run:`, Dependabot updates
   held for a 7-day cooldown, packages published through NuGet Trusted Publishing rather than a
   stored API key.

## 2. Simplicity

1. **No speculative abstractions.** Solve the problem at hand.
2. **Keep things small.** Budgets: C# files 400 lines, C# methods 60 lines, TypeScript and
   JavaScript files 500 lines, cyclomatic complexity 15, class coupling 40 (method) and 60
   (type), TypeScript functions 80 lines and cognitive complexity 15.
3. **Ratchet, not amnesty.** Code already over a budget is listed in a baseline that may only
   shrink. New code starts within budget: do not add to a baselined file, add a new one.
4. **One concern per class.** More than about seven collaborators, or a name that needs "And",
   "Manager" or "Helper", means split it.
5. **One source of truth.** Never hand-mirror a type across languages (generate it) and never
   cast past a mismatch (`as unknown as`): fix the type.
6. **No back-compat shims.** No aliases, fallback reads or "also accept the old name" branches.
   Change a shape everywhere and migrate the fixtures.
7. **No duplication across packages or repos.** Shared CI lives in
   [`ci-security`](https://github.com/jonnymuir/ci-security); shared rules live here.
8. **Check whether a constraint is real intent or just current scope** before building a
   compatibility layer around it.

## 3. Testing: behavioural contracts, not implementation mirrors

Every test answers "what should happen, observed from outside this unit?".

1. **Test behaviour through public seams**: a public method, a rendered HTML fragment, an HTTP
   response, the visible UI.
2. **`InternalsVisibleTo` is a smell, not a tool.** Needing it means the test is at the wrong
   level.
3. **Prefer real in-memory implementations over mocking frameworks.** No database mocks:
   integration tests use a real test host.
4. **A behaviour-preserving refactor must not turn a test red.**
5. **Name tests as behaviours, one behaviour per test.**
6. **Prefer the coarsest test that is fast and deterministic.** Reserve live browser runs for
   behaviour that only emerges from a booted host, and keep those few.
7. **Playwright uses semantic selectors only**: `getByRole`, `getByLabel`, `getByText`,
   `aria-*`, `data-*` hooks. Never CSS classes or web component tag names.
8. **Error states are asserted twice**: the `[role="alert"]` summary and the field-level message.
9. **Every suite is green before a PR.**

## 4. Change flow

1. **Every change reaches `main` through a pull request.** `main` is protected by a ruleset: no
   deletion, no force push, PR required, required checks, branch current before merge, no bypass.
   An emergency merge means deliberately and visibly disabling the ruleset.
2. **Branches:** `{type}/{issue-number}-{kebab-slug}` or `{type}/{kebab-slug}`.
3. **[Conventional Commits](https://www.conventionalcommits.org/).** `feat:` is minor; `fix:`,
   `perf:`, `refactor:`, `test:`, `chore:`, `docs:` are patch; `feat!:` or a `BREAKING CHANGE:`
   body line is major and says how to upgrade. Write subjects a package user can understand,
   because the changelog is built from them.
4. **One aggregate CI gate.** Each CI workflow ends with an `all` job that depends on every other
   job, so the ruleset names one check per workflow.
5. **Releases** go through a release PR that bumps the version and writes the `CHANGELOG.md`
   entry from the commit history (the `/release` command in the plugin). Merging is followed by
   a `v{version}` tag, which triggers the publish workflow.
6. **Never commit generated runtime state.** Run the app, then check `git status` before staging:
   first-run tools rewrite config files.

## 5. Documentation

1. **Docs describe current state**, never the history of how it was reached ("originally",
   "verified live", "found while"). That narrative belongs in the commit or PR.
2. **`docs/README.md` indexes every current document.** Superseded docs go to `docs/archive/` and
   are never linked from current docs.
3. **Docs are checked by CI.** `scripts/check-doc-links.mjs` fails on a broken relative link or
   heading anchor. Where a doc teaches code, a test runs that code (README quickstarts, example
   files, generated screenshots).
4. **READMEs shipped inside a NuGet package** use absolute GitHub links and
   `raw.githubusercontent.com` images, because relative links don't resolve on nuget.org.
5. **Production infrastructure details** (hosts, secrets, service files) live in the private
   infra notes, never in a public repo.

## 6. Writing style

- No em dashes anywhere: prose, docs, code comments, commit messages. Use a comma or a full stop.
- Plain English, short sentences, active voice.
- Emojis sparingly, only as real signposts, never decoration.
- Comments only where the reason is genuinely non-obvious; match the density of the surrounding
  code.

## 7. Agent guidance

Repos are developed with AI agents, so the guidance they read is part of the harness.

- **`CLAUDE.md` holds only what is specific to the repo**: what it is, its projects, build and test
  commands, and its own rules. It links to this file for everything else instead of copying it.
- **Keep skills few and current.** A skill is loaded into every session's context. Delete skills
  that record a one-off fix; keep the ones that encode a repeatable procedure.
- **Guidance for consumers of a package stays tool-agnostic** (plain markdown that any agent can
  read), because users of the package may not use Claude Code.
- **Shared commands come from the plugin** in this repo, not from copies in each repo.
