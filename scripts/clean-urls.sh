#!/bin/sh
# clean-urls.sh — Production-only clean URL transform for Cloudflare Pages
#
# Strips .html from all internal href links in generated HTML files.
# Cloudflare Pages natively serves /page → page.html, so no directory
# restructuring is needed.
#
# Source files keep .html in hrefs so jbake:inline dev server works as-is.
# This script runs only during production builds (mvnw clean process-resources).
#
# Usage: ./scripts/clean-urls.sh [output-dir]
#   Default output-dir: target/site

set -e

SITE_DIR="${1:-target/site}"

if [ ! -d "$SITE_DIR" ]; then
    echo "Error: Site directory '$SITE_DIR' not found. Run jbake:generate first."
    exit 1
fi

echo "=== Clean URLs: stripping .html from href links ==="
find "$SITE_DIR" -name '*.html' -exec \
    sed -i 's|href="\(/[^"]*\)\.html"|href="\1"|g' {} +
echo "=== Done ==="
