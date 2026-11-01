# NuGet Trusted Publishing

Packages are pushed to nuget.org without a stored API key. The publish workflow exchanges the
run's short-lived GitHub OIDC token for a NuGet key that expires within an hour.

## How it is wired

`.github/workflows/package-release.yml` runs on a `v*` tag:

1. Verify that the packable projects' `<Version>` matches the tag, and fail if not.
2. Build, test and `dotnet pack`.
3. Create a GitHub Release with the packages attached.
4. Log in with Trusted Publishing and push:

```yaml
permissions:
  contents: read
  id-token: write   # NuGet Trusted Publishing (OIDC token exchange)
steps:
  - name: NuGet login
    id: login
    uses: NuGet/login@8d196754b4036150537f80ac539e15c2f1028841 # v1
    with:
      user: ${{ secrets.NUGET_USER }}   # the nuget.org account name
  - name: Push
    env:
      NUGET_API_KEY: ${{ steps.login.outputs.NUGET_API_KEY }}
    run: dotnet nuget push "artifacts/*.nupkg" --api-key "$NUGET_API_KEY" -s https://api.nuget.org/v3/index.json --skip-duplicate
```

## One-time setup

On nuget.org, add a Trusted Publishing policy for the package owner, scoped to this exact
repository and workflow file (`package-release.yml`). Renaming the workflow file breaks
publishing until the policy is updated.

## Releasing

1. Run `/release` (from the plugin) to open a release PR with the version bump and the changelog.
2. Merge it.
3. Tag the merge commit and push the tag:

   ```sh
   git checkout main && git pull
   git tag v1.2.3 && git push origin v1.2.3
   ```

nuget.org takes a few minutes to index a new version. A downstream repo that needs it immediately
can restore from a local folder feed in the meantime.
