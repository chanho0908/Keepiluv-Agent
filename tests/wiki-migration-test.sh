#!/bin/sh

set -u

ROOT_DIR=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
INVENTORY="$ROOT_DIR/tests/fixtures/legacy-doc-inventory.tsv"
failures=0
BASELINE_COMMIT=14c17aa
TAB=$(printf '\t')
TMP_ROOT=$(mktemp -d "${TMPDIR:-/tmp}/wiki-migration-test.XXXXXX")
trap 'rm -rf "$TMP_ROOT"' EXIT HUP INT TERM

pass() {
  printf 'PASS: %s\n' "$1"
}

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  failures=$((failures + 1))
}

frontmatter_value() {
  file=$1
  key=$2
  ruby -e '
    require "yaml"
    require "date"
    content = File.read(ARGV[0])
    match = content.match(/\A---\r?\n(.*?)\r?\n---(?:\r?\n|\z)/m)
    exit 2 unless match
    data = YAML.safe_load(match[1], permitted_classes: [Date], aliases: false)
    value = data[ARGV[1]]
    puts value if value.is_a?(String)
  ' "$file" "$key" 2>/dev/null
}

find_legacy_references() {
  scan_root=$1
  find "$scan_root" \
    -path "$scan_root/.git" -prune -o \
    -path "$scan_root/.idea" -prune -o \
    -path "$scan_root/wiki/.obsidian" -prune -o \
    -type f -print | while IFS= read -r candidate; do
      relative=${candidate#"$scan_root/"}
      case "$relative" in
        tests/wiki-migration-test.sh|tests/wiki-validator-test.sh|scripts/validate-wiki.sh|tests/fixtures/legacy-doc-inventory.tsv)
          continue
          ;;
      esac
      LC_ALL=C grep -Iq . "$candidate" 2>/dev/null || continue
      allowed_legacy=''
      case "$relative" in
        wiki/reference/project-overview.md) allowed_legacy='.codex/docs/project-overview.md' ;;
        wiki/reference/architecture.md) allowed_legacy='.codex/docs/architecture.md' ;;
        wiki/reference/module-hierarchy.md) allowed_legacy='.codex/docs/hierarchy.md' ;;
        wiki/reference/domain-glossary.md) allowed_legacy='.codex/docs/domain-glossary.md' ;;
        wiki/reference/test-strategy.md) allowed_legacy='.codex/docs/test-strategy.md' ;;
        wiki/operations/routing-rules.md) allowed_legacy='.codex/docs/routing-rules.md' ;;
        wiki/operations/workflows.md) allowed_legacy='.codex/docs/workflows.md' ;;
        wiki/operations/agent-list.md) allowed_legacy='.codex/docs/agent-list.md' ;;
      esac
      grep -nF '.codex/docs' "$candidate" 2>/dev/null | while IFS= read -r match; do
        if [ -n "$allowed_legacy" ] && printf '%s\n' "$match" | grep -Eq "repo:[^[:space:]]+@[0-9a-fA-F]{40}:${allowed_legacy}\"?$"; then
          continue
        fi
        printf '%s:%s\n' "$relative" "$match"
      done
    done
}

legacy_scan_fixture="$TMP_ROOT/legacy-scan"
mkdir -p "$legacy_scan_fixture/tests" "$legacy_scan_fixture/scripts"
printf '%s\n' 'real legacy reference: .codex/docs/architecture.md' > "$legacy_scan_fixture/untracked-note.md"
printf '%s\n' 'test contract: .codex/docs' > "$legacy_scan_fixture/tests/wiki-migration-test.sh"
printf '%s\n' 'validator contract: .codex/docs' > "$legacy_scan_fixture/scripts/validate-wiki.sh"
legacy_scan_result=$(find_legacy_references "$legacy_scan_fixture")
if printf '%s\n' "$legacy_scan_result" | grep -Fq 'untracked-note.md:' &&
   ! printf '%s\n' "$legacy_scan_result" | grep -Eq 'tests/wiki-migration-test|scripts/validate-wiki'; then
  pass "legacy reference scan detects untracked documents without self-matching tester files"
else
  fail "legacy reference scan must detect untracked documents and use exact tester exclusions"
fi

if [ -e "$ROOT_DIR/.codex/docs" ]; then
  fail ".codex/docs must be removed after migration"
else
  pass ".codex/docs is removed"
fi

legacy_references=$(find_legacy_references "$ROOT_DIR")
if [ -n "$legacy_references" ]; then
  fail "tracked files still reference the legacy docs path:\n$legacy_references"
else
  pass "tracked and untracked documents contain no legacy docs path references outside canonical provenance"
fi

while IFS="$TAB" read -r legacy_file relative_file required_patterns; do
  [ -n "$legacy_file" ] || continue
  file="$ROOT_DIR/$relative_file"
  if [ ! -f "$file" ]; then
    fail "$relative_file is missing"
    continue
  fi

  authority=$(frontmatter_value "$file" authority || true)
  if [ "$authority" = canonical ]; then
    pass "$relative_file is canonical"
  else
    fail "$relative_file must declare authority: canonical"
  fi

  old_ifs=$IFS
  IFS='|'
  for required_pattern in $required_patterns; do
    if grep -Fq "$required_pattern" "$file"; then
      pass "$relative_file preserves: $required_pattern"
    else
      fail "$relative_file lost required knowledge: $required_pattern"
    fi
  done
  IFS=$old_ifs

  if git -C "$ROOT_DIR" cat-file -e "$BASELINE_COMMIT:$legacy_file" 2>/dev/null; then
    if LEGACY_FILE="$legacy_file" NEW_FILE="$file" BASELINE_COMMIT="$BASELINE_COMMIT" ROOT_DIR="$ROOT_DIR" ruby <<'RUBY'
legacy_path = ENV.fetch("LEGACY_FILE")
new_file = ENV.fetch("NEW_FILE")
root = ENV.fetch("ROOT_DIR")
commit = ENV.fetch("BASELINE_COMMIT")
legacy = IO.popen(["git", "-C", root, "show", "#{commit}:#{legacy_path}"], &:read)
new_content = File.read(new_file)
strip_frontmatter = ->(content) { content.sub(/\A---\r?\n.*?\r?\n---\r?\n/m, "") }
mapping = {
  ".codex/docs/project-overview.md" => "wiki/reference/project-overview.md",
  ".codex/docs/architecture.md" => "wiki/reference/architecture.md",
  ".codex/docs/hierarchy.md" => "wiki/reference/module-hierarchy.md",
  ".codex/docs/domain-glossary.md" => "wiki/reference/domain-glossary.md",
  ".codex/docs/test-strategy.md" => "wiki/reference/test-strategy.md",
  ".codex/docs/routing-rules.md" => "wiki/operations/routing-rules.md",
  ".codex/docs/workflows.md" => "wiki/operations/workflows.md",
  ".codex/docs/agent-list.md" => "wiki/operations/agent-list.md"
}
expected = strip_frontmatter.call(legacy)
mapping.each { |from, to| expected = expected.gsub(from, to) }
sentence_migrations = {
  "- 원본 교훈과 근거는 `.codex/diary/`, 프로젝트의 공식 사실과 정책은 `.codex/docs/`에 둔다\n" =>
    "- 원본 교훈과 근거는 `.codex/diary/`, 프로젝트의 공식 사실과 정책은 `wiki/reference/` 또는 관련 canonical Wiki 문서에 둔다\n",
  "  4. 기존 Skill의 상세 규칙은 해당 `references/`, 공식 사실과 정책은 `.codex/docs/`에 반영\n" =>
    "  4. 기존 Skill의 상세 규칙은 해당 `references/`, 공식 사실과 정책은 `wiki/reference/` 또는 관련 canonical Wiki 문서에 반영\n"
}
sentence_migrations.each { |from, to| expected = expected.gsub(from, to) }
actual = strip_frontmatter.call(new_content)
cursor = 0
preserved = expected.lines.all? do |line|
  found = actual.index(line, cursor)
  if found
    cursor = found + line.length
    true
  else
    false
  end
end
exit(preserved ? 0 : 1)
RUBY
    then
      pass "$relative_file contains the complete migrated body from $BASELINE_COMMIT:$legacy_file"
    else
      fail "$relative_file must preserve the complete legacy body from $BASELINE_COMMIT:$legacy_file"
    fi
  else
    fail "baseline source is unavailable: $BASELINE_COMMIT:$legacy_file"
  fi
done < "$INVENTORY"

while IFS="$TAB" read -r legacy_file relative_file _; do
  [ -f "$ROOT_DIR/$relative_file" ] || continue
  if FILE="$ROOT_DIR/$relative_file" LEGACY="$legacy_file" ruby <<'RUBY'
require "yaml"
require "date"
content = File.read(ENV.fetch("FILE"))
match = content.match(/\A---\r?\n(.*?)\r?\n---(?:\r?\n|\z)/m)
exit 1 unless match
data = YAML.safe_load(match[1], permitted_classes: [Date], aliases: false)
sources = data.is_a?(Hash) ? data["sources"] : nil
exit(sources.is_a?(Array) && sources.any? { |source| source.is_a?(String) && source.end_with?(":#{ENV.fetch("LEGACY")}") } ? 0 : 1)
RUBY
  then
    pass "$relative_file records provenance to $legacy_file"
  else
    fail "$relative_file sources must reference the legacy path $legacy_file"
  fi
done < "$INVENTORY"

if [ -f "$ROOT_DIR/wiki/reference/architecture.md" ]; then
  for provenance in \
    '.codex/docs/architecture.md' \
    'wiki/topics/architecture/mvi-state-and-collaboration.md' \
    '.codex/diary/2026-05-15-loading-error-ui-collaboration-retrospective.md'; do
    if grep -Fq "$provenance" "$ROOT_DIR/wiki/reference/architecture.md"; then
      pass "architecture provenance includes $provenance"
    else
      fail "architecture sources must include $provenance"
    fi
  done
fi

if [ -d "$ROOT_DIR/wiki/topics" ]; then
  while IFS= read -r topic; do
    relative_topic=${topic#"$ROOT_DIR/"}
    TOPIC="$topic" ruby -e '
      require "yaml"
      require "date"
      content = File.read(ENV.fetch("TOPIC"))
      match = content.match(/\A---\r?\n(.*?)\r?\n---(?:\r?\n|\z)/m)
      exit 1 unless match
      data = YAML.safe_load(match[1], permitted_classes: [Date], aliases: false)
      paths = data["source_paths"]
      exit(data["authority"] == "synthesized" && paths.is_a?(Array) && !paths.empty? ? 0 : 1)
    ' && pass "$relative_topic is synthesized with source_paths" || fail "$relative_topic must declare authority: synthesized and non-empty source_paths"
  done <<EOF
$(find "$ROOT_DIR/wiki/topics" -type f -name '*.md' -print | sort)
EOF
fi

for agent in \
  .codex/agents/tier1/explore.md \
  .codex/agents/tier1/writer.md \
  .codex/agents/tier2/analyst.md \
  .codex/agents/tier2/planner.md \
  .codex/agents/tier2/tester.md \
  .codex/agents/tier2/implementer.md \
  .codex/agents/tier2/code-reviewer.md; do
  if [ ! -f "$ROOT_DIR/$agent" ]; then
    fail "$agent is missing"
  elif AGENT_FILE="$ROOT_DIR/$agent" ruby -e '
    content = File.read(ENV.fetch("AGENT_FILE"))
    exit(content.match?(/wiki\/index\.md.{0,160}(먼저|우선|시작)|(먼저|우선|시작).{0,160}wiki\/index\.md/m) ? 0 : 1)
  '; then
    pass "$agent starts knowledge discovery from wiki/index.md"
  else
    fail "$agent must reference wiki/index.md as the first knowledge entry point"
  fi
done

for required_file in \
  .codex/agents/tier2/wiki-maintainer.md \
  .agents/skills/wiki-maintainer/SKILL.md \
  .agents/skills/wiki-maintainer/agents/openai.yaml; do
  if [ -f "$ROOT_DIR/$required_file" ]; then
    pass "$required_file exists"
  else
    fail "$required_file is missing"
  fi
done

for routing_file in AGENTS.md wiki/operations/routing-rules.md wiki/operations/agent-list.md; do
  if [ -f "$ROOT_DIR/$routing_file" ] && grep -Fq 'wiki-maintainer' "$ROOT_DIR/$routing_file"; then
    pass "$routing_file routes wiki maintenance"
  else
    fail "$routing_file must include wiki-maintainer"
  fi
done

if [ -f "$ROOT_DIR/wiki/index.md" ]; then
  while IFS="$TAB" read -r _ canonical_file _; do
    target=${canonical_file#wiki/}
    if grep -Fq "]($target)" "$ROOT_DIR/wiki/index.md" || grep -Fq "](./$target)" "$ROOT_DIR/wiki/index.md"; then
      pass "wiki/index.md directly links $target"
    else
      fail "wiki/index.md must directly link $target"
    fi
  done < "$INVENTORY"
fi

if [ "${WIKI_CLEAN_CHECKOUT_CHILD:-0}" != 1 ]; then
  seed="$TMP_ROOT/seed"
  checkout="$TMP_ROOT/checkout"
  git clone -q "$ROOT_DIR" "$seed"
  git -C "$seed" rm -qr --ignore-unmatch .
  (cd "$ROOT_DIR" && tar --exclude=.git --exclude=.idea --exclude=wiki/.obsidian -cf - .) | (cd "$seed" && tar -xf -)
  git -C "$seed" add -A
  git -C "$seed" -c user.name=Tester -c user.email=tester@example.com commit -qm 'test clean checkout'
  git clone -q "$seed" "$checkout"
  git -C "$checkout" remote set-url origin https://github.com/chanho0908/Keepiluv-Agent.git
  for directory in wiki/topics/architecture wiki/topics/domain wiki/topics/development wiki/topics/operations; do
    [ -d "$checkout/$directory" ] || fail "clean checkout must preserve empty required directory $directory"
  done
  if WIKI_CLEAN_CHECKOUT_CHILD=1 "$checkout/tests/wiki-migration-test.sh" >/dev/null 2>&1; then
    pass "migration test passes from a clean checkout"
  else
    fail "migration test must pass from a clean checkout"
  fi
  if "$checkout/scripts/validate-wiki.sh" >/dev/null 2>&1; then
    pass "wiki validator passes from a clean checkout"
  else
    fail "wiki validator must pass from a clean checkout"
  fi
fi

if [ "$failures" -ne 0 ]; then
  printf '\nWiki migration test failed with %s issue(s).\n' "$failures" >&2
  exit 1
fi

printf '\nWiki migration test passed.\n'
