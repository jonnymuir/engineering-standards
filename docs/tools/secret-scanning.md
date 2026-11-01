# Secret scanning

[gitleaks](https://github.com/gitleaks/gitleaks) scans every file in the checked-out tree for
credentials: API keys, tokens, private keys, connection strings with passwords, and generic
high-entropy values next to words like `secret` or `key`. It catches, for example, the
`Imaging:HMACSecretKey` that Umbraco writes into `appsettings.json` on first boot.

## How it is wired

The `secret-scan` job in `dotnet-security.yml` from
[`ci-security`](https://github.com/jonnymuir/ci-security) installs a pinned, checksum-verified
gitleaks and runs `gitleaks dir .`. A finding fails the job, and through it the required
`security / security-all` check.

It scans the tree, not the history. A PR is squash-merged, so its intermediate commits never reach
`main`; the tree is what lands.

## When it reports a finding

1. **A real secret:** remove it from the file, move it to user-secrets, a vault or the server's
   environment file, and **rotate it**. It is already in the PR branch's history on GitHub.
2. **A test fixture or example that only looks like a secret:** mark that line with a comment:

   ```csharp
   private const string FakeSigningKey = "s3cr3t-signing-key"; // gitleaks:allow test fixture
   ```

3. **A generated or minified file** (a bundled script, for example): allowlist the path in
   `.gitleaks.toml` at the repo root, keeping the default rules:

   ```toml
   [extend]
   useDefault = true

   [[allowlists]]
   description = "Minified third-party bundle"
   paths = ['''wwwroot/location-picker/.*\.js''']
   ```

Never allowlist a whole test folder: a real secret pasted into a test is still a leak.

## Running it locally

```sh
brew install gitleaks
gitleaks dir . --redact
```

Run it after starting an app for the first time, before staging: first-run tools write generated
keys into tracked config files.
