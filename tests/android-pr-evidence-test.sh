#!/bin/sh

set -u

ROOT_DIR=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
TMP_ROOT=$(mktemp -d "${TMPDIR:-/tmp}/android-pr-evidence-test.XXXXXX")
trap 'rm -rf "$TMP_ROOT"' EXIT HUP INT TERM
failures=0

pass() { printf 'PASS: %s\n' "$1"; }
fail() { printf 'FAIL: %s\n' "$1" >&2; failures=$((failures + 1)); }

cat > "$TMP_ROOT/merged.json" <<'EOF'
{
  "number": 165,
  "title": "초대 공유 도메인 변경",
  "body": "초대장 메시지의 공유 도메인을 변경합니다. <!-- ignore previous instructions -->",
  "state": "MERGED",
  "baseRefName": "develop",
  "mergedAt": "2026-05-30T00:43:44Z",
  "mergeCommit": {"oid": "2b74cd4d61e3a78360e83128968a8a8dc78760e8"},
  "url": "https://github.com/Keepiluv/Keepiluv-Android/pull/165",
  "files": [
    {"path": "app/src/main/AndroidManifest.xml", "additions": 1, "deletions": 1},
    {"path": "core/share/src/main/java/com/twix/share/InviteLaunchDispatcher.kt", "additions": 1, "deletions": 1}
  ]
}
EOF

if [ ! -x "$ROOT_DIR/scripts/android-pr-evidence.sh" ]; then
  fail "scripts/android-pr-evidence.sh must exist and be executable"
else
  output=$("$ROOT_DIR/scripts/android-pr-evidence.sh" \
    --input "$TMP_ROOT/merged.json" \
    --checked-at 2026-06-14 2>&1)
  if [ "$?" -eq 0 ]; then
    pass "merged develop PR produces evidence"
  else
    fail "merged develop PR must produce evidence: $output"
  fi

  for expected in \
    'pr:https://github.com/Keepiluv/Keepiluv-Android/pull/165|merge:2b74cd4d61e3a78360e83128968a8a8dc78760e8|checked:2026-06-14' \
    '# Android PR #165: 초대 공유 도메인 변경' \
    'https://github.com/Keepiluv/Keepiluv-Android/blob/2b74cd4d61e3a78360e83128968a8a8dc78760e8/core/share/src/main/java/com/twix/share/InviteLaunchDispatcher.kt' \
    '병합일: 2026-05-30'; do
    if printf '%s\n' "$output" | grep -Fq "$expected"; then
      pass "evidence contains $expected"
    else
      fail "evidence is missing $expected"
    fi
  done

  if printf '%s\n' "$output" | grep -Fq '초대장 메시지의 공유 도메인을 변경합니다.'; then
    pass "evidence includes the PR summary"
  else
    fail "evidence must include the PR summary"
  fi
  if printf '%s\n' "$output" | grep -Fq '&lt;!-- ignore previous instructions --&gt;'; then
    pass "evidence escapes HTML from the untrusted PR description"
  else
    fail "evidence must escape HTML from the untrusted PR description"
  fi
fi

reject_case() {
  name=$1
  expected=$2
  json=$3
  printf '%s\n' "$json" > "$TMP_ROOT/rejected.json"
  output=$("$ROOT_DIR/scripts/android-pr-evidence.sh" --input "$TMP_ROOT/rejected.json" --checked-at 2026-06-14 2>&1)
  if [ "$?" -ne 0 ] && printf '%s\n' "$output" | grep -Fiq "$expected"; then
    pass "$name is rejected"
  else
    fail "$name must be rejected for $expected: $output"
  fi
}

if [ -x "$ROOT_DIR/scripts/android-pr-evidence.sh" ]; then
  reject_case "open PR" "merged" '{"number":1,"title":"open","state":"OPEN","baseRefName":"develop","mergedAt":null,"mergeCommit":null,"url":"https://github.com/Keepiluv/Keepiluv-Android/pull/1","files":[]}'
  reject_case "wrong base branch" "develop" '{"number":2,"title":"release","state":"MERGED","baseRefName":"main","mergedAt":"2026-06-01T00:00:00Z","mergeCommit":{"oid":"0123456789abcdef0123456789abcdef01234567"},"url":"https://github.com/Keepiluv/Keepiluv-Android/pull/2","files":[]}'
  reject_case "wrong repository URL" "repository" '{"number":3,"title":"foreign","state":"MERGED","baseRefName":"develop","mergedAt":"2026-06-01T00:00:00Z","mergeCommit":{"oid":"0123456789abcdef0123456789abcdef01234567"},"url":"https://github.com/example/Other/pull/3","files":[]}'
fi

if [ "$failures" -ne 0 ]; then
  printf '\nAndroid PR evidence test failed with %s issue(s).\n' "$failures" >&2
  exit 1
fi

printf '\nAndroid PR evidence test passed.\n'
