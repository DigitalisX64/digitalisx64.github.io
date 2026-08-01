# digitalisx64.github.io

Landing page for the [Digitalis](https://github.com/DigitalisX64) project — ARM64-to-x86_64 binary translation for Android.

## Local Preview

```bash
./serve.sh        # http://localhost:8000
./serve.sh 3000   # custom port
```

Uses Jekyll when it is installed. Without it, the last build in `_site` is
served instead — the sources cannot be served raw any more, since `index.html`
carries front matter for its latest-post highlight.

If you see `INotifyMaxWatchesExceeded`, the machine has run out of inotify
watches; `serve.sh` detects this and watches by polling instead, so the preview
still works. The limit is per user and shared with everything else running, so
an editor indexing a large checkout can consume all of it:

```bash
# who is holding them, and what the ceiling is
cat /proc/[0-9]*/fdinfo/* 2>/dev/null | grep -c '^inotify'
cat /proc/sys/fs/inotify/max_user_watches

# raise the ceiling for this boot
sudo sysctl fs.inotify.max_user_watches=524288

# ... and persistently
echo 'fs.inotify.max_user_watches=524288' | sudo tee /etc/sysctl.d/60-inotify.conf
```

The other half of the fix is to stop watching what does not need watching — in
VS Code, add the AOSP checkout to `files.watcherExclude`.

## Adding a Verified App

The apps page is generated from [`_data/apps.yml`](_data/apps.yml) — the page
itself contains no app data. Add an entry to the list matching its status:

```yaml
verified:
  - name: "Some App"
    package: com.example.someapp
    stack: "Unity (IL2CPP)"
    notes: >-      # optional; inline <code> and <em> are allowed
      What was fixed under translation, if anything worth recording.
```

Use `reason:` instead of `stack:` for a blocked app. The tables, the per-status
counts, and the search and filter controls all follow from the file, and a
status whose list is empty disappears from the page.

## Linting

```bash
pip install yamllint pymarkdownlnt pyyaml
./lint.sh
```

Checks YAML syntax, Markdown, and the app data against its schema — required
fields, a well-formed package id, no duplicate packages, `reason` only on
blocked apps, and no stray HTML tags in prose. CI runs the same script, then
builds the site and validates the generated HTML and CSS with `html5validator`.

## Writing a Post

Add one Markdown file under `_posts/`, named `YYYY-MM-DD-slug.md`:

```markdown
---
title: "The title, as it appears in the heading and the tab"
summary: "One line, shown under the title and on the blog index"
---

Body in Markdown. Raw HTML is fine where Markdown runs out — the
`.post-figure` class is styled for `<figure>`/`<img>`/`<figcaption>`.
```

That is the whole checklist. The layout, the date, the URL
(`/posts/slug/`) and the entry on [`/blog.html`](blog.html) all follow from
the file name and front matter; `summary` is optional and falls back to the
first paragraph. Layouts live in `_layouts/`, post styles in `style.css`
under `Blog: post list` and `Blog: single post`.

Nothing else needs editing. The post's date comes from the file name (override
it with a `date:` key in the front matter if you need a time of day), and both
the blog index and the "Latest post" strip on the home page read `site.posts`
directly — so the newest post appears in both places by itself.

One caveat that follows from that: **Jekyll hides posts dated in the future**
until that date arrives, and builds on GitHub's runners use UTC. A post dated
later today can therefore build locally and still be missing from the deployed
site. If a new post does not appear, check its date first.

The byline comes from `author:` in `_config.yml`. A post credited to someone
else overrides it in its own front matter:

```yaml
author:
  name: someone
  url: https://github.com/someone
```

## Deploy

Push to `android-latest-release` branch. GitHub Pages auto-deploys.
