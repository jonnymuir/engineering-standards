# Doc link checker

`scripts/check-doc-links.mjs` walks every Markdown file in the repo and fails on a relative link to
a file that doesn't exist, or to a heading anchor that doesn't exist in the target file. External
`http(s)` links are not checked.

```sh
node scripts/check-doc-links.mjs
```

It runs as a step in the CI workflow, so a broken link fails the `all` gate. The template carries
the current copy of the script.

Heading anchors follow GitHub's rules: lower case, spaces become hyphens, punctuation is dropped.
Renaming a heading breaks every link to it, and the checker says where.
