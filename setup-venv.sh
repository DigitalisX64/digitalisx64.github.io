#!/usr/bin/env bash
# Create the Python virtualenv this site's checks run in, and install the
# tooling from requirements-dev.txt into it. Safe to re-run: an existing
# virtualenv is reused and its packages are brought up to date.
#
#   ./setup-venv.sh              create/update ./.venv
#   VENV_DIR=/tmp/x ./setup-venv.sh   put it somewhere else
#
# The virtualenv is git-ignored. Activate it with `source .venv/bin/activate`,
# or just run the tools directly out of .venv/bin — ./lint.sh finds them on
# PATH once the environment is active.
set -euo pipefail
cd "$(dirname "$0")"

VENV_DIR="${VENV_DIR:-.venv}"
PYTHON="${PYTHON:-python3}"

if ! command -v "$PYTHON" >/dev/null 2>&1; then
  echo "error: $PYTHON not found; install Python 3 or set PYTHON=" >&2
  exit 1
fi

# Debian and Ubuntu split venv out of the base python3 package, and the
# failure is otherwise a confusing traceback from ensurepip.
if ! "$PYTHON" -c 'import venv, ensurepip' 2>/dev/null; then
  echo "error: $PYTHON has no venv/ensurepip module" >&2
  echo "       on Debian/Ubuntu: sudo apt install python3-venv" >&2
  exit 1
fi

echo "Creating virtualenv in $VENV_DIR ($("$PYTHON" --version))"
"$PYTHON" -m venv "$VENV_DIR"

"$VENV_DIR/bin/python" -m pip install --quiet --upgrade pip
"$VENV_DIR/bin/python" -m pip install --quiet --upgrade -r requirements-dev.txt

echo
"$VENV_DIR/bin/python" -m pip list --format=columns

# html5validator only drives the Nu validator; the checker itself is Java.
if ! command -v java >/dev/null 2>&1; then
  echo
  echo "note: java not on PATH, so html5validator will not run." >&2
  echo "      on Debian/Ubuntu: sudo apt install default-jre-headless" >&2
fi

cat <<EOF

Done. Activate it with:

    source $VENV_DIR/bin/activate

Then the source checks are:

    ./lint.sh

and the built-site check, after \`jekyll build\`:

    html5validator --root _site
EOF
