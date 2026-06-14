#!/bin/sh

set -u

ROOT_DIR=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
WIKI_DIR="$ROOT_DIR/wiki"
failures=0
ruby_available=1

pass() {
  printf 'PASS: %s\n' "$1"
}

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  failures=$((failures + 1))
}

if ! command -v ruby >/dev/null 2>&1; then
  ruby_available=0
  fail "Ruby runtime is required for YAML, date, and percent-encoded link validation"
elif ! ruby -e 'require "yaml"; require "date"; require "uri"' >/dev/null 2>&1; then
  ruby_available=0
  fail "Ruby standard libraries Psych, Date, and URI are required for wiki validation"
else
  pass "Ruby with Psych, Date, and URI is available"
fi

require_directory() {
  relative_path=$1
  if [ -d "$ROOT_DIR/$relative_path" ]; then
    pass "$relative_path directory exists"
  else
    fail "$relative_path directory is missing"
  fi
}

require_file() {
  relative_path=$1
  if [ -f "$ROOT_DIR/$relative_path" ]; then
    pass "$relative_path file exists"
  else
    fail "$relative_path file is missing"
  fi
}

validate_manifest() {
  manifest="$ROOT_DIR/wiki/state/source-manifest.tsv"
  [ -f "$manifest" ] || return
  if [ "$ruby_available" -ne 1 ]; then
    fail "wiki/state/source-manifest.tsv could not be validated because Ruby is unavailable"
    return
  fi
  manifest_output=$(mktemp "${TMPDIR:-/tmp}/validate-wiki-manifest.XXXXXX") || {
    fail "could not create temporary file for manifest validation"
    return
  }
  if ruby - "$manifest" >"$manifest_output" 2>&1 <<'RUBY'
file = ARGV.fetch(0)
lines = File.readlines(file, chomp: true)
abort "manifest must start with exact path<TAB>sha256 header" unless lines.shift == "path\tsha256"
paths = []
lines.each_with_index do |line, index|
  path, digest, extra = line.split("\t", -1)
  abort "manifest row #{index + 2} must contain exactly two columns" if extra || path.nil? || digest.nil?
  abort "manifest row #{index + 2} path must not be empty" if path.empty?
  abort "manifest row #{index + 2} path must be repository-relative" if path.start_with?("/") || path.split("/").include?("..")
  abort "manifest row #{index + 2} sha256 must be 64 lowercase hex characters" unless digest.match?(/\A[0-9a-f]{64}\z/)
  abort "manifest contains duplicate path: #{path}" if paths.include?(path)
  paths << path
end
abort "manifest paths must be sorted" unless paths == paths.sort
puts "manifest header, rows, safe paths, hashes, uniqueness, and sorting are valid"
RUBY
  then
    manifest_result=$(cat "$manifest_output")
    rm -f "$manifest_output"
    pass "$manifest_result"
  else
    manifest_result=$(cat "$manifest_output")
    rm -f "$manifest_output"
    fail "$manifest_result"
  fi
}

find_legacy_references() {
  find "$ROOT_DIR" \
    -path "$ROOT_DIR/.git" -prune -o \
    -path "$ROOT_DIR/.idea" -prune -o \
    -path "$ROOT_DIR/wiki/.obsidian" -prune -o \
    -type f -print | while IFS= read -r candidate; do
      relative=${candidate#"$ROOT_DIR/"}
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

current_repository_slug() {
  remote_url=$(git -C "$ROOT_DIR" remote get-url origin 2>/dev/null || true)
  printf '%s\n' "$remote_url" | sed -E 's#^git@github\.com:##; s#^https://github\.com/##; s#\.git$##'
}

validate_frontmatter() {
  file=$1
  label=${file#"$ROOT_DIR/"}
  if [ "$ruby_available" -ne 1 ]; then
    fail "$label frontmatter could not be parsed because Ruby is unavailable"
    return
  fi
  current_repository=$(current_repository_slug)
  yaml_results=$(ROOT_DIR="$ROOT_DIR" CURRENT_REPOSITORY="$current_repository" ruby - "$file" "$label" <<'RUBY'
require "yaml"
require "date"
require "uri"

file, label = ARGV
root = ENV.fetch("ROOT_DIR")
current_repository = ENV.fetch("CURRENT_REPOSITORY")

def result(kind, message)
  puts "#{kind}:#{message}"
end

begin
  content = File.binread(file).force_encoding("UTF-8")
  raise "is not valid UTF-8" unless content.valid_encoding?
  match = content.match(/\A---\r?\n(.*?)\r?\n---(?:\r?\n|\z)/m)
  raise "must start with closed YAML frontmatter" unless match
  data = YAML.safe_load(match[1], [Date], [], false)
  raise "frontmatter must be a YAML mapping" unless data.is_a?(Hash)

  status = data["status"]
  result(status.is_a?(String) && !status.strip.empty? ? "PASS" : "FAIL",
         "#{label} status must be a non-empty string")

  tags = data["tags"]
  valid_tags = tags.is_a?(Array) && !tags.empty? && tags.all? { |tag| tag.is_a?(String) && !tag.strip.empty? }
  result(valid_tags ? "PASS" : "FAIL", "#{label} tags must be a non-empty string list")

  raw_date = match[1][/^last_verified:[ \t]*(.+?)[ \t]*$/, 1]
  valid_date = false
  if raw_date&.match?(/\A\d{4}-\d{2}-\d{2}\z/)
    begin
      parsed_date = Date.iso8601(raw_date)
      valid_date = parsed_date.strftime("%Y-%m-%d") == raw_date
    rescue Date::Error
      valid_date = false
    end
  end
  result(valid_date ? "PASS" : "FAIL", "#{label} last_verified must be a real YYYY-MM-DD date")

  sources = data["sources"]
  valid_sources = sources.is_a?(Array) && !sources.empty? && sources.all? { |source| source.is_a?(String) && !source.empty? }
  unless valid_sources
    result("FAIL", "#{label} sources must be a non-empty string list")
    exit
  end
  result("PASS", "#{label} sources is a non-empty string list")

  sources.each do |source|
    if (repo_match = source.match(/\Arepo:([A-Za-z0-9_.-]+\/[A-Za-z0-9_.-]+)@([0-9a-fA-F]{40}):(.+)\z/))
      repository, commit, path = repo_match.captures
      if repository != current_repository
        result("FAIL", "#{label} external repo source is forbidden; use a commit permalink URL with checked date: #{source}")
        next
      end
      if path.start_with?("/") || path.split("/").include?("..")
        result("FAIL", "#{label} repo source path must stay inside the repository: #{path}")
        next
      end
      if system("git", "-C", root, "cat-file", "-e", "#{commit}:#{path}", out: File::NULL, err: File::NULL)
        result("PASS", "#{label} source exists at #{commit}:#{path}")
      else
        result("FAIL", "#{label} source does not exist at #{commit}:#{path}")
      end
    elsif (url_match = source.match(/\Aurl:(https?:\/\/[^|\s]+)\|checked:(\d{4}-\d{2}-\d{2})\z/))
      source_url = url_match[1]
      checked = url_match[2]
      begin
        valid_checked = Date.iso8601(checked).strftime("%Y-%m-%d") == checked
      rescue Date::Error
        valid_checked = false
      end
      result(valid_checked ? "PASS" : "FAIL", "#{label} URL source checked date must be real: #{source}")

      begin
        parsed_url = URI.parse(source_url)
        if parsed_url.host == "github.com"
          fixed_blob = parsed_url.path.match?(%r{\A/[^/]+/[^/]+/blob/[0-9a-fA-F]{40}/.+\z})
          result(fixed_blob ? "PASS" : "FAIL",
                 "#{label} GitHub URL source must use /blob/<40-hex-commit>/ path: #{source}")
        elsif parsed_url.host == "raw.githubusercontent.com"
          result("FAIL", "#{label} raw GitHub URL sources are not supported; use a GitHub commit permalink: #{source}")
        end
      rescue URI::InvalidURIError
        result("FAIL", "#{label} URL source is invalid: #{source}")
      end
    else
      result("FAIL", "#{label} source must use current-origin repo or url format: #{source}")
    end
  end

  authority = data["authority"]
  valid_authority = ["canonical", "synthesized"].include?(authority)
  result(valid_authority ? "PASS" : "FAIL",
         "#{label} authority must be canonical or synthesized")

  if authority == "synthesized"
    source_paths = data["source_paths"]
    valid_source_paths = source_paths.is_a?(Array) && !source_paths.empty? &&
      source_paths.all? { |path| path.is_a?(String) && !path.empty? && !path.start_with?("/") && !path.split("/").include?("..") }
    result(valid_source_paths ? "PASS" : "FAIL",
           "#{label} synthesized page must have non-empty repository-relative source_paths")
    if valid_source_paths
      source_paths.each do |path|
        result(File.file?(File.join(root, path)) ? "PASS" : "FAIL",
               "#{label} source_path must exist: #{path}")
      end
    end
  end
rescue Psych::Exception => error
  result("FAIL", "#{label} has invalid YAML frontmatter: #{error.message.lines.first.strip}")
rescue StandardError => error
  result("FAIL", "#{label} #{error.message}")
end
RUBY
)

  while IFS= read -r yaml_result; do
    [ -n "$yaml_result" ] || continue
    case "$yaml_result" in
      PASS:*) pass "${yaml_result#PASS:}" ;;
      FAIL:*) fail "${yaml_result#FAIL:}" ;;
    esac
  done <<EOF
$yaml_results
EOF
}

normalize_vault_path() {
  awk -v path="$1" '
    BEGIN {
      count = split(path, parts, "/")
      depth = 0
      for (i = 1; i <= count; i++) {
        if (parts[i] == "" || parts[i] == ".") continue
        if (parts[i] == "..") {
          if (depth == 0) exit 1
          depth--
        } else {
          stack[++depth] = parts[i]
        }
      }
      if (depth == 0) {
        print "."
        exit
      }
      result = stack[1]
      for (i = 2; i <= depth; i++) result = result "/" stack[i]
      print result
    }
  '
}

extract_markdown_links() {
  awk '
    {
      line = $0
      while (match(line, /\[[^][]*\]\((<[^>]+>|[^()[:space:]]+)([[:space:]]+"[^"]*")?\)/)) {
        link = substr(line, RSTART, RLENGTH)
        sub(/^.*\]\(/, "", link)
        sub(/\)$/, "", link)
        sub(/[[:space:]]+"[^"]*"$/, "", link)
        if (link ~ /^<.*>$/) {
          sub(/^</, "", link)
          sub(/>$/, "", link)
        }
        print link
        line = substr(line, RSTART + RLENGTH)
      }
    }
  ' "$1"
}

decode_link_destination() {
  if [ "$ruby_available" -ne 1 ]; then
    return 1
  fi
  ruby -r uri -e '
    value = STDIN.read
    begin
      decoded = URI::DEFAULT_PARSER.unescape(value)
      raise "decoded link is not valid UTF-8" unless decoded.force_encoding("UTF-8").valid_encoding?
      print decoded
    rescue StandardError => error
      warn error.message
      exit 1
    end
  '
}

validate_links() {
  file=$1
  label=${file#"$ROOT_DIR/"}
  file_dir=${label%/*}
  [ "$file_dir" != "$label" ] || file_dir=.

  extract_markdown_links "$file" | while IFS= read -r destination; do
    case "$destination" in
      ''|'#'*|http://*|https://*|mailto:*) continue ;;
    esac

    destination=${destination%%#*}
    destination=${destination%%\?*}
    decoded_destination=$(printf '%s' "$destination" | decode_link_destination 2>/dev/null || true)
    if [ -z "$decoded_destination" ] && [ -n "$destination" ]; then
      printf 'LINK_FAIL:%s has an invalid percent-encoded link: %s\n' "$label" "$destination"
      continue
    fi
    destination=$decoded_destination
    case "$destination" in
      /*)
        printf 'LINK_FAIL:%s uses an absolute link: %s\n' "$label" "$destination"
        continue
        ;;
    esac

    normalized=$(normalize_vault_path "$file_dir/$destination" 2>/dev/null || true)
    if [ -z "$normalized" ]; then
      printf 'LINK_FAIL:%s link escapes the vault: %s\n' "$label" "$destination"
    elif [ ! -e "$ROOT_DIR/$normalized" ]; then
      printf 'LINK_FAIL:%s has a broken link: %s\n' "$label" "$destination"
    fi
  done
}

for directory in \
  wiki/inbox \
  wiki/sources \
  wiki/topics/architecture \
  wiki/topics/domain \
  wiki/topics/development \
  wiki/topics/operations \
  wiki/decisions \
  wiki/schema \
  wiki/templates \
  wiki/attachments; do
  require_directory "$directory"
done

require_directory wiki/reference
require_directory wiki/operations
require_directory wiki/state

require_file wiki/index.md
require_file wiki/log.md
require_file wiki/schema/page-template.md
require_file wiki/state/source-manifest.tsv

for canonical_file in \
  wiki/reference/project-overview.md \
  wiki/reference/architecture.md \
  wiki/reference/module-hierarchy.md \
  wiki/reference/domain-glossary.md \
  wiki/reference/test-strategy.md \
  wiki/operations/routing-rules.md \
  wiki/operations/workflows.md \
  wiki/operations/agent-list.md; do
  require_file "$canonical_file"
done

validate_manifest

if [ "$ruby_available" -eq 1 ]; then
  provenance_results=$(ROOT_DIR="$ROOT_DIR" ruby <<'RUBY'
require "yaml"
require "date"
root = ENV.fetch("ROOT_DIR")
mapping = {
  "wiki/reference/project-overview.md" => ".codex/docs/project-overview.md",
  "wiki/reference/architecture.md" => ".codex/docs/architecture.md",
  "wiki/reference/module-hierarchy.md" => ".codex/docs/hierarchy.md",
  "wiki/reference/domain-glossary.md" => ".codex/docs/domain-glossary.md",
  "wiki/reference/test-strategy.md" => ".codex/docs/test-strategy.md",
  "wiki/operations/routing-rules.md" => ".codex/docs/routing-rules.md",
  "wiki/operations/workflows.md" => ".codex/docs/workflows.md",
  "wiki/operations/agent-list.md" => ".codex/docs/agent-list.md"
}
mapping.each do |file, legacy|
  path = File.join(root, file)
  next unless File.file?(path)
  content = File.read(path)
  match = content.match(/\A---\r?\n(.*?)\r?\n---(?:\r?\n|\z)/m)
  data = match && YAML.safe_load(match[1], permitted_classes: [Date], aliases: false)
  sources = data.is_a?(Hash) ? data["sources"] : nil
  authority = data.is_a?(Hash) ? data["authority"] : nil
  puts "#{authority == 'canonical' ? 'PASS' : 'FAIL'}:#{file} must declare authority: canonical"
  valid = sources.is_a?(Array) && sources.any? { |source| source.is_a?(String) && source.end_with?(":#{legacy}") }
  puts "#{valid ? 'PASS' : 'FAIL'}:#{file} sources must preserve provenance to #{legacy}"
end
architecture = File.join(root, "wiki/reference/architecture.md")
if File.file?(architecture)
  content = File.read(architecture)
  [
    ".codex/docs/architecture.md",
    "wiki/topics/architecture/mvi-state-and-collaboration.md",
    ".codex/diary/2026-05-15-loading-error-ui-collaboration-retrospective.md"
  ].each do |source|
    puts "#{content.include?(source) ? 'PASS' : 'FAIL'}:wiki/reference/architecture.md provenance must include #{source}"
  end
end
RUBY
  )
  while IFS= read -r provenance_result; do
    case "$provenance_result" in
      PASS:*) pass "${provenance_result#PASS:}" ;;
      FAIL:*) fail "${provenance_result#FAIL:}" ;;
    esac
  done <<EOF
$provenance_results
EOF
fi

markdown_count=0
if [ -d "$WIKI_DIR" ]; then
  while IFS= read -r markdown_file; do
    markdown_count=$((markdown_count + 1))
    validate_frontmatter "$markdown_file"

    link_results=$(validate_links "$markdown_file")
    if [ -n "$link_results" ]; then
      while IFS= read -r link_result; do
        fail "${link_result#LINK_FAIL:}"
      done <<EOF
$link_results
EOF
    else
      pass "${markdown_file#"$ROOT_DIR/"} has valid relative Markdown links"
    fi
  done <<EOF
$(find "$WIKI_DIR" -type f -name '*.md' -print | sort)
EOF
fi

if [ "$markdown_count" -eq 0 ]; then
  fail "wiki needs at least one Markdown document"
fi

if [ -f "$WIKI_DIR/index.md" ]; then
  index_targets=$(extract_markdown_links "$WIKI_DIR/index.md")
  decoded_index_targets=''
  while IFS= read -r index_target; do
    case "$index_target" in
      ''|'#'*|http://*|https://*|mailto:*) continue ;;
    esac
    index_target=${index_target%%#*}
    index_target=${index_target%%\?*}
    decoded_index_target=$(printf '%s' "$index_target" | decode_link_destination 2>/dev/null || true)
    [ -n "$decoded_index_target" ] || continue
    decoded_index_targets=${decoded_index_targets}${decoded_index_target}'
'
  done <<EOF
$index_targets
EOF
  while IFS= read -r candidate; do
    relative_candidate=${candidate#"$WIKI_DIR/"}
    [ "$relative_candidate" != index.md ] || continue
    case "$relative_candidate" in
      topics/*|reference/*|operations/*|schema/*|templates/*|log.md)
        if printf '%s' "$decoded_index_targets" | grep -Fqx "$relative_candidate"; then
          pass "wiki/index.md links operational document $relative_candidate"
        else
          fail "orphan candidate not linked directly from wiki/index.md: $relative_candidate"
        fi
        ;;
    esac
  done <<EOF
$(find "$WIKI_DIR/topics" "$WIKI_DIR/schema" "$WIKI_DIR/templates" -type f -name '*.md' -print 2>/dev/null | sort)
$WIKI_DIR/log.md
EOF
fi

if [ -e "$ROOT_DIR/.codex/docs" ]; then
  fail ".codex/docs must be removed after wiki migration"
else
  pass ".codex/docs is removed"
fi

legacy_references=$(find_legacy_references)
if [ -n "$legacy_references" ]; then
  fail "repository documents still reference .codex/docs outside canonical provenance:\n$legacy_references"
else
  pass "tracked and untracked documents contain no legacy references outside canonical provenance"
fi

if [ -d "$WIKI_DIR" ]; then
  wikilink_found=0
  secret_found=0
  while IFS= read -r text_file; do
    if ! LC_ALL=C grep -Iq . "$text_file" 2>/dev/null; then
      continue
    fi
    if grep -nE '\[\[[^]]+\]\]' "$text_file" >/dev/null 2>&1; then
      fail "${text_file#"$ROOT_DIR/"} uses forbidden WikiLink syntax"
      wikilink_found=1
    fi

    if grep -nE '(-----BEGIN (RSA |EC |OPENSSH )?PRIVATE KEY-----|AKIA[0-9A-Z]{16}|gh[pousr]_[A-Za-z0-9_]{20,}|(api[_-]?key|access[_-]?token|secret[_-]?key)[[:space:]]*[:=][[:space:]]*[A-Za-z0-9_./+=-]{16,})' "$text_file" >/dev/null 2>&1; then
      fail "${text_file#"$ROOT_DIR/"} contains a likely secret"
      secret_found=1
    fi
  done <<EOF
$(find "$WIKI_DIR" -type f \( -name '*.md' -o -name '*.txt' -o -name '*.json' -o -name '*.yaml' -o -name '*.yml' -o -name '*.env' -o -name '*.pem' -o -name '*.key' -o -name '*.properties' -o -name '*.conf' -o -name '*.config' \) -print | sort)
EOF

  [ "$wikilink_found" -ne 0 ] || pass "wiki uses no WikiLink syntax"
  [ "$secret_found" -ne 0 ] || pass "wiki text files contain no obvious secret pattern"
fi

if [ "$failures" -ne 0 ]; then
  printf '\nWiki validation failed with %s issue(s).\n' "$failures" >&2
  exit 1
fi

printf '\nWiki validation passed.\n'
