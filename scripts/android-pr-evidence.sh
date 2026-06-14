#!/bin/sh

set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
exec ruby "$ROOT_DIR/scripts/android_pr_evidence.rb" "$@"
