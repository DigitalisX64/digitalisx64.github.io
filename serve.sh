#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
PORT="${1:-8000}"
echo "Serving at http://localhost:$PORT"

# The site is built by Jekyll: posts are Markdown under _posts/, and index.html
# carries front matter for the latest-post highlight. Serving the sources raw
# would show that front matter, so fall back to the last build before the
# sources, and to the sources only when there is no build to serve.
if command -v jekyll >/dev/null 2>&1; then
  exec jekyll serve --port "$PORT"
elif [ -d _site ]; then
  echo "jekyll not found: serving the last build in _site" >&2
  cd _site
  exec python3 -m http.server "$PORT"
else
  echo "jekyll not found and no _site to serve: rendering sources raw" >&2
  exec python3 -m http.server "$PORT"
fi
