#!/bin/sh

set -u

ROOT_DIR=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
WORKFLOW="$ROOT_DIR/.github/workflows/android-pr-wiki-maintenance.yml"
PROMPT="$ROOT_DIR/.github/codex/prompts/maintain-wiki-from-android-pr.md"
failures=0

pass() { printf 'PASS: %s\n' "$1"; }
fail() { printf 'FAIL: %s\n' "$1" >&2; failures=$((failures + 1)); }

require_text() {
  file=$1
  expected=$2
  label=$3
  if [ -f "$file" ] && grep -Fq "$expected" "$file"; then
    pass "$label"
  else
    fail "$label"
  fi
}

require_text "$WORKFLOW" 'workflow_dispatch:' "workflow supports manual runs"
require_text "$WORKFLOW" 'repository_dispatch:' "workflow supports source repository events"
require_text "$WORKFLOW" 'schedule:' "workflow scans for missed merged PRs"
require_text "$WORKFLOW" 'contents: read' "Codex job starts with read-only repository token"
require_text "$WORKFLOW" 'openai/codex-action@e0fdf01220eb9a88167c4898839d273e3f2609d1' "Codex action is pinned to a commit"
require_text "$WORKFLOW" 'openai-api-key: ${{ secrets.OPENAI_API_KEY }}' "OpenAI key is passed only to Codex action"
require_text "$WORKFLOW" 'pull-requests: write' "PR creation job has explicit pull request permission"
require_text "$WORKFLOW" 'gh pr create --draft' "automation opens a Draft PR"
require_text "$WORKFLOW" './tests/android-pr-evidence-test.sh' "automation verifies PR evidence behavior"
require_text "$WORKFLOW" './scripts/validate-wiki.sh' "automation validates Wiki changes"
require_text "$PROMPT" '미병합 PR' "prompt forbids unmerged PR evidence"
require_text "$PROMPT" '직접 병합' "prompt forbids direct merge"
require_text "$PROMPT" '신뢰되지 않은 입력' "prompt treats PR text as untrusted"

if [ -f "$WORKFLOW" ]; then
  unpinned=$(grep -E '^[[:space:]]*uses:' "$WORKFLOW" | grep -Ev '@[0-9a-f]{40}([[:space:]]|$)' || true)
  if [ -z "$unpinned" ]; then
    pass "all workflow actions are pinned to full commit SHAs"
  else
    fail "workflow contains unpinned actions: $unpinned"
  fi
fi

if [ "$failures" -ne 0 ]; then
  printf '\nWiki automation test failed with %s issue(s).\n' "$failures" >&2
  exit 1
fi

printf '\nWiki automation test passed.\n'
