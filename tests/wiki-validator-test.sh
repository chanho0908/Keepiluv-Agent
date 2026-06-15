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
mutate_header() { printf 'wrong\theader\n' > "$1/wiki/state/wiki-verification-baseline.tsv"; }
mutate_hash() { printf 'path\tsha256\nAGENTS.md\tabc\n' > "$1/wiki/state/wiki-verification-baseline.tsv"; }
mutate_absolute() { printf 'path\tsha256\n/tmp/AGENTS.md\t%064d\n' 0 > "$1/wiki/state/wiki-verification-baseline.tsv"; }
mutate_traversal() { printf 'path\tsha256\n../AGENTS.md\t%064d\n' 0 > "$1/wiki/state/wiki-verification-baseline.tsv"; }
mutate_empty() { printf 'path\tsha256\n\t%064d\n' 0 > "$1/wiki/state/wiki-verification-baseline.tsv"; }
mutate_duplicate() { printf 'path\tsha256\nAGENTS.md\t%064d\nAGENTS.md\t%064d\n' 0 1 > "$1/wiki/state/wiki-verification-baseline.tsv"; }
mutate_unsorted() { printf 'path\tsha256\nwiki/reference/project-overview.md\t%064d\nAGENTS.md\t%064d\n' 0 1 > "$1/wiki/state/wiki-verification-baseline.tsv"; }
mutate_empty_sources() {
  ruby -0pi -e 'sub("status: active\n", "status: active\nsources: []\n")' "$1/wiki/index.md"
}
mutate_reference_authority() {
  ruby -0pi -e 'sub("authority: canonical", "authority: synthesized")' "$1/wiki/reference/project-overview.md"
}
mutate_operation_authority() {
  ruby -0pi -e 'sub("authority: canonical", "authority: synthesized")' "$1/wiki/operations/routing-rules.md"
}
mutate_schema_authority() {
  ruby -0pi -e 'sub("authority: canonical", "authority: synthesized")' "$1/wiki/schema/lint.md"
}
mutate_synthesized_source_authority() {
  ruby -0pi -e 'sub("authority: canonical", "authority: synthesized")' "$1/wiki/schema/maintenance.md"
}
mutate_unlinked_reference() {
  cp "$1/wiki/reference/project-overview.md" "$1/wiki/reference/unlinked-reference.md"
}
mutate_unlinked_operation() {
  cp "$1/wiki/operations/routing-rules.md" "$1/wiki/operations/unlinked-operation.md"
}
mutate_unlinked_schema() {
  cp "$1/wiki/schema/lint.md" "$1/wiki/schema/unlinked-schema.md"
}
write_candidate() {
  repo=$1
  use_count=${2:-1}
  cat > "$repo/wiki/inbox/candidate.md" <<EOF
---
type: knowledge-candidate
status: candidate
created_at: 2026-06-15
updated_at: 2026-06-15
last_verified: 2026-06-15
use_count: $use_count
last_used_at: 2026-06-15
used_in:
  - task: archive-refresh-error-handling
    used_at: 2026-06-15
    context: implementation
    evidence: existing content retention decision
tags:
  - inbox
  - knowledge-candidate
authority: none
---

# Candidate
EOF
}
mutate_candidate_count() { write_candidate "$1" 2; }
mutate_candidate_duplicate_task() {
  write_candidate "$1" 2
  ruby -0pi -e 'sub("    evidence: existing content retention decision\n", "    evidence: existing content retention decision\n  - task: archive-refresh-error-handling\n    used_at: 2026-06-15\n    context: test\n    evidence: regression test decision\n")' "$1/wiki/inbox/candidate.md"
}
mutate_candidate_bad_context() {
  write_candidate "$1"
  ruby -0pi -e 'sub("context: implementation", "context: search")' "$1/wiki/inbox/candidate.md"
}
mutate_promoted_without_target() {
  write_candidate "$1"
  ruby -0pi -e 'sub("status: candidate", "status: promoted\nresolution_reason: repeated use")' "$1/wiki/inbox/candidate.md"
}

baseline_output=$("$seed/scripts/validate-wiki.sh" 2>&1)
if [ "$?" -eq 0 ]; then
  pass "validator passes in a fully tracked clean checkout"
else
  fail "validator must pass in a fully tracked clean checkout: $baseline_output"
fi

valid_candidate_repo="$TMP_ROOT/valid-candidate"
git clone -q "$seed" "$valid_candidate_repo"
write_candidate "$valid_candidate_repo"
valid_candidate_output=$("$valid_candidate_repo/scripts/validate-wiki.sh" 2>&1)
if [ "$?" -eq 0 ]; then
  pass "validator accepts a valid knowledge candidate"
else
  fail "validator must accept a valid knowledge candidate: $valid_candidate_output"
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
run_case empty-sources sources mutate_empty_sources
run_case reference-authority 'must declare authority: canonical' mutate_reference_authority
run_case operation-authority 'must declare authority: canonical' mutate_operation_authority
run_case schema-authority 'must declare authority: canonical' mutate_schema_authority
run_case synthesized-source-authority 'source_path must reference authority: canonical Markdown' mutate_synthesized_source_authority
run_case unlinked-reference 'orphan candidate' mutate_unlinked_reference
run_case unlinked-operation 'orphan candidate' mutate_unlinked_operation
run_case unlinked-schema 'orphan candidate' mutate_unlinked_schema
run_case candidate-count 'use_count must equal used_in item count' mutate_candidate_count
run_case candidate-duplicate-task 'used_in tasks must identify independent unique work' mutate_candidate_duplicate_task
run_case candidate-bad-context 'context must be plan, implementation, test, or review' mutate_candidate_bad_context
run_case promoted-without-target 'promoted candidate must have repository-relative target_path' mutate_promoted_without_target
if [ "$failures" -ne 0 ]; then
  printf '\nWiki validator test failed with %s issue(s).\n' "$failures" >&2
  exit 1
fi

printf '\nWiki validator test passed.\n'
