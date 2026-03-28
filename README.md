# fahimfarook.me

Personal profile website for Fahim Farook, built with [JBake](https://jbake.org/) and Maven.

## Prerequisites

- Java 8+ (tested with Java 17+)
- Maven 3.6+ (Maven Wrapper included)

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
Then open [http://localhost:8820](http://localhost:8820) in your browser.

## Theme Switching

Two themes are available:

- **tufte** - Tufte-inspired, ET Book serif, warm off-white background, purple accents
- **crimson** - Crafting Interpreters-inspired, Crimson Pro serif, blue accents, clean white

Switch themes by editing `src/main/jbake/jbake.properties`:

```properties
site.theme=tufte
# or
site.theme=crimson
```

Then rebuild.

## Adding a Blog Post

1. Create a new Markdown file in `src/main/jbake/content/blog/`:

```
title=Your Post Title
date=2026-04-01
type=post
tags=distributed-systems, architecture
status=published
~~~~~~
Your post content here in Markdown.
```

2. Rebuild: `./mvnw jbake:generate`

## Deploy to Cloudflare Pages

1. Build: `./mvnw jbake:generate`
2. In Cloudflare Pages, set the output directory to the contents of `target/site/`
3. Or use `wrangler pages deploy target/site/`

## Project Structure

```
src/main/jbake/
├── assets/
│   ├── css/
│   │   ├── tufte.css          # Theme 1: Tufte-inspired
│   │   ├── crimson.css        # Theme 2: Crafting Interpreters-inspired
│   │   └── fonts.css          # ET Book font definitions
│   └── fonts/et-book/         # Self-hosted ET Book font files
├── content/
│   ├── index.md               # Home page
│   ├── profile.md             # Full profile/about page
│   ├── writing.md             # Blog listing (placeholder)
│   ├── contact.md             # Contact info
│   └── blog/                  # Future blog posts go here
└── templates/
    ├── page.ftl               # Standard page layout
    ├── index.ftl              # Home page layout (custom hero)
    ├── post.ftl               # Blog post layout
    ├── header.ftl             # <head> section (theme-aware)
    ├── footer.ftl             # Site footer
    └── menu.ftl               # Navigation
```
