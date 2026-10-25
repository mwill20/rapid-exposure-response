# Kickoff prompt for Claude Code

Paste this as your first message (plan mode recommended):

```text
You're taking over the RER Kit repo. Before doing anything:
1. Read CLAUDE.md and docs/HANDOFF.md completely.
2. Reply with: the 6 invariants in your own words, what is verified vs untested, and any risks you see.
3. Run `bash scripts/guard.sh` and `bash scripts/build.sh` and report results.
4. Propose a step-by-step plan for P0-1 through P0-3 with acceptance criteria.

Rules: ask before any git push, repo creation, tag, release, or workflow run. Never read .guard/local-denylist.txt. If a repo named mwill20/rapid-exposure-response already exists, stop and tell me.
```
