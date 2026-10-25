#!/usr/bin/env bash
# Leak guard: fails if tracked files contain patterns that suggest org data.
# Usage: scripts/guard.sh [files...]   (defaults to all tracked text files)
set -uo pipefail
files=("$@")
if [ ${#files[@]} -eq 0 ]; then mapfile -t files < <(git ls-files 2>/dev/null || find . -type f -not -path './.git/*'); fi
patterns=(
  '\b10\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\b'
  '\b192\.168\.[0-9]{1,3}\.[0-9]{1,3}\b'
  '\b172\.(1[6-9]|2[0-9]|3[01])\.[0-9]{1,3}\.[0-9]{1,3}\b'
  '[A-Za-z0-9._%+-]+@(?!example\.(org|com))[A-Za-z0-9.-]+\.[A-Za-z]{2,}'
  '\b[a-z0-9-]+\.(corp|internal|local|lan)\b'
  '(AKIA|ASIA)[A-Z0-9]{16}'
  'ghp_[A-Za-z0-9]{36}'
  '-----BEGIN [A-Z ]*PRIVATE KEY-----'
)
if [ -f .guard/local-denylist.txt ]; then
  while IFS= read -r t; do [ -n "$t" ] && [[ "$t" != \#* ]] && patterns+=("(?i)\Q$t\E"); done < .guard/local-denylist.txt
fi
fail=0
for f in "${files[@]}"; do
  [ -f "$f" ] || continue
  case "$f" in *.xlsx|*.docx|*.zip|*.png|*.jpg) continue;; scripts/guard.sh|.guard/*|.gitignore|./.gitignore) continue;; esac
  for p in "${patterns[@]}"; do
    if grep -nP "$p" "$f" >/dev/null 2>&1; then echo "LEAK GUARD: pattern match in $f"; fail=1; fi
  done
done
[ $fail -eq 0 ] && echo "Leak guard: clean" || { echo "Commit blocked. Remove org data or adjust the pattern."; exit 1; }
