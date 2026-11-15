# The AI-native repo playbook

How a small, surgical, AI-native team builds software: one or two people who hold the design,
with AI agents in every supporting role, moving fast without the quality drifting. It covers how
to set up a repository for that way of working, and how to work in it. It is drawn from running a
small estate of real products (an Umbraco package, a service design engine, its Umbraco host, a
static site) where most of the code is written with agents and every change still has to be
secure, simple and tested.

[`STANDARDS.md`](../STANDARDS.md) is the rulebook: short, normative, the thing a review checks
against. This playbook is the reasoning and the method behind those rules: why each one exists,
how to set it up, and what to do when it bites. The [tool guides](../docs/tools/README.md) cover
each tool in detail.

## The team this is for

Fred Brooks described the surgical team in *The Mythical Man-Month*: one surgeon who does the
critical work and holds the design, surrounded by specialists who make that one mind effective (a
copilot, a toolsmith, a tester, an editor, a language lawyer). It preserved what Brooks called
conceptual integrity, and it was too expensive for most organisations to staff. Lockheed's Skunk
Works showed what a small, trusted team with real authority, a simple release system and quality
built into the work could do: "be quick, be quiet, be on time".

AI agents make that team affordable. The person is the surgeon; agents fill the other chairs. What
keeps the result coherent is not more people checking, but the system around the work: knowledge
written down where it is needed, guardrails that inspect every change, and a clear line between
what agents do alone and what a person decides. That system is what this playbook describes.

## The idea in one paragraph

An agent starts every session knowing nothing about your repo except what it can read. So does a
new colleague, and so do you after six months away. Everything that matters therefore has to be
**knowledge in the world**, not knowledge in someone's head: rules written down where the work
happens, checks that run on every change, tests that state behaviour, docs that describe what is
true now. Content written that way serves the agent and the human equally well, because they need
the same thing: the right fact, at the moment of the decision, in plain words.

## Chapters

| | Read it when |
|---|---|
| [1. Principles](01-principles.md) | You want the thinking that ties the rest together |
| [2. Quality](02-quality.md) | You want to know what "good" means here: a system with nothing in the way |
| [3. Product](03-product.md) | You are deciding what to build and how you will know it worked |
| [4. The agent harness](04-the-harness.md) | You are writing `CLAUDE.md`, `AGENTS.md`, skills, MCP instructions or memory |
| [5. Guardrails](05-guardrails.md) | You are choosing or wiring checks: SAST, DAST, dependencies, secrets, CodeScene, k6, and the agent's own |
| [6. Testing](06-testing.md) | You are writing tests, changing a dependency, or fighting a flaky suite |
| [7. Diagnosing the hard ones](07-diagnosis.md) | Something fails intermittently and the obvious theory hasn't held |
| [8. Change flow and releases](08-change-flow.md) | You are opening, stacking or merging PRs, or cutting a release |
| [9. Working with agents](09-working-with-agents.md) | You are deciding what an agent does alone and what it asks about |
| [10. Contributing upstream](10-contributing-upstream.md) | You have found a bug in someone else's project |
| [Checklists](checklists.md) | You want the short version for a new repo, a PR, a release or an incident |

## How to use it

- **Starting a repo:** run [`scripts/adopt.sh`](../scripts/adopt.sh) (see the
  [README](../README.md#adopting)), then read chapters 1 to 5.
- **As an agent:** each chapter opens with **In short**, a list you can act on directly. The rest
  of the chapter says why, which is what you need when a case doesn't fit the list.
- **Changing it:** rules come from practice. Something proves itself in a repo first, then lands
  here, with the repo it came from named in the PR. See [`CLAUDE.md`](../CLAUDE.md).
