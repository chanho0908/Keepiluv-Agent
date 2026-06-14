#!/usr/bin/env ruby

require "digest"
require "fileutils"
require "open3"
require "yaml"
require "date"
require "pathname"

ROOT = File.expand_path("..", __dir__)
MANIFEST = File.join(ROOT, "wiki/state/source-manifest.tsv")
TRACKED_FILES = ["AGENTS.md"].freeze
TRACKED_GLOBS = [
  "wiki/reference/**/*.md",
  "wiki/operations/**/*.md",
  "wiki/schema/**/*.md",
  ".codex/agents/**/*.md",
  ".agents/skills/**/*.md",
  ".agents/skills/**/*.yaml",
  ".github/codex/**/*.md",
  ".github/workflows/**/*.yml",
  ".github/workflows/**/*.yaml"
].freeze
REQUIRED_CANONICAL = %w[
  wiki/reference/project-overview.md
  wiki/reference/architecture.md
  wiki/reference/module-hierarchy.md
  wiki/reference/domain-glossary.md
  wiki/reference/test-strategy.md
  wiki/operations/routing-rules.md
  wiki/operations/workflows.md
  wiki/operations/agent-list.md
].freeze

def safe_relative_path?(path)
  !path.empty? && !Pathname.new(path).absolute? && !path.split("/").include?("..")
end

def current_sources
  paths = (TRACKED_FILES + TRACKED_GLOBS.flat_map { |pattern| Dir.glob(File.join(ROOT, pattern)) })
    .map { |path| Pathname.new(File.expand_path(path, ROOT)).relative_path_from(Pathname.new(ROOT)).to_s }
    .select { |path| File.file?(File.join(ROOT, path)) }
    .uniq
    .sort
  paths.to_h { |path| [path, Digest::SHA256.file(File.join(ROOT, path)).hexdigest] }
end

def read_manifest
  return {} unless File.file?(MANIFEST)

  lines = File.readlines(MANIFEST, chomp: true)
  abort "invalid manifest header" if lines.empty?
  abort "invalid manifest header" unless lines.shift == "path\tsha256"

  rows = lines.map do |line|
    path, digest, extra = line.split("\t", -1)
    abort "invalid manifest row: path must be repository-relative and non-empty" if extra || path.nil? || !safe_relative_path?(path)
    abort "invalid manifest row: sha256 must be 64 lowercase hex characters" unless digest&.match?(/\A[0-9a-f]{64}\z/)
    [path, digest]
  end
  paths = rows.map(&:first)
  abort "invalid manifest: duplicate path" unless paths.uniq.length == paths.length
  abort "invalid manifest: paths must be sorted" unless paths == paths.sort
  rows.to_h
end

def source_paths(topic)
  content = File.read(topic)
  match = content.match(/\A---\r?\n(.*?)\r?\n---(?:\r?\n|\z)/m)
  return [] unless match

  data = YAML.safe_load(match[1], permitted_classes: [Date], aliases: false)
  paths = data.is_a?(Hash) ? data["source_paths"] : nil
  paths.is_a?(Array) ? paths.grep(String) : []
rescue Psych::Exception
  []
end

def print_status(previous, current)
  changed = []
  (previous.keys | current.keys).sort.each do |path|
    kind = if !previous.key?(path)
      "NEW"
    elsif !current.key?(path)
      "DELETED"
    elsif previous[path] != current[path]
      "CHANGED"
    end
    next unless kind

    changed << path
    puts [kind, path].join("\t")
  end

  topics = Dir.glob(File.join(ROOT, "wiki/topics/**/*.md")).sort
  changed.each do |source|
    topics.each do |topic|
      next unless source_paths(topic).include?(source)

      relative_topic = Pathname.new(topic).relative_path_from(Pathname.new(ROOT)).to_s
      puts ["IMPACT", source, relative_topic].join("\t")
    end
  end
end

def write_manifest(sources)
  FileUtils.mkdir_p(File.dirname(MANIFEST))
  content = (["path\tsha256"] + sources.map { |path, digest| "#{path}\t#{digest}" }).join("\n") + "\n"
  return if File.file?(MANIFEST) && File.read(MANIFEST) == content

  File.write(MANIFEST, content)
end

def validate_acceptance!
  missing = REQUIRED_CANONICAL.reject { |path| File.file?(File.join(ROOT, path)) }
  abort "canonical documents are missing: #{missing.join(', ')}" unless missing.empty?

  validator = File.join(ROOT, "scripts/validate-wiki.sh")
  abort "wiki validator is missing or not executable" unless File.executable?(validator)
  output, status = Open3.capture2e(validator)
  abort "wiki validation failed:\n#{output}" unless status.success?
end

accept = ARGV.include?("--accept")
approved = ARGV.include?("--approved")
valid_arguments = ARGV.uniq.length == ARGV.length && (ARGV - %w[--accept --approved]).empty?
abort "usage: wiki-status.sh [--accept --approved]" unless valid_arguments
abort "--accept requires explicit --approved" if accept && !approved
abort "--approved is only valid with --accept" if approved && !accept

previous = read_manifest
current = current_sources
print_status(previous, current)
if accept
  validate_acceptance!
  write_manifest(current)
end
