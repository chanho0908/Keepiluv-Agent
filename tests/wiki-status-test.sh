#!/bin/sh

set -u

SOURCE_ROOT=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
failures=0
TAB=$(printf '\t')
TMP_ROOT=$(mktemp -d "${TMPDIR:-/tmp}/wiki-status-test.XXXXXX")
trap 'rm -rf "$TMP_ROOT"' EXIT HUP INT TERM

pass() {
  printf 'PASS: %s\n' "$1"
}

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  failures=$((failures + 1))
}

assert_contains() {
  output=$1
  expected=$2
  label=$3
  if printf '%s\n' "$output" | grep -Fqx "$expected"; then
    pass "$label"
  else
    fail "$label (missing: $expected)"
  fi
}

assert_file_unchanged() {
  before=$1
  file=$2
  label=$3
  after=$(sha256_file "$file")
  if [ "$before" = "$after" ]; then
    pass "$label"
  else
    fail "$label"
  fi
}

assert_failure_preserves_manifest() {
  label=$1
  expected_error=$2
  shift 2
  before=$(sha256_file "$REPO/wiki/state/source-manifest.tsv")
  output=$("$@" 2>&1)
  if [ "$?" -eq 0 ]; then
    fail "$label must fail"
  elif printf '%s\n' "$output" | grep -Fiq "$expected_error"; then
    pass "$label fails for the expected reason"
  else
    fail "$label failed for the wrong reason: $output"
  fi
  assert_file_unchanged "$before" "$REPO/wiki/state/source-manifest.tsv" "$label leaves manifest unchanged"
}

sha256_file() {
  ruby -rdigest -e 'print Digest::SHA256.file(ARGV[0]).hexdigest' "$1"
}

if [ ! -x "$SOURCE_ROOT/scripts/wiki-status.sh" ] || [ ! -f "$SOURCE_ROOT/scripts/wiki_status.rb" ]; then
  fail "scripts/wiki-status.sh and scripts/wiki_status.rb must exist"
  printf '\nWiki status test failed with %s issue(s).\n' "$failures" >&2
  exit 1
fi

REPO="$TMP_ROOT/repo"
mkdir -p \
  "$REPO/scripts" \
  "$REPO/wiki/reference" \
  "$REPO/wiki/operations" \
  "$REPO/wiki/schema" \
  "$REPO/wiki/state" \
  "$REPO/wiki/topics"
cp "$SOURCE_ROOT/scripts/wiki-status.sh" "$REPO/scripts/wiki-status.sh"
cp "$SOURCE_ROOT/scripts/wiki_status.rb" "$REPO/scripts/wiki_status.rb"
chmod +x "$REPO/scripts/wiki-status.sh"
cat > "$REPO/scripts/validate-wiki.sh" <<'EOF'
#!/bin/sh
exit "${WIKI_TEST_VALIDATOR_EXIT:-0}"
EOF
chmod +x "$REPO/scripts/validate-wiki.sh"

printf '%s\n' '# Agents' > "$REPO/AGENTS.md"
for file in \
  project-overview.md architecture.md module-hierarchy.md domain-glossary.md test-strategy.md; do
  printf '# %s\n' "$file" > "$REPO/wiki/reference/$file"
done
for file in routing-rules.md workflows.md agent-list.md; do
  printf '# %s\n' "$file" > "$REPO/wiki/operations/$file"
done
printf '%s\n' '# Schema' > "$REPO/wiki/schema/workflow.md"
printf '%s\n' '# ignored log' > "$REPO/wiki/log.md"
cat > "$REPO/wiki/topics/architecture-summary.md" <<'EOF'
---
authority: synthesized
source_paths:
  - wiki/reference/architecture.md
---
# Architecture summary
EOF

git -C "$REPO" init -q
git -C "$REPO" config user.email tester@example.com
git -C "$REPO" config user.name Tester
git -C "$REPO" add .
git -C "$REPO" commit -qm initial

initial_output=$("$REPO/scripts/wiki-status.sh" 2>&1)
initial_status=$?
if [ "$initial_status" -eq 0 ]; then
  pass "initial status inspection succeeds"
else
  fail "initial status inspection must succeed: $initial_output"
fi
assert_contains "$initial_output" "NEW${TAB}AGENTS.md" "initial inspection reports AGENTS.md as NEW"
assert_contains "$initial_output" "NEW${TAB}wiki/reference/architecture.md" "initial inspection reports canonical reference as NEW"
if [ ! -e "$REPO/wiki/state/source-manifest.tsv" ]; then
  pass "read-only inspection does not create manifest"
else
  fail "read-only inspection must not create manifest"
fi
if printf '%s\n' "$initial_output" | grep -Fq 'wiki/log.md' || printf '%s\n' "$initial_output" | grep -Fq 'wiki/state/source-manifest.tsv'; then
  fail "status inspection must exclude log and manifest"
else
  pass "status inspection excludes log and manifest"
fi

if "$REPO/scripts/wiki-status.sh" --accept >/dev/null 2>&1; then
  fail "--accept without explicit approval must be rejected"
else
  pass "--accept without explicit approval is rejected"
fi
if [ ! -e "$REPO/wiki/state/source-manifest.tsv" ]; then
  pass "rejected acceptance does not create manifest"
else
  fail "rejected acceptance must not create manifest"
fi

accept_output=$("$REPO/scripts/wiki-status.sh" --accept --approved 2>&1)
accept_status=$?
if [ "$accept_status" -eq 0 ] && [ -f "$REPO/wiki/state/source-manifest.tsv" ]; then
  pass "--accept creates the manifest"
else
  fail "--accept --approved must create the manifest: $accept_output"
fi

if [ -f "$REPO/wiki/state/source-manifest.tsv" ]; then
  if awk -F '\t' 'NR == 1 { ok = ($1 == "path" && $2 == "sha256"); next } NF != 2 || length($2) != 64 || $2 !~ /^[0-9a-f]+$/ { ok = 0 } END { exit(ok ? 0 : 1) }' "$REPO/wiki/state/source-manifest.tsv"; then
    pass "manifest uses path and sha256 columns"
  else
    fail "manifest must contain a path and 64-character sha256 per row"
  fi
  if tail -n +2 "$REPO/wiki/state/source-manifest.tsv" | cut -f1 | LC_ALL=C sort -c; then
    pass "manifest paths are deterministically sorted"
  else
    fail "manifest paths must be sorted"
  fi
fi

manifest_before=$(sha256_file "$REPO/wiki/state/source-manifest.tsv")
clean_output=$("$REPO/scripts/wiki-status.sh" 2>&1)
clean_status=$?
if [ "$clean_status" -eq 0 ] && [ -z "$clean_output" ]; then
  pass "unchanged repository produces no status records"
else
  fail "unchanged repository must produce no status records: $clean_output"
fi
assert_file_unchanged "$manifest_before" "$REPO/wiki/state/source-manifest.tsv" "read-only clean inspection leaves manifest unchanged"

printf '%s\n' '# Architecture changed' > "$REPO/wiki/reference/architecture.md"
printf '%s\n' '# New reference' > "$REPO/wiki/reference/new-reference.md"
rm "$REPO/wiki/operations/routing-rules.md"
printf '%s\n' '# log changed but ignored' > "$REPO/wiki/log.md"
printf '%s\n' '# manifest sibling ignored' > "$REPO/wiki/state/notes.md"

changed_output=$("$REPO/scripts/wiki-status.sh" 2>&1)
changed_status=$?
if [ "$changed_status" -eq 0 ]; then
  pass "changed status inspection succeeds"
else
  fail "changed status inspection must succeed: $changed_output"
fi
assert_contains "$changed_output" "CHANGED${TAB}wiki/reference/architecture.md" "changed canonical document is detected"
assert_contains "$changed_output" "NEW${TAB}wiki/reference/new-reference.md" "new canonical document is detected"
assert_contains "$changed_output" "DELETED${TAB}wiki/operations/routing-rules.md" "deleted canonical document is detected"
assert_contains "$changed_output" "IMPACT${TAB}wiki/reference/architecture.md${TAB}wiki/topics/architecture-summary.md" "changed source reports affected synthesized topic"
if printf '%s\n' "$changed_output" | grep -Eq 'wiki/(log\.md|state/)'; then
  fail "log and state files must stay excluded after changes"
else
  pass "log and state files remain excluded after changes"
fi
assert_file_unchanged "$manifest_before" "$REPO/wiki/state/source-manifest.tsv" "changed inspection remains read-only"

printf '%s\n' '# Routing restored' > "$REPO/wiki/operations/routing-rules.md"
assert_failure_preserves_manifest "acceptance when validator fails" \
  "validat" \
  env WIKI_TEST_VALIDATOR_EXIT=1 "$REPO/scripts/wiki-status.sh" --accept --approved

mv "$REPO/wiki/reference/project-overview.md" "$REPO/wiki/reference/project-overview.md.deleted"
assert_failure_preserves_manifest "acceptance with a required canonical document deleted" \
  "canonical" \
  "$REPO/scripts/wiki-status.sh" --accept --approved
mv "$REPO/wiki/reference/project-overview.md.deleted" "$REPO/wiki/reference/project-overview.md"

if "$REPO/scripts/wiki-status.sh" --accept --approved >/dev/null 2>&1; then
  accepted_manifest=$(sha256_file "$REPO/wiki/state/source-manifest.tsv")
  if "$REPO/scripts/wiki-status.sh" --accept --approved >/dev/null 2>&1; then
    assert_file_unchanged "$accepted_manifest" "$REPO/wiki/state/source-manifest.tsv" "repeated approved acceptance is idempotent"
  else
    fail "second approved acceptance must succeed"
  fi
else
  fail "first approved acceptance must succeed before idempotency is checked"
fi

valid_manifest=$(cat "$REPO/wiki/state/source-manifest.tsv")
check_malformed_manifest() {
  label=$1
  content=$2
  printf '%b' "$content" > "$REPO/wiki/state/source-manifest.tsv"
  if "$REPO/scripts/wiki-status.sh" >/dev/null 2>&1; then
    fail "$label malformed manifest must fail"
  else
    pass "$label malformed manifest fails"
  fi
}

check_malformed_manifest "wrong header" "wrong${TAB}header\n"
check_malformed_manifest "malformed hash" "path${TAB}sha256\nAGENTS.md${TAB}abc\n"
check_malformed_manifest "absolute path" "path${TAB}sha256\n/tmp/AGENTS.md${TAB}$(printf '%064d' 0)\n"
check_malformed_manifest "traversal path" "path${TAB}sha256\n../AGENTS.md${TAB}$(printf '%064d' 0)\n"
check_malformed_manifest "empty path" "path${TAB}sha256\n${TAB}$(printf '%064d' 0)\n"
check_malformed_manifest "duplicate path" "path${TAB}sha256\nAGENTS.md${TAB}$(printf '%064d' 0)\nAGENTS.md${TAB}$(printf '%064d' 1)\n"
check_malformed_manifest "unsorted paths" "path${TAB}sha256\nwiki/reference/project-overview.md${TAB}$(printf '%064d' 0)\nAGENTS.md${TAB}$(printf '%064d' 1)\n"
printf '%s\n' "$valid_manifest" > "$REPO/wiki/state/source-manifest.tsv"

printf '%s\n' '# dirty but outside tracked source set' > "$REPO/unrelated-local-note.txt"
before_dirty_accept=$(sha256_file "$REPO/wiki/state/source-manifest.tsv")
if "$REPO/scripts/wiki-status.sh" --accept --approved >/dev/null 2>&1; then
  pass "approved acceptance allows dirty files outside the tracked source set"
else
  fail "approved acceptance should allow unrelated dirty files when validation passes"
fi
assert_file_unchanged "$before_dirty_accept" "$REPO/wiki/state/source-manifest.tsv" "unrelated dirty file does not affect manifest"

if [ "$failures" -ne 0 ]; then
  printf '\nWiki status test failed with %s issue(s).\n' "$failures" >&2
  exit 1
fi

printf '\nWiki status test passed.\n'
