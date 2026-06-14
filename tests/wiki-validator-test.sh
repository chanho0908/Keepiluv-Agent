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
if [ "$failures" -ne 0 ]; then
  printf '\nWiki validator test failed with %s issue(s).\n' "$failures" >&2
  exit 1
fi

printf '\nWiki validator test passed.\n'
