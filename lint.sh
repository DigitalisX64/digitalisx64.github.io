#!/usr/bin/env bash
# Source-level checks, the same ones CI runs. HTML is validated against the
# built site instead, which needs Jekyll — CI does that after building;
# locally, `jekyll build && html5validator --root _site` is the equivalent.
#
#   ./lint.sh          check everything
#
# The tools live in the virtualenv ./setup-venv.sh creates; activate it first
# with `source .venv/bin/activate`. Each check below skips itself when its tool
# is not on PATH.
set -uo pipefail
cd "$(dirname "$0")"

status=0
run() {
  local label="$1"; shift
  printf '\n\033[1m== %s ==\033[0m\n' "$label"
  if ! "$@"; then
    status=1
    printf '\033[31mFAILED: %s\033[0m\n' "$label"
  fi
}

missing() {
  command -v "$1" >/dev/null 2>&1 && return 1
  printf '\n\033[33m-- skipping %s: %s not installed --\033[0m\n' "$2" "$1"
  return 0
}

missing yamllint  "YAML"     || run "YAML"          yamllint _config.yml _data .github/workflows
missing pymarkdown "Markdown" || run "Markdown"     pymarkdown --config .pymarkdown.json scan README.md _posts
run "App data schema" python3 scripts/check-apps-data.py

if [ "$status" -eq 0 ]; then
  printf '\n\033[32mAll checks passed.\033[0m\n'
else
  printf '\n\033[31mSome checks failed.\033[0m\n'
fi
exit "$status"
