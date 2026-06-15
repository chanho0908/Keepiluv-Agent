#!/bin/sh

set -u

ROOT_DIR=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
WORKFLOW="$ROOT_DIR/.github/workflows/wiki-validation.yml"
IMPLEMENTER="$ROOT_DIR/.codex/agents/tier2/implementer.md"
MAINTAINER="$ROOT_DIR/.agents/skills/wiki-maintainer/SKILL.md"
COMMITTER="$ROOT_DIR/.codex/agents/tier2/committer.md"
PR_CREATOR="$ROOT_DIR/.codex/agents/tier2/pr-creator.md"
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

for removed in \
  "$ROOT_DIR/.github/workflows/android-pr-wiki-maintenance.yml" \
  "$ROOT_DIR/.github/codex/prompts/maintain-wiki-from-android-pr.md" \
  "$ROOT_DIR/scripts/android-pr-evidence.sh" \
  "$ROOT_DIR/scripts/android_pr_evidence.rb" \
  "$ROOT_DIR/tests/android-pr-evidence-test.sh"; do
  if [ ! -e "$removed" ]; then
    pass "obsolete Android PR automation is removed: ${removed#"$ROOT_DIR/"}"
  else
    fail "obsolete Android PR automation must be removed: ${removed#"$ROOT_DIR/"}"
  fi
done

require_text "$WORKFLOW" 'pull_request:' "Wiki validation runs for pull requests"
require_text "$WORKFLOW" 'workflow_dispatch:' "Wiki validation supports manual runs"
require_text "$WORKFLOW" 'contents: read' "Wiki validation uses read-only repository permission"
require_text "$WORKFLOW" './tests/wiki-migration-test.sh' "workflow verifies Wiki migration"
require_text "$WORKFLOW" './tests/wiki-status-test.sh' "workflow verifies Wiki status"
require_text "$WORKFLOW" './tests/wiki-validator-test.sh' "workflow verifies Wiki rules"
require_text "$WORKFLOW" './scripts/validate-wiki.sh' "workflow runs the Wiki validator"
require_text "$IMPLEMENTER" '장기 지식' "implementer evaluates durable knowledge"
require_text "$IMPLEMENTER" 'wiki-maintainer' "implementer hands durable knowledge to wiki-maintainer"
require_text "$MAINTAINER" '작업 중 확인한 코드' "wiki maintainer uses current work evidence"
require_text "$MAINTAINER" 'PR 번호' "wiki maintainer explicitly excludes PR numbers from Wiki sources"
require_text "$MAINTAINER" '별도 Git 승인 없이' "wiki maintainer automates approved Wiki Git completion"
require_text "$MAINTAINER" '제품 기능 코드가 섞이면' "wiki maintainer preserves normal approval for product code"
require_text "$COMMITTER" 'Wiki 전용 자동 Git 조건' "committer recognizes the Wiki-only approval exception"
require_text "$PR_CREATOR" 'PR은 반드시 Draft' "PR creator requires Draft Wiki pull requests"
require_text "$PR_CREATOR" '자동 병합하지 않음' "PR creator forbids automatic Wiki merges"

if grep -Fq 'fetch-depth: 0' "$WORKFLOW"; then
  fail "Wiki validation must not require full Git history for migration invariants"
else
  pass "Wiki validation does not require full Git history"
fi

if rg -n 'OPENAI_API_KEY|openai/codex-action|api\.deepseek\.com|repository_dispatch|pr:PR-URL' \
  "$ROOT_DIR/.github" "$ROOT_DIR/wiki" "$ROOT_DIR/.agents/skills/wiki-maintainer" "$ROOT_DIR/.codex/agents/tier2/wiki-maintainer.md" \
  >/dev/null 2>&1; then
  fail "Wiki maintenance configuration must not require an external LLM API or PR evidence source"
else
  pass "Wiki maintenance configuration requires no external LLM API or PR evidence source"
fi

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
