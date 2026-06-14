#!/bin/sh

set -u

ROOT_DIR=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
TMP_ROOT=$(mktemp -d "${TMPDIR:-/tmp}/wiki-validator-test.XXXXXX")
trap 'rm -rf "$TMP_ROOT"' EXIT HUP INT TERM
failures=0
TAB=$(printf '\t')

pass() { printf 'PASS: %s\n' "$1"; }
fail() { printf 'FAIL: %s\n' "$1" >&2; failures=$((failures + 1)); }

seed="$TMP_ROOT/seed"
git clone -q "$ROOT_DIR" "$seed"
git -C "$seed" rm -qr --ignore-unmatch .
(cd "$ROOT_DIR" && tar --exclude=.git --exclude=.idea --exclude=wiki/.obsidian -cf - .) | (cd "$seed" && tar -xf -)
git -C "$seed" add -A
git -C "$seed" -c user.name=Tester -c user.email=tester@example.com commit -qm 'validator fixture'
git -C "$seed" remote set-url origin https://github.com/chanho0908/Keepiluv-Agent.git

run_case() {
  name=$1
  expected=$2
  repo="$TMP_ROOT/$name"
  git clone -q "$seed" "$repo"
  git -C "$repo" remote set-url origin https://github.com/chanho0908/Keepiluv-Agent.git
  shift 2
  "$@" "$repo"
  output=$("$repo/scripts/validate-wiki.sh" 2>&1)
  if [ "$?" -ne 0 ] && printf '%s\n' "$output" | grep -Fiq "$expected"; then
    pass "$name is rejected for $expected"
  else
    fail "$name must be rejected for $expected: $output"
  fi
}

mutate_legacy() { printf '%s\n' 'legacy .codex/docs/architecture.md' > "$1/untracked-note.md"; }
mutate_deleted() { rm "$1/wiki/reference/project-overview.md"; }
mutate_header() { printf 'wrong\theader\n' > "$1/wiki/state/source-manifest.tsv"; }
mutate_hash() { printf 'path\tsha256\nAGENTS.md\tabc\n' > "$1/wiki/state/source-manifest.tsv"; }
mutate_absolute() { printf 'path\tsha256\n/tmp/AGENTS.md\t%064d\n' 0 > "$1/wiki/state/source-manifest.tsv"; }
mutate_traversal() { printf 'path\tsha256\n../AGENTS.md\t%064d\n' 0 > "$1/wiki/state/source-manifest.tsv"; }
mutate_empty() { printf 'path\tsha256\n\t%064d\n' 0 > "$1/wiki/state/source-manifest.tsv"; }
mutate_duplicate() { printf 'path\tsha256\nAGENTS.md\t%064d\nAGENTS.md\t%064d\n' 0 1 > "$1/wiki/state/source-manifest.tsv"; }
mutate_unsorted() { printf 'path\tsha256\nwiki/reference/project-overview.md\t%064d\nAGENTS.md\t%064d\n' 0 1 > "$1/wiki/state/source-manifest.tsv"; }
mutate_invalid_pr_source() {
  sed 's#repo:chanho0908/Keepiluv-Agent@[0-9a-f]*:AGENTS.md#pr:https://github.com/Keepiluv/Keepiluv-Android/pull/165|merge:short|checked:2026-06-14#' \
    "$1/wiki/schema/page-template.md" > "$1/wiki/schema/page-template.md.tmp"
  mv "$1/wiki/schema/page-template.md.tmp" "$1/wiki/schema/page-template.md"
}

baseline_output=$("$seed/scripts/validate-wiki.sh" 2>&1)
if [ "$?" -eq 0 ]; then
  pass "validator passes in a fully tracked clean checkout"
else
  fail "validator must pass in a fully tracked clean checkout: $baseline_output"
fi

run_case untracked-legacy legacy mutate_legacy
run_case required-canonical canonical mutate_deleted
run_case wrong-header header mutate_header
run_case malformed-hash sha256 mutate_hash
run_case absolute-path repository-relative mutate_absolute
run_case traversal-path repository-relative mutate_traversal
run_case empty-path empty mutate_empty
run_case duplicate-path duplicate mutate_duplicate
run_case unsorted-path sorted mutate_unsorted
run_case invalid-pr-source "source must use" mutate_invalid_pr_source

valid_pr_repo="$TMP_ROOT/valid-pr-source"
git clone -q "$seed" "$valid_pr_repo"
git -C "$valid_pr_repo" remote set-url origin https://github.com/chanho0908/Keepiluv-Agent.git
sed 's#repo:chanho0908/Keepiluv-Agent@[0-9a-f]*:AGENTS.md#pr:https://github.com/Keepiluv/Keepiluv-Android/pull/165|merge:2b74cd4d61e3a78360e83128968a8a8dc78760e8|checked:2026-06-14#' \
  "$valid_pr_repo/wiki/schema/page-template.md" > "$valid_pr_repo/wiki/schema/page-template.md.tmp"
mv "$valid_pr_repo/wiki/schema/page-template.md.tmp" "$valid_pr_repo/wiki/schema/page-template.md"
valid_pr_output=$("$valid_pr_repo/scripts/validate-wiki.sh" 2>&1)
if [ "$?" -eq 0 ]; then
  pass "merged PR source format is accepted"
else
  fail "merged PR source format must be accepted: $valid_pr_output"
fi

if [ "$failures" -ne 0 ]; then
  printf '\nWiki validator test failed with %s issue(s).\n' "$failures" >&2
  exit 1
fi

printf '\nWiki validator test passed.\n'
