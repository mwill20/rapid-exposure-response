#!/usr/bin/env bash
# Should-pass and should-fail tests for scripts/check_refs.py.
# 1. The real repo resolves.
# 2. A copy with planted broken references fails and names each one.
set -euo pipefail
cd "$(dirname "$0")/.."
PY="${PYTHON:-python3}"

echo "--- should pass: real repo"
"$PY" scripts/check_refs.py

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
for d in playbook packs library copilot examples reports lists drills build-guides tracker; do
  [ -d "$d" ] && mkdir -p "$tmp/$d" && cp -r "$d"/. "$tmp/$d/"
done
cp README.md SECURITY.md HOW_TO_USE.md "$tmp/"

cat >> "$tmp/examples/planted.md" <<'EOF'
# Planted breaks
Apply CTL-99 and check V9, then run H9 per Playbook Section 42 and Playbook Step 9.
See Appendix Z and Event Pack section Z, and sections A, Q and B. Grade with DT-9 at stage S9.
EOF

echo "--- should fail: planted breaks"
set +e
out="$("$PY" scripts/check_refs.py --root "$tmp" 2>&1)"
rc=$?
set -e
echo "$out"
[ "$rc" -eq 1 ] || { echo "FAIL: expected exit 1, got $rc"; exit 1; }
for needle in "unresolved CTL-99" "unresolved V9" "unresolved H9" "unresolved Section 42" \
              "unresolved Step 9" "unresolved Appendix Z" "unresolved Pack Z" "unresolved Pack Q" \
              "unresolved DT-9" "unresolved S9"; do
  grep -q "$needle" <<<"$out" || { echo "FAIL: missing '$needle'"; exit 1; }
done
# Valid letters in the same list must not be reported.
if grep -q "unresolved Pack A\|unresolved Pack B" <<<"$out"; then echo "FAIL: false positive on valid pack letters"; exit 1; fi
echo "check_refs tests: PASS"
