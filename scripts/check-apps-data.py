#!/usr/bin/env python3
"""Schema check for _data/apps.yml.

yamllint proves the file is YAML; this proves it is a usable app list, so a
malformed entry fails the pull request instead of silently rendering an empty
cell. Run it through ./lint.sh, or directly:

    python3 scripts/check-apps-data.py
"""

import re
import sys

try:
    import yaml
except ImportError:
    sys.exit("PyYAML is required: pip install pyyaml")

PATH = "_data/apps.yml"
STATUSES = ("verified", "partial", "blocked")
PACKAGE_RE = re.compile(r"^[a-zA-Z][\w]*(\.[a-zA-Z][\w]*)+$")
ALLOWED = {"name", "package", "stack", "reason", "notes"}

# Inline HTML is allowed in prose, but only these tags — anything else is
# either a typo or markup the page's styles do not cover.
TAG_RE = re.compile(r"</?([a-zA-Z][a-zA-Z0-9]*)\b")
ALLOWED_TAGS = {"code", "em", "strong", "b", "i", "small"}


def main() -> int:
    with open(PATH, encoding="utf-8") as handle:
        data = yaml.safe_load(handle)

    errors = []
    seen_packages = {}
    total = 0

    if not isinstance(data, dict):
        return fail([f"{PATH}: top level must be a mapping of status -> list"])

    for status in data:
        if status not in STATUSES:
            errors.append(f"unknown status '{status}' (expected {', '.join(STATUSES)})")

    for status in STATUSES:
        apps = data.get(status)
        if apps is None:
            errors.append(f"missing status list '{status}' (use [] when empty)")
            continue
        if not isinstance(apps, list):
            errors.append(f"'{status}' must be a list")
            continue

        for index, app in enumerate(apps):
            where = f"{status}[{index}]"
            if not isinstance(app, dict):
                errors.append(f"{where}: entry must be a mapping")
                continue

            name = app.get("name")
            if not name:
                errors.append(f"{where}: missing 'name'")
            where = f"{status}[{index}] '{name}'"

            package = app.get("package")
            if not package:
                errors.append(f"{where}: missing 'package'")
            elif not PACKAGE_RE.match(str(package)):
                errors.append(f"{where}: '{package}' is not an Android package id")
            elif package in seen_packages:
                errors.append(f"{where}: package already listed under {seen_packages[package]}")
            else:
                seen_packages[package] = status

            unknown = set(app) - ALLOWED
            if unknown:
                errors.append(f"{where}: unknown field(s) {', '.join(sorted(unknown))}")

            # The third column has to say something.
            if not (app.get("stack") or app.get("reason") or app.get("notes")):
                errors.append(f"{where}: needs a 'stack', 'reason' or 'notes'")

            if status == "blocked" and app.get("stack"):
                errors.append(f"{where}: blocked apps describe why in 'reason', not 'stack'")
            if status != "blocked" and app.get("reason"):
                errors.append(f"{where}: 'reason' is for blocked apps; use 'stack'")

            for field in ("stack", "reason", "notes"):
                value = app.get(field)
                if value is None:
                    continue
                for tag in TAG_RE.findall(str(value)):
                    if tag.lower() not in ALLOWED_TAGS:
                        errors.append(f"{where}: <{tag}> not allowed in '{field}'")
            total += 1

    if errors:
        return fail(errors)

    counts = ", ".join(f"{len(data.get(s) or [])} {s}" for s in STATUSES)
    print(f"{PATH}: {total} apps ({counts})")
    return 0


def fail(errors) -> int:
    print(f"{PATH}: {len(errors)} problem(s)", file=sys.stderr)
    for error in errors:
        print(f"  {error}", file=sys.stderr)
    return 1


if __name__ == "__main__":
    sys.exit(main())
