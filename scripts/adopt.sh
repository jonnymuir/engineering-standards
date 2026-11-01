#!/usr/bin/env bash
# Copies the template into a repo, replacing the MyRepo placeholder, without overwriting files
# that already exist (existing repos keep their own versions and are told what was skipped).
#
#   scripts/adopt.sh <target-repo-path> <RepoName>
set -euo pipefail

target="${1:?usage: scripts/adopt.sh <target-repo-path> <RepoName>}"
name="${2:?usage: scripts/adopt.sh <target-repo-path> <RepoName>}"
target="$(cd "$target" && pwd)"
template="$(cd "$(dirname "$0")/../template" && pwd)"

cd "$template"
find . -type f | sort | while read -r file; do
  dest="$target/${file#./}"
  if [ -e "$dest" ]; then
    echo "skip   ${file#./} (already exists)"
    continue
  fi
  mkdir -p "$(dirname "$dest")"
  sed "s/MyRepo/$name/g" "$file" > "$dest"
  echo "added  ${file#./}"
done

echo
echo "Next: edit the placeholders in CLAUDE.md and SECURITY.md, then follow README.md, 'Adopting'."
