---
description: Cut a release. Infer the semver bump from Conventional Commits, bump versions, draft the CHANGELOG, open a release PR
---

Cut a release for this repo. Read the repo's `CLAUDE.md` first: its **Releasing** section names
the version files to bump, the pre-release checks to run, and what the tag publishes. If it has no
Releasing section, stop and ask.

## 1. Find the last release and the commits since

```bash
git fetch --tags origin
git tag --list 'v*' --sort=-version:refname | head -1
git log {last_tag}..origin/main --format="%H %s%n%b" --no-merges
```

With no tags, treat all history as unreleased. Read subjects and bodies: bodies carry
`BREAKING CHANGE:` notes.

## 2. Infer the bump

- **major:** a `BREAKING CHANGE:` body line, or `!` after the type (`feat!:`, `fix!:`)
- **minor:** any `feat:`
- **patch:** `fix:`, `perf:`, `refactor:`, `test:`, `chore:`, `docs:`, or no prefix

Take the highest. With no conventional signals, default to patch and say so.

## 3. Announce and confirm

Tell the user the last tag, the number of commits, the bump and which commits drove it, and the new
version. Ask: **"Shall I cut vX.Y.Z as a {bump} release?"** Wait for a yes.

## 4. Branch and bump

```bash
git checkout -b release/v{version} origin/main
```

Update every version file the Releasing section lists, keeping them in sync.

## 5. Draft the CHANGELOG entry

Add a section at the top of `CHANGELOG.md`, below the heading and intro:

```markdown
## [v{version}] - {YYYY-MM-DD}

### Breaking changes
- ...

### New features
- ...

### Fixes and improvements
- ...
```

Omit empty sections. Drafting rules:

- Plain English for someone using the package: what changed and why it matters to them.
- Active voice, present tense: "Adds", "Fixes".
- One change per bullet. No commit hashes or internal references.
- Breaking changes say how to upgrade.
- Skip internal chores (CI, dependency bumps) unless they affect users.
- No em dashes.

## 6. Pre-release checks

Run the checks the Releasing section lists. Stop on any failure and fix it first.

## 7. Show the draft

Print the CHANGELOG entry and wait for approval or edits.

## 8. Commit, push, open the PR

Stage only the version files and `CHANGELOG.md`:

```bash
git commit -m "chore: release v{version}"
git push -u origin release/v{version}
gh pr create --title "chore: release v{version}" --body "..."
```

The PR body gives the bump and what drove it, the release notes, and the tagging step below.

## 9. Remind

Return the PR URL and remind the user that after merging:

```bash
git checkout main && git pull
git tag v{version} && git push origin v{version}
```

The tag triggers the publish workflow.
