#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
PORT="${1:-8000}"
echo "Serving at http://localhost:$PORT"

# Posts are Markdown under _posts/ and are rendered by Jekyll, so prefer a real
# Jekyll server. Without it the plain file server still renders index.html and
# apps.html, but /blog.html and the post pages will be missing.
if command -v jekyll >/dev/null 2>&1; then
  exec jekyll serve --port "$PORT"
else
  echo "jekyll not found: serving raw files, /blog.html will not be available" >&2
  exec python3 -m http.server "$PORT"
fi
