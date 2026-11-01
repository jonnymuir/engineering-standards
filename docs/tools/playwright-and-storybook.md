# Playwright and Storybook

## Playwright

Browser tests of user-visible behaviour. Used two ways:

- **Component level**, against Storybook stories: fast and deterministic, the default for UI work.
- **Live stack**, against the booted app: only for behaviour that emerges from the whole host
  (sign-in round trips, journeys spanning pages). Keep these few.

Rules from [STANDARDS.md](../../STANDARDS.md#3-testing-behavioural-contracts-not-implementation-mirrors):

- Semantic selectors only: `getByRole`, `getByLabel`, `getByText`, `aria-*`, `data-*` hooks
  (for example `data-prism-*`). Never CSS classes or web component tag names.
- Wait for a visible loaded indicator before reading values. No fixed sleeps.
- Error states: assert both the `[role="alert"]` summary and the field-level message.
- For open shadow DOM, target the semantic elements inside it, not the host's internals.

Keep separate configs for component and live-stack runs (`playwright.config.ts` and, for
example, `playwright.localhost-auth.config.ts`), so the fast suite never needs the stack.

```sh
npx playwright test --reporter=line
npx playwright test path/to/spec.ts -g "test name"
```

## Storybook

Every UI component has stories covering its states. Storybook doubles as the test harness:

- **Interaction tests** run through the Vitest addon (`npm run test-storybook`).
- **Accessibility** uses `@storybook/addon-a11y`, which runs axe-core against each story. Treat
  an axe violation as a failing test, not a warning.
