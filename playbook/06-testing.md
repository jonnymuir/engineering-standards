# 6. Testing: behavioural contracts, not implementation mirrors

## In short

- A test states a behaviour, observed from outside: a public method, an HTTP response, rendered
  HTML, the visible UI.
- A behaviour-preserving refactor must not turn a test red. If it does, the test was a mirror.
- Prefer real in-memory implementations to mocks. Never mock the database.
- Use the coarsest test that is still fast and deterministic.
- Before changing a dependency or rewriting code, pin today's behaviour with tests that pass on the
  old version, then make them pass on the new one.
- Compare old and new outputs directly, and prove the comparison can fail.
- Turn rare timing bugs into deterministic ones with fault injection, so the test fails every time
  without the fix.
- A test you have never seen fail proves nothing. A test that can pass without the fix gives false
  confidence: remove it or make it bite.
- A re-run is not a fix. Measure the failure rate, find the cause, change the system.

## Tests are the specification

The most useful thing a test can do is say, in code that runs, what the product must do. That is
knowledge in the world: a reader (or an agent) can learn the behaviour from the test, and a change
that breaks the behaviour is caught by it.

A test that mirrors the implementation does the opposite. It asserts that method A calls method B
with these arguments, or that a private field holds a value. It restates the code, so it can only
ever agree with it. Refactor the code and the test breaks even though nothing a user sees has
changed; break the behaviour in a way the mirror didn't anticipate and it still passes.

| Mirror (avoid) | Contract (prefer) |
|---|---|
| "`Save` calls `repository.Insert` once" | "After saving, the item can be read back with the same values" |
| "The validator sets `_errors[0]`" | "Submitting without a date shows 'Enter a date' in the summary and next to the field" |
| "The controller calls `IAuthService.Check`" | "An anonymous request to this endpoint gets 401" |
| "The parser uses `CsvReader.ReadHeader`" | "A file with a byte order mark and Windows line endings is read normally" |

The test on the right survives any rewrite that keeps the behaviour and fails on any change that
breaks it, which is exactly the job.

## Where to observe from

Pick the seam the behaviour is visible at:

- A public method of a domain or engine type, with real in-memory collaborators.
- An HTTP response from a test host running the real pipeline (routing, auth, middleware).
- Rendered output: an HTML fragment, a generated file's exact bytes.
- The visible UI: Playwright against a Storybook story, or against the booted app when the
  behaviour only emerges there.

Needing `InternalsVisibleTo` is a sign the test is at the wrong level. Look for the public seam that
shows the behaviour.

## Real implementations over mocks

A mocking framework makes it easy to write mirrors, because a mock is a list of expected calls.
Prefer real, in-memory implementations of your own abstractions (an in-memory store, an in-memory
file storage, a fake clock) that behave like the real thing. Mock only a contract you own, at the
edge, when there is no reasonable in-memory version.

Never mock the database. Data access bugs (a column type, a transaction, a lock) are exactly what
an integration test against a real engine catches and a mock hides. The estate runs its booted-host
suites against SQLite, and against SQL Server in CI, because a column SQLite accepts can still
truncate on SQL Server.

## The coarsest fast test

Prefer the test that covers the most real behaviour while staying fast and deterministic. A domain
test with real in-memory stores beats five unit tests with mocks. A rendering test of the real
component beats a test of its helper. Reserve full browser runs against a booted host for what only
emerges there (a sign-in round trip, a journey across pages), and keep those few, because they are
slow and have more ways to flake.

## Pin behaviour before you change it

The safest way to change a dependency, or rewrite code, is to first capture what it does today:

1. Write tests that state the current behaviour at the public seam, including the awkward cases.
2. Run them against the old version. They must pass, or they aren't describing reality.
3. Make the change.
4. Run them against the new version. Every difference is now visible and deliberate.

When the estate moved to a major new version of a CSV library (a full rewrite with different
defaults), this caught five behaviours that would otherwise have changed silently: the separator
being guessed instead of fixed, header names matching case-insensitively, the first data row being
taken as the header, short rows reading as empty instead of absent, and padded values no longer
being quoted on output. Each was set back explicitly, with a test naming it. The tests covered byte
order marks, Windows line endings, quotes and line breaks inside values, semicolon files, repeated
headers and the exact bytes of exported files, and they passed on both versions.

## Differential testing, and proving it can fail

For a change that should not alter output at all, compare outputs directly: run a set of awkward
inputs through the old build and the new build, and diff the results byte for byte.

Then do the step most people skip: **break the new build on purpose and check the comparison
notices.** In the CSV migration, removing the two compatibility settings made the differential
report differences on exactly the files that should differ. Without that, an "identical" result
could just mean the comparison wasn't comparing.

## Making rare bugs deterministic

An intermittent failure is a test that hasn't been written yet. Once you know the cause, write a
test that forces it every time, then fix the code.

The estate's example is a database race. On SQLite, some framework operations read and then write
inside a deferred transaction; if another connection commits in the gap, the write can never
succeed and the request stalls for minutes. It happened about once in twenty boots, only under load.
The test hook is an interceptor in the test host that, just before the vulnerable statement runs,
commits a write from another connection, exactly in the gap:

- Without the fix, every boot stalls.
- With the fix (take the write lock before the first read), every boot passes in about ten seconds.

The rare timing became a certain failure, so the fix is proven and can't silently regress. The same
idea works for any race: inject the other party's action at the worst possible moment, on purpose.

Two cautions from that work:

- Inject narrowly. A first version of the hook committed on behalf of every lock statement
  across the whole process, which planted commits into unrelated transactions' gaps and made
  unrelated code fail. Target the one gap you are testing.
- If the injection can't reliably hit the gap, drop it. A second gap only opened when a cache
  happened to be cold. A hook for it passed with and without the fix, so it proved nothing and was
  removed. That fix rests on the trace evidence and a soak run instead, and the PR says so.

## A test that cannot fail proves nothing

Before trusting a test, see it fail:

- Write it before the fix and watch it go red, or revert the fix and check it goes red.
- For a check or a comparison, break the thing it guards on purpose.
- For a guardrail, feed it a known violation.

A test that passes with and without the change is not neutral; it is misleading, because it adds
confidence that isn't earned. Remove it, or change it until it bites.

## Flaky tests: a re-run is not a fix

A test that fails sometimes is telling you the system has a failure rate. Re-running until it
passes is tampering in Deming's sense (see [Quality](02-quality.md#understand-variation-dont-tamper)):
it hides the rate without changing it.

Treat a flaky test as an incident:

1. Measure the rate with a soak: run the suite repeatedly under realistic load (in the estate,
   several test projects booting at once, as CI does) and count. "One in fourteen" is information;
   "it failed once" isn't.
2. Capture evidence while it is failing: stack dumps, logs, traces. See
   [Diagnosing the hard ones](07-diagnosis.md).
3. Fix the cause, make it deterministic in a test if you can, and soak again to compare
   rates.
4. Be honest about what is left. If part of the cause is in someone else's code, say so, with
   the rate, rather than calling it fixed.

Don't merge a "fix" for a flaky test on the strength of one green run.

## UI tests

Rules for browser tests, from [STANDARDS.md](../STANDARDS.md#3-testing-behavioural-contracts-not-implementation-mirrors):

- Semantic selectors only: `getByRole`, `getByLabel`, `getByText`, `aria-*`, `data-*` hooks.
  Never CSS classes or component tag names. Semantic selectors double as an accessibility check:
  if a test can't find a control by its role and name, neither can a screen reader.
- Wait for a state, never a duration. No fixed sleeps. Start waiting for navigation before the
  click that triggers it, or the wait can resolve against the old page.
- Assert error states twice: the `[role="alert"]` summary and the field-level message.
- Prefer specific targets. A generic `button[name="Action"]` can match a "Change" link before
  the real submit button and quietly send a journey backwards.
- Accessibility is a test, not a report: an axe violation on a story fails the suite.

## Business rules and calculations

Keep business maths in one declared place (in the estate, a blueprint's `calculations` block),
verified by a shared conformance suite that every implementation runs, rather than re-implemented
and re-tested in each host and client. One source of truth for the rule means one set of tests for
it.
