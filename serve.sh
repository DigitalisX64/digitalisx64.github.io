#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
PORT="${1:-8000}"
echo "Serving at http://localhost:$PORT"

# The site is built by Jekyll: posts are Markdown under _posts/, and index.html
# carries front matter for the latest-post highlight. Serving the sources raw
# would show that front matter, so fall back to the last build before the
# sources, and to the sources only when there is no build to serve.
if ! command -v jekyll >/dev/null 2>&1; then
  if [ -d _site ]; then
    echo "jekyll not found: serving the last build in _site" >&2
    cd _site
  else
    echo "jekyll not found and no _site to serve: rendering sources raw" >&2
  fi
  exec python3 -m http.server "$PORT"
fi

# `jekyll serve` watches the tree for changes through inotify, and a watch
# descriptor is a per-user resource shared with everything else on the machine.
# An editor indexing a large checkout can hold the entire budget, at which point
# Jekyll dies on INotifyMaxWatchesExceeded before it ever serves a byte -- even
# though this site is a handful of files. Polling needs no descriptors, so use
# it when the budget is spent instead of failing. Raising the limit is the real
# fix; see the README.
POLL=()
if [ -r /proc/sys/fs/inotify/max_user_watches ]; then
  max="$(cat /proc/sys/fs/inotify/max_user_watches)"
  used="$(cat /proc/[0-9]*/fdinfo/* 2>/dev/null | grep -c '^inotify' || true)"
  if [ "${used:-0}" -gt "$(( max - 200 ))" ]; then
    echo "inotify watches exhausted (${used}/${max}) -- watching by polling" >&2
    POLL=(--force_polling)
  fi
fi

exec jekyll serve --port "$PORT" "${POLL[@]}"
