# Supply chain: vulnerability gate, dependency review, Dependabot

## NuGet vulnerability gate

Runs `dotnet list package --vulnerable --include-transitive` over the solution. A High or Critical
advisory fails the job unless its GHSA or CVE id is listed in `.github/allowed-advisories.txt`.
Moderate and Low go to the job summary only.

`.github/allowed-advisories.txt` holds one accepted advisory per line, with a reason and a date to
revisit:

```text
GHSA-xxxx-xxxx-xxxx # only reachable through the dev-only Aspire host; revisit 2027-01
```

Prefer fixing over allowing. A transitive vulnerability is usually fixed by pinning the patched
version as a direct `PackageReference` (or `PackageVersion` under central package management),
the smallest change that clears it.

Run it locally before adding a package:

```sh
dotnet list MyRepo.slnx package --vulnerable --include-transitive
```

## Dependency review

On pull requests, `actions/dependency-review-action` fails if the PR adds a dependency with a
High or worse known vulnerability. It looks only at what the PR changes.

Both gates roll up into the single required check **`security / security-all`**, from
`dotnet-security.yml` in [`ci-security`](https://github.com/jonnymuir/ci-security).

## Dependabot

`.github/dependabot.yml` lives in each repo, because Dependabot only reads its own repo's file.
The template's version:

- **NuGet, npm and GitHub Actions**, weekly on Mondays.
- **`cooldown: default-days: 7`**: a release must be a week old before Dependabot proposes it,
  which avoids pulling in a compromised release before it is noticed and yanked.
- **Grouped** minor and patch updates, so one PR per ecosystem instead of dozens.
- **The `github-actions` entry** also keeps the `ci-security` SHA pin current.

Major updates arrive as separate PRs. Read the release notes before merging them.
