# OWASP ZAP baseline (DAST)

Dynamic analysis of the running app. It boots the app on the runner, spiders it, and runs ZAP's
passive rules only: no attacks, nothing destructive. It finds what static analysis cannot see:
missing or mis-set security headers (CSP, HSTS, `X-Content-Type-Options`), cookie flags
(`Secure`, `HttpOnly`, `SameSite`), cache-control on sensitive pages, information disclosure and
the `Server` header.

## How it is wired

`dast-baseline.yml` in [`ci-security`](https://github.com/jonnymuir/ci-security), called from
the repo's `.github/workflows/dast.yml` (see [the template](../../template/.github/workflows/dast.yml)):

- `boot-command` starts the app, `target-url` and `health-path` say where and when it is ready.
- `rules-file-path` (default `.zap/rules.tsv`) holds triaged findings.
- `fail-action` starts `false` (advisory) and becomes `true` once the rules file is triaged. Then
  `baseline / DAST baseline` joins the ruleset's required checks.
- An optional **authenticated leg** calls the same workflow a second time with `login-command`,
  which signs in and writes the session cookie for ZAP to replay. Pages behind sign-in are then
  scanned too.

## Triaging findings

The report is uploaded as an artifact and written to the job summary. For each finding, either
fix it (usually a header or cookie setting) or record it in `.zap/rules.tsv`, tab-separated:

```text
10049	IGNORE	https?://127\.0\.0\.1:8080/umbraco/.*	Backoffice assets are cache-controlled by Umbraco
```

Actions are `IGNORE` (accepted), `WARN` (reported, not failing) and `FAIL`. Every `IGNORE` carries
a note saying why.

## Running it locally

With the app running on port 8080:

```sh
docker run --rm --network=host -v "$PWD:/zap/wrk" ghcr.io/zaproxy/zaproxy:stable \
  zap-baseline.py -t http://127.0.0.1:8080 -c .zap/rules.tsv -r zap-report.html
```
