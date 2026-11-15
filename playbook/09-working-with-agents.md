# 9. Working with agents

## In short

- The person sets direction and owns irreversible decisions; the agent does the work and reports
  faithfully.
- Standing approvals are explicit and scoped: "merge green PRs in this repo" is not "deploy" or
  "tag".
- On a non-trivial direction, the agent recommends with the key trade-off and waits. On
  everything else it gets on.
- Reports are true before they are reassuring: what was done, what was verified, what was
  skipped, what is still wrong.
- Corrections become durable: memory first, then the standards when they hold across repos.
- The agent asks whether a constraint is real intent before building around it.
- A blocked action is information. Find the safe route or ask; never work around the block.

## Seating the team

In Brooks's surgical team every role served one person's design (see
[Principles](01-principles.md#a-surgical-team-with-agents-in-every-other-chair)). Give agents work
in those terms:

- Copilot: "Implement this, within these constraints; tell me where the design pushes back."
- Toolsmith: "Write a check that fails when this mistake recurs."
- Tester: "State this behaviour as tests at the public seam; show me they fail without the
  change."
- Language lawyer: "Read the upstream source on every supported branch and tell me exactly
  where this goes wrong."
- Editor: "Write the release notes from these commits, for a package user."
- Administrator: "Work through the dependency PRs; merge what is green and superseded-checked;
  report the rest."

Several roles can run at once. The surgeon's job is to keep them pointed at one design and to make
the calls only the surgeon can make.

## Who decides what

The useful split is not "the agent writes, the person reviews". It is about reversibility:

| | Agent | Person |
|---|---|---|
| Reversible work: code, tests, branches, PRs, local runs | Does it | Reviews the result |
| Merging to `main` | With a scoped standing approval, when every check is green | Gives or withdraws the approval |
| Irreversible or outward-facing: release tags, deploys, public posts, deleting others' work | Prepares it, then asks | Confirms each time |
| Direction: architecture, scope, what not to build | Recommends, with the trade-off | Decides |

Approvals are scoped to what was said. "You can merge if all is green" covers merging green PRs; it
does not cover tagging a release or posting an issue on another project's tracker. When the scope
is unclear, the agent asks once, briefly, and doesn't assume the wider reading.

## Recommend, then wait

For a decision that shapes later work (an architecture, a migration approach, what to simplify),
the agent gives a recommendation and the key trade-off in two or three sentences, then waits for
agreement. It doesn't launch into a full plan or implementation unprompted. For everything else,
which is most things, it acts: a question about a detail the code or a sensible default can settle
is a wasted round trip.

## Report faithfully

The person can't watch every step, so the report is the system's view of what happened. A report
that sounds better than the truth is a breakdown in its own right.

- Lead with the outcome, then the detail.
- Say what was verified and how: "768 tests pass; the byte-for-byte comparison of 12 awkward
  files is identical; the live end-to-end run was not done."
- Give rates, not anecdotes: "stalled once in 40 runs under heavy load", not "seems fixed".
- Name residual risk and where it lives: "the remaining gap is inside the framework; it is
  fixed in their next major version".
- Own mistakes plainly: what went wrong, what it affected, what was done about it, and what
  wasn't affected. In this estate an agent's failed shell command partially applied one of the
  person's old stashes to a scratch copy; the report said so, said the stash was untouched and the
  main working copy wasn't affected, and the lesson (never chain a stash pop after a command that
  might fail) went into practice.
- Don't predict a result that hasn't arrived. A background job still running is "still
  running".

## Make corrections durable

When a person corrects an agent, the correction should outlive the session:

1. Memory: one fact, with why it matters and how to apply it, linked to related entries.
2. The repo's `CLAUDE.md`, if it is a standing rule for that repo.
3. [`STANDARDS.md`](../STANDARDS.md) and, if possible, a check, once it holds across repos.

The test of whether this is working: the person stops having to say the same thing twice. Several
rules in the standards (no em dashes, docs describe current state, behavioural tests) began as a
person saying "I've told you this before".

## Habits worth keeping

These came from real corrections in this estate:

- Is this constraint intent or scope? Before building a compatibility layer around a
  limitation, check whether it was a decision or just where the code had got to.
- Capability contracts, not runtime guesses. When one component needs to know what another can
  do, derive it from something both share (a closed type list, a build artefact), not by calling
  the other at runtime or assuming.
- Describe references precisely. When matching a design, report measurements as approximate
  ranges ("a slight radius, about 4 to 6 px") rather than rounding to extremes ("square corners").
- Disposable means disposable. If a local database is seeded from code, wipe it to test a
  seeding change rather than patching it by hand.
- Generated code is held to the same standard as handwritten code, because people and agents
  will maintain it.
- Treat the person's working copy as theirs. Use a separate worktree for agent work, leave
  uncommitted changes alone, and never discard or overwrite without looking first.

## When the agent is blocked

Permission modes and classifiers sometimes refuse an action: a force push, installing a tool,
merging without approval. The right response:

1. Look for a safer way to the same goal (merge `main` into the branch instead of force-pushing).
2. If there isn't one, finish everything that doesn't depend on it, then explain what is needed and
   why, and let the person decide (they can run the command themselves).
3. Never try to get around the block by other means.

## Long-running work

Agents increasingly run long tasks: soak tests, CI waits, release chains. Keep them legible:

- Run waits in the background and get notified, rather than polling.
- Give the person a short status when they ask, or after a long silence: what is done, what is
  running, what needs them.
- Clean up afterwards: scratch worktrees, merged branches, background jobs.
