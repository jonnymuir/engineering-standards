# MyRepo: Project Guide

## What this is

One paragraph: what the repo is, who uses it, and what it deliberately does not do.

Engineering standards (security, simplicity, testing, change flow, docs, writing style) are in
[jonnymuir/engineering-standards](https://github.com/jonnymuir/engineering-standards/blob/main/STANDARDS.md).
Follow them; this file adds only what is specific to this repo.

## Projects

| Project | Purpose |
|---|---|
| `src/MyRepo.Site` | |

## Build and test

```bash
dotnet build MyRepo.slnx
dotnet test MyRepo.slnx
node scripts/check-policies.mjs
node scripts/check-doc-links.mjs
```

## Releasing

Version files to bump, pre-release checks to run, and what the tag publishes. The `/release`
command reads this section.

## Rules specific to this repo

-
