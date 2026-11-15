# 10. Contributing upstream

## In short

- Read the project's contribution guide, issue template, PR template and any agent guide
  (`CLAUDE.md`, `AGENTS.md`) first, and follow them.
- Search existing issues and PRs, including newer branches, before filing. It may be known or
  fixed.
- One issue per defect, in the template's own fields.
- Tie the root cause to specific code; show real evidence (stack traces, real error responses,
  versions).
- Give steps that reproduce it on a clean install, without your own product in the way.
- Offer the fix for each supported branch, with tests that fail before and pass after.
- Fit the project's principles, not your call site: fix the contract, not one caller.
- Posting is outward-facing: a person approves before anything is published.

## Why it is worth doing well

Most of an app is other people's code, so most of its bugs are too. A good report turns a
maintainer's afternoon of investigation into ten minutes of review. A good PR gets merged. And it
builds a relationship with the projects you depend on.

The pattern below comes from three issues and six PRs this estate contributed to Umbraco.AI (an
error-classification fix, an automation retry-category fix, a package floor raise, each for two
major versions). The maintainer merged all six within a day and said the PRs were easy to review
because of "clear write-ups, solid tests, and real API responses to test against".

## Before you write anything

1. Read the guides. `CONTRIBUTING.md`, the issue and PR templates, branch naming, which branch
   to target, and the project's own agent guide if it has one. Large projects often say when to
   open an issue first and what changes they don't want (breaking changes, new config options,
   broad refactors).
2. Search. The error text, the mechanism, the code path. Check open and closed issues, and
   recent PRs on newer branches.
3. Check whether it is fixed already. A newer major version may have fixed it. If it has, the
   useful contribution may be evidence on an existing backport request, or nothing at all.
4. Confirm on current source, on each supported branch, not only the binary you run.

## The issue

Use the project's template fields, and fill them with specifics:

- Version: exact, and which other branches the code is unchanged on.
- Summary: the defect and its user-visible effect, in two or three sentences.
- Cause: the specific type, method and condition, and why it goes wrong. Compare with a
  sibling that does it right if there is one ("the Anthropic provider overrides this; the Google
  one doesn't").
- Specifics: real evidence. Verbatim error responses, stack traces, extended error codes,
  versions bisected ("1.21.1 fails, 1.22.0 works").
- Steps to reproduce: on a clean install, as few as possible, without your own product
  installed. If it needs timing, say how often it happens and how to make it likely.
- Expected and actual.
- Offer: "I have a fix ready for both branches and will open PRs that reference this issue."

Describe the problem, not just your preferred solution; the maintainers may know a better one.

## The fix

- Small and focused. One defect per PR; no drive-by formatting.
- In the shape of the codebase. Follow its patterns and its stated principles. If the project
  asks for fixes at the contract rather than one caller, fix the rule the layer must uphold.
- Tests that fail without it. State that you watched them fail. Use real responses captured
  from the real system as fixtures where you can.
- A PR per supported branch, each linking the issue with a closing keyword.
- A testing section that says what was run, what was tested against the real system, and what
  wasn't reproduced live.
- Breaking changes: none, or stated with the upgrade path.

## Know when not to

If the project has already fixed it in a version you can move to, or a request for exactly your
fix is already open, adding another issue costs the maintainers time. Add evidence to the existing
thread only if it changes the picture (for example, proof that an older version the fix wasn't
backported to is affected), and otherwise leave it.

## Agents and upstream work

An agent can do almost all of this: read the guides, search, confirm on source, build a clean
reproduction, write the issue and the PRs. It does not post. Anything published on another
project's tracker is reviewed and approved by a person first, because it speaks for them and can't
be unsaid.
