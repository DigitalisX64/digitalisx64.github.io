# digitalisx64.github.io

Landing page for the [Digitalis](https://github.com/DigitalisX64) project — ARM64-to-x86_64 binary translation for Android.

## Local Preview

```bash
./serve.sh        # http://localhost:8000
./serve.sh 3000   # custom port
```

Uses Jekyll when it is installed, and falls back to a plain file server (which
serves `index.html` and `apps.html`, but not the blog).

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
