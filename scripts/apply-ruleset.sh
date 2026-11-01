#!/usr/bin/env bash
# Creates or replaces the "Main branch rules" ruleset on a repo, requiring the named checks.
#
#   scripts/apply-ruleset.sh OWNER/REPO "security / security-all" all zizmor CodeQL
#
# Only name checks that already report on pull requests: a required check that never runs blocks
# every merge.
set -euo pipefail

repo="${1:?usage: scripts/apply-ruleset.sh OWNER/REPO <check>...}"
shift
[ "$#" -gt 0 ] || { echo "Name at least one required check." >&2; exit 1; }

base="$(dirname "$0")/ruleset.base.json"
checks="$(printf '%s\n' "$@" | jq -R '{context: .}' | jq -s .)"
body="$(jq --argjson checks "$checks" \
  '(.rules[] | select(.type == "required_status_checks") | .parameters.required_status_checks) = $checks' "$base")"

existing="$(gh api "repos/$repo/rulesets" --jq '.[] | select(.name == "Main branch rules") | .id')"
if [ -n "$existing" ]; then
  echo "$body" | gh api -X PUT "repos/$repo/rulesets/$existing" --input - --jq '"Updated ruleset \(.id) on '"$repo"'"'
else
  echo "$body" | gh api -X POST "repos/$repo/rulesets" --input - --jq '"Created ruleset \(.id) on '"$repo"'"'
fi
