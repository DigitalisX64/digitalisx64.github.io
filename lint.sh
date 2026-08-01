#!/usr/bin/env bash
# Source-level checks, the same ones CI runs. HTML and CSS are validated
# against the built site instead, which needs Jekyll — CI does that after
# building; locally, `jekyll build && html5validator --root _site
# --also-check-css` is the equivalent.
#
#   ./lint.sh          check everything
#   pip install yamllint pymarkdownlnt pyyaml
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
