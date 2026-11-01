# Engineering standards: Project Guide

This repo is the handbook (`STANDARDS.md`), the tool guides (`docs/tools/`), the starting files
for a repo (`template/`), two helper scripts (`scripts/`) and a Claude Code plugin (`plugin/`).
It follows its own [STANDARDS.md](STANDARDS.md).

## Rules for changing it

- **Standards come from practice.** Add a rule only once a repo has proven it works, and say in
  the PR which repo it comes from. Don't invent rules here first.
- **Keep the template and the guides in step.** A change to a template file updates the tool guide
  that describes it, and the reverse.
- **Pin actions by full SHA** in template workflows, matching the versions the estate's repos use.
- **The "Where each repo stands" table in `README.md`** is updated when a repo adopts something.
- Check before pushing:

  ```sh
  node template/scripts/check-doc-links.mjs
  claude plugin validate . && claude plugin validate plugin
  bash -n scripts/*.sh
  gitleaks dir . --redact
  ```

- Every change goes through a PR, gated by `self-check.yml`. Conventional Commits. No em dashes.
