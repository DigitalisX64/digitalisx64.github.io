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

The byline comes from `author:` in `_config.yml`. A post credited to someone
else overrides it in its own front matter:

```yaml
author:
  name: someone
  url: https://github.com/someone
```

## Deploy

Push to `android-latest-release` branch. GitHub Pages auto-deploys.
