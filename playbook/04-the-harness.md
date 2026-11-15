# 4. The agent harness

## In short

- The harness is everything an agent reads or is constrained by: `CLAUDE.md` or `AGENTS.md`,
  skills, plugin commands, MCP instructions, memory, CI messages, and the code itself.
- `CLAUDE.md` holds only what is specific to the repo and links to the shared standards.
- Write guidance as you would for a capable new colleague: current, specific, reasoned, plain.
- Keep skills few. A skill is for a repeatable procedure, not a record of a one-off fix.
- Shared commands live in one plugin, not copied into each repo.
- Guidance for people who consume your package is tool-agnostic: plain markdown and MCP.
- Memory records corrections with the reason and how to apply them, and is pruned when wrong.
- Guidance is tested: run an evaluation after changing it.

## What the harness is

An agent's behaviour in a repo is shaped by what it reads and what stops it. In rough order of
when it meets them:

| Layer | Example in this estate | Loaded |
|---|---|---|
| Repo guide | `CLAUDE.md` (Claude Code), `AGENTS.md` (most other agents) | Every session |
| Shared standards | [`STANDARDS.md`](../STANDARDS.md), linked from every `CLAUDE.md` | When followed |
| Skills and commands | The [plugin](../plugin/): `/release`, `standards-review` | When relevant |
| Memory | Corrections and preferences that persist across sessions | Index every session, detail on demand |
| Runtime knowledge | An MCP server's instructions, resources and prompts | When connected |
| The code | Names, types, comments, tests | When read |
| Feedback | Compiler errors, analyser findings, test failures, CI messages | When it acts |

The last two matter as much as the first. An agent learns the codebase's conventions by reading
it, so code that is consistent teaches consistency. And a check that fails with a clear message is
guidance delivered at exactly the right moment.

## The repo guide

`CLAUDE.md` (or `AGENTS.md`) is read at the start of every session, so every line in it costs
attention on every task. Keep it to what is specific to this repo:

- What this is, in a paragraph, including what it deliberately does not do.
- Projects, as a table: path and purpose.
- Build and test commands that run as written, including the order when it matters ("the
  editor bundle must exist on disk before `dotnet pack`").
- Releasing: version files, pre-release checks, what the tag publishes. The `/release`
  command reads this section.
- Rules specific to this repo, each with its reason.

Everything general (security, simplicity, testing, writing) is a link to
[`STANDARDS.md`](../STANDARDS.md), not a copy. Copies drift; links don't. The
[template](../template/CLAUDE.md) is the skeleton.

What does not belong there: history ("we used to..."), a changelog, long tutorials (link to
`docs/`), and anything a tool enforces anyway, unless knowing about it saves a failed run.

### Write rules that survive contact

A rule an agent can follow:

```markdown
- Every endpoint carries an explicit policy (`RequireAuthorization`). Anonymous access needs
  a comment naming why. New middleware runs in a test host with the real pipeline.
```

A rule an agent will misapply:

```markdown
- Be careful with security.
```

The first is checkable, says where it applies, and implies its test. When an agent gets something
wrong, ask what it would have needed to read to get it right, and whether that can be a check
instead of a sentence.

## Skills and the plugin

A skill is loaded into context when its description matches the task, so a stale or one-off skill
costs every session and can steer an agent wrong. The rule:

- Keep a skill that encodes a repeatable procedure the repo actually performs (cutting a
  release, reviewing against the standards).
- Delete a skill that records how one bug was fixed. That knowledge belongs in the commit, a
  test, or a line in `CLAUDE.md` if it is a standing rule.
- Share procedures used in several repos through one plugin
  ([`plugin/`](../plugin/)), installed everywhere, rather than a copy per repo that will drift.

Review skills when you review the repo guide. A repo that accumulated dozens of narrowly named
skills (one estate repo had over a hundred from an earlier multi-agent setup) is carrying old
decisions into every new session.

## Guidance for your consumers' agents

If you publish a package, the people who use it will build with their own agents, and those agents
will never see your repo's `CLAUDE.md` or skills. They see:

- the package README on the registry,
- your public docs,
- your MCP server, if you ship one: its instructions, resources and prompts,
- any template you provide for their repo (for example a `dotnet new` template that adds an
  `AGENTS.md`).

So guidance for consumers lives there, in plain markdown any tool can read, with MCP as the
portable runtime surface. Tool-specific packaging (a Claude Code skill, say) is at most a thin
pointer to the canonical content, never the only copy.

This estate learned it the hard way: a designer's agent built a site as hand-made CMS pages even
though the service design packages were installed, because nothing the agent read told it to use
them. The fix put the guidance where that agent would look: a "building with" guide that is also an
MCP resource, default MCP server instructions, task-shaped MCP prompts, and an `AGENTS.md`
template.

## Testing the guidance

Guidance is code for agents, so it gets tested. The estate's `evals/agent-build/` (in
Wayfinder.Umbraco) is the pattern:

1. A fixed brief: a realistic task with the traps in it (a calculation, a system with no API, a
   look to match).
2. A fresh environment, with and without the guidance.
3. A scorer that reads the result's files and checks for the right shape (services as blueprints,
   no hand-built forms, no arithmetic in host code).
4. Run it after changing any guidance, with each agent you care about, and compare with and
   without.

It is a smoke test, not a grade. Read the agent's own report and the output too. The value is in
noticing when a guidance change made things worse.

## Memory

Agents that keep memory across sessions need the same discipline as docs:

- One fact per entry, with the reason and how to apply it. "Merge green PRs for this repo
  once checks pass; not deploys, force pushes or tags" is usable. "User likes merging" is not.
- Corrections are the most valuable entries. When a person says "I've told you this before",
  that belongs in memory, and if it applies to every repo, in the standards.
- Prune. A memory that turned out wrong, or describes code that has moved, is worse than none.
- Don't store what the repo already records. Code structure, history and past fixes are in the
  code and git. Memory holds what isn't derivable: preferences, decisions, the non-obvious.
- Promote. A memory that holds across repos becomes a rule here, with its evidence.

## Runtime knowledge through MCP

When an agent works against a running system (authoring content, reading data, driving a
workflow), the system itself is the best place for guidance: it knows its own rules and its
current state. An MCP server can carry:

- Instructions sent on connect: how to work with this system, in a few paragraphs.
- Resources: the guides, the schema, examples, readable on demand.
- Prompts: named, task-shaped starting points ("design a service", "convert an existing
  design").
- Tools whose descriptions and errors teach: validate before save, simulate before publish,
  and say what is wrong in words the agent can act on.

A host that embeds the server can add its own context to the defaults (appended under "About this
host") rather than replacing them, so the system's own rules always arrive.
