#!/usr/bin/env bash
# Builds dist/rer-kit-<version>.zip: .md and .docx copies of every document, plus the generated tracker.
set -euo pipefail
VERSION="v$(cat VERSION)"
OUT="dist/kit"
rm -rf dist && mkdir -p "$OUT" templates
[ -f templates/reference.docx ] || pandoc -o templates/reference.docx --print-default-data-file reference.docx
for dir in playbook packs library copilot examples reports lists drills build-guides flows; do
  mkdir -p "$OUT/$dir"
  for f in "$dir"/*.md; do
    base="$(basename "$f" .md)"
    cp "$f" "$OUT/$dir/"
    pandoc "$f" -f gfm -t docx --reference-doc=templates/reference.docx -o "$OUT/$dir/$base.docx"
  done
done
mkdir -p "$OUT/tracker" "$OUT/work-side"
python3 scripts/build_tracker.py "$OUT/tracker/RER_Tracker.xlsx"
python3 scripts/build_lists_import.py "$OUT/lists/RER_Lists_Import.xlsx"
cp work-side/Get-RERUpdate.ps1 "$OUT/work-side/"
cp README.md SECURITY.md CHANGELOG.md HOW_TO_USE.md VERSION "$OUT/"
pandoc HOW_TO_USE.md -f gfm -t docx --reference-doc=templates/reference.docx -o "$OUT/HOW_TO_USE.docx"
(cd "$OUT" && zip -qr "../rer-kit-$VERSION.zip" .)
(cd dist && sha256sum "rer-kit-$VERSION.zip" > SHA256SUMS.txt)
echo "Built dist/rer-kit-$VERSION.zip"
