#!/usr/bin/env bash
# Builds the HTML and PDF versions of the book locally.
#
# Requirements:
#   macOS:  brew install pandoc && brew install --cask basictex
#   Linux:  sudo apt-get install -y pandoc texlive-xetex texlive-fonts-recommended
#
# Usage:
#   bash build.sh          # build both HTML and PDF
#   bash build.sh html     # build HTML only
#   bash build.sh pdf      # build PDF only

set -euo pipefail

# ── Config ─────────────────────────────────────────────────────────────────
OUT_DIR="dist"
METADATA="book/metadata.yml"
CSS="book/style.css"
HTML_OUT="$OUT_DIR/index.html"
PDF_OUT="$OUT_DIR/git-practice.pdf"

# Collect note files in numbered order (00 → 16)
FILES=( notes/[0-9][0-9]-*.md )

# ── Helpers ─────────────────────────────────────────────────────────────────
build_html() {
    echo "→ Building HTML..."
    pandoc "${FILES[@]}" \
        --metadata-file="$METADATA" \
        --standalone \
        --toc \
        --toc-depth=2 \
        --css="$CSS" \
        --highlight-style=tango \
        -o "$HTML_OUT"
    echo "  ✓ $HTML_OUT"
}

build_pdf() {
    echo "→ Building PDF..."
    pandoc "${FILES[@]}" \
        --metadata-file="$METADATA" \
        --toc \
        --toc-depth=2 \
        --pdf-engine=xelatex \
        --highlight-style=tango \
        -V geometry:margin=1in \
        -o "$PDF_OUT"
    echo "  ✓ $PDF_OUT"
}

# ── Main ────────────────────────────────────────────────────────────────────
mkdir -p "$OUT_DIR"

TARGET="${1:-all}"

case "$TARGET" in
    html) build_html ;;
    pdf)  build_pdf  ;;
    all)  build_html && build_pdf ;;
    *)
        echo "Usage: bash build.sh [html|pdf|all]"
        exit 1
        ;;
esac

echo "Done."
