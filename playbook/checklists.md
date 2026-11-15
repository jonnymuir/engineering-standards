# Checklists

The short version of the playbook, for when you know why and need the steps. Each item links to
where it is explained.

## Starting a repo

- [ ] `scripts/adopt.sh <path> <Name>`, then fill in `CLAUDE.md` and `SECURITY.md`
      ([README](../README.md#adopting))
- [ ] Workflows edited for the repo's solution, clients and app; `perf.yml` removed if there is no
      app
- [ ] CodeQL default setup off, vulnerability alerts on, `CS_ACCESS_TOKEN` set, branch deletion on
      merge, private vulnerability reporting on
- [ ] Adoption PR opened and every workflow run once
- [ ] Ruleset applied with the checks that reported
      ([branch protection](../docs/tools/branch-protection.md))
- [ ] Plugin installed; agent permission defaults agreed ([guardrails](05-guardrails.md#permission-modes))
- [ ] `CLAUDE.md` says what the repo is and isn't, its projects, commands that run, how it
      releases ([harness](04-the-harness.md#the-repo-guide))

## Before building

- [ ] Who it is for, what problem, how we will know it worked ([product](03-product.md#1-start-from-the-need))
- [ ] Is any constraint I'm working around real intent, or current scope?
- [ ] The smallest version that tests the idea
- [ ] For a non-trivial direction: recommendation and trade-off agreed

## Before opening a PR

- [ ] Tests state behaviour from outside; I have seen the new ones fail ([testing](06-testing.md))
- [ ] Build with analyzers, tests, `node scripts/check-policies.mjs`,
      `node scripts/check-doc-links.mjs`
- [ ] `cs delta origin/main` shows no file worse ([CodeScene](05-guardrails.md#codescene-keeping-code-healthy-change-by-change))
- [ ] `git status` clean of runtime state; `gitleaks dir .` if an app was run
- [ ] Every new endpoint or tool has an explicit authorization requirement, and a test proves it
- [ ] Threat-surface changes named in the commit body
- [ ] Docs describe current state; new docs indexed; no em dashes
- [ ] Conventional Commit subject a package user would understand
- [ ] PR body: what, why, what was checked, what wasn't

## Merging

- [ ] Every required check green, branch current
- [ ] Merging is within the approval I have ([working with agents](09-working-with-agents.md#who-decides-what))
- [ ] Stacked child PRs retargeted to `main` first ([change flow](08-change-flow.md#stacked-prs))
- [ ] Other open PRs updated afterwards, one at a time

## Changing a dependency

- [ ] Read the release notes; for a major version, assume behaviour changes
- [ ] Tests pinning today's behaviour, passing on the old version ([testing](06-testing.md#pin-behaviour-before-you-change-it))
- [ ] Old and new outputs compared, and the comparison shown to catch a difference
- [ ] Consumers told, in the changelog, what changes for them
- [ ] Superseded Dependabot PRs checked against `main` before closing

## A flaky test or intermittent failure

- [ ] No re-run-and-merge; no added retry, sleep or timeout ([quality](02-quality.md#understand-variation-dont-tamper))
- [ ] Rate measured with a soak under realistic load
- [ ] Evidence captured while failing: dumps, logs, traces ([diagnosis](07-diagnosis.md))
- [ ] A theory that explains every fact, including the inconvenient one
- [ ] Mechanism reproduced in isolation, then deterministically in the real system
- [ ] Fix proven by a test that fails without it; soak rate compared
- [ ] What remains, and where it lives, written down

## Releasing

- [ ] Release PR: version files, changelog, README compatibility table, derived docs,
      pre-release checks ([change flow](08-change-flow.md#releases))
- [ ] Merged green
- [ ] A person has confirmed the tag
- [ ] Tag pushed; publish workflow green; registry shows the version
- [ ] Downstream repos bumped to the published version, in dependency order

## Filing upstream

- [ ] Contribution guide, templates and agent guide read ([upstream](10-contributing-upstream.md))
- [ ] Searched, including newer branches; not already fixed or requested
- [ ] Cause tied to code; real evidence; clean-install reproduction
- [ ] Fix per supported branch, with tests that fail before
- [ ] A person has approved posting
