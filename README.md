# fahimfarook.me

Personal profile website of Fahim Farook

## Prerequisites

Tested with:
- Java 25+
- Maven 3.9+

## Build

Generate the static site:

```bash
./mvnw jbake:generate
```

Output is written to `target/site/`.

## Serve Locally

Run a local dev server with live reload:

```bash
./mvnw jbake:inline -Djbake.port=8020

```
Then open [http://localhost:8820](http://localhost:8820) in the browser.

## Theme Switching

Two themes are available:

- **tufte** - Tufte-inspired, ET Book serif, warm off-white background, purple accents. This is based on my old [Jekyll blog's](https://fahimfarookme.gumroad.com/l/WDdYlR) theme. 
- **crimson** - My new theme - Crimson Pro serif, same purple blue accents, clean white

Switch themes by editing `src/main/jbake/jbake.properties`:

```properties
site.theme=tufte
# or
site.theme=crimson
```

## Adding a Blog Post

1. Create a new Markdown file in `src/main/jbake/content/blog/`:

```
title=Your Post Title
date=2026-04-01
type=post
tags=distributed-systems, architecture
status=published|draft
~~~~~~
Post content goes here in Markdown. I plan to add org-mode support when I find some time, insha Allah.
```

2. Rebuild: `./mvnw jbake:generate`

## Deployment (CI/CD)

CI/CD is via GitHub Actions + Cloudflare Pages. Follow [git-flow](https://nvie.com/posts/a-successful-git-branching-model/)

**Branches (Gitflow):**
- `develop` — integration branch. Push here triggers preview deploy.
- `master` — production. Only tagged releases deploy to production.
- `feature/*` — work branches, merged into develop via PR.

**Workflow:**
- PR merge to `develop` → deploys to preview: `https://develop.fahimfarookme.pages.dev`
- Merge `develop` to `master`, tag with `vYYYY.MM.DD` → deploys to `https://www.fahimfarook.me`


**Required GitHub Secrets:**
- `CLOUDFLARE_ACCOUNT_ID`
- `CLOUDFLARE_API_TOKEN`