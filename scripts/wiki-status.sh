#!/bin/sh

set -u

ROOT_DIR=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
exec ruby "$ROOT_DIR/scripts/wiki_status.rb" "$@"
