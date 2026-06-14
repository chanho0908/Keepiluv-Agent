#!/bin/sh

set -u

ROOT_DIR=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
failures=0
TAB=$(printf '\t')

pass() { printf 'PASS: %s\n' "$1"; }
fail() { printf 'FAIL: %s\n' "$1" >&2; failures=$((failures + 1)); }

frontmatter_authority() {
  ruby -e '
    require "yaml"
    require "date"
    content = File.read(ARGV.fetch(0))
    match = content.match(/\A---\r?\n(.*?)\r?\n---(?:\r?\n|\z)/m)
    exit 1 unless match
    data = YAML.safe_load(match[1], permitted_classes: [Date], aliases: false)
    puts data["authority"] if data.is_a?(Hash)
  ' "$1" 2>/dev/null
}

if [ -e "$ROOT_DIR/.codex/docs" ]; then
  fail ".codex/docs must be absent after migration"
else
  pass ".codex/docs is absent"
fi

while IFS="$TAB" read -r relative_file required_patterns; do
  file="$ROOT_DIR/$relative_file"
  if [ ! -f "$file" ]; then
    fail "$relative_file is missing"
    continue
  fi

  if [ "$(frontmatter_authority "$file" || true)" = canonical ]; then
    pass "$relative_file is canonical"
  else
    fail "$relative_file must declare authority: canonical"
  fi

  old_ifs=$IFS
  IFS='|'
  for required_pattern in $required_patterns; do
    if grep -Fq "$required_pattern" "$file"; then
      pass "$relative_file contains core knowledge marker: $required_pattern"
    else
      fail "$relative_file is missing core knowledge marker: $required_pattern"
    fi
  done
  IFS=$old_ifs

  target=${relative_file#wiki/}
  if grep -Fq "]($target)" "$ROOT_DIR/wiki/index.md" || grep -Fq "](./$target)" "$ROOT_DIR/wiki/index.md"; then
    pass "wiki/index.md links $target"
  else
    fail "wiki/index.md must link $target"
  fi
done <<'EOF'
wiki/reference/project-overview.md	# Project Overview|## 서비스 개요|## 핵심 스택
wiki/reference/architecture.md	# Architecture Principles|## 레이어|## 의존 방향|## MVI 규칙
wiki/reference/module-hierarchy.md	# Module Hierarchy|## 최상위 구조|## 주요 core 모듈
wiki/reference/domain-glossary.md	# Keepiluv Domain Glossary|## 사용자와 커플|## 목표
wiki/reference/test-strategy.md	# Test Strategy|## 테스트 레벨 선택|## 작업 유형별 완료 기준
wiki/operations/routing-rules.md	# Agent Routing Rules|## 핵심 원칙|## 라우팅 우선순위
wiki/operations/workflows.md	# Complex Workflows|## 기본 조합|## 승인 포인트
wiki/operations/agent-list.md	# Agent List|## Tier 1 - 경량 탐색 / 문서|wiki-maintainer
EOF

if [ "$failures" -ne 0 ]; then
  printf '\nWiki migration test failed with %s issue(s).\n' "$failures" >&2
  exit 1
fi

printf '\nWiki migration test passed.\n'
