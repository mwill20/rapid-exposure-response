# Handoff: from Claude chat to Claude Code

## Status (v0.1.0, M0 in progress)
Designed in a Claude chat session, imported into git on 2026-10-25 (baseline commit). Target: `github.com/mwill20/rapid-exposure-response`, **public** (decided: public keeps the work-side pull credential-free). Scope and sequencing live in `docs/ROADMAP.md`; this file holds status and known issues.

### Verified on the owner's machine (2026-10-25)
- `scripts/guard.sh` clean on the repo; planted hostname, private IP and non-example email blocked; a denylist term with regex metacharacters matches literally.
- `scripts/test_check_refs.sh`: 72 references resolve; eight planted breaks are each reported.
- `work-side/Test-Updater.ps1` under Windows PowerShell 5.1: PSScriptAnalyzer clean, 7 Pester tests pass (happy path, no-op, corrupted checksum, wrong file in sums, bad tag, wrong asset name, bad owner/repo).

### Verified in the chat sandbox
- `scripts/build.sh` builds the zip with .md + .docx for every doc and the generated tracker.
- `scripts/guard.sh` passes on the repo; a planted hostname, private IP, and non-example email were all blocked; `jane@example.org` passes.
- Tracker formulas recalculated with zero errors (lookups, hour deltas, overdue flags, metrics) on the original build.
- Event Pack .docx renders cleanly with pandoc's default reference doc.

### NOT verified (treat as untested)
- Local build on the owner's Windows machine: pandoc, zip, openpyxl and pwsh are not installed, so `build.sh` has only run in the sandbox.
- Any GitHub Actions run (guard.yml, release.yml have never executed).
- Whether the `paths: ['VERSION']` trigger fires on a brand-new repo's first push. `workflow_dispatch` is the fallback.
- `work-side/Get-RERUpdate.ps1` against a real release (the `verify-updater-live` job runs after the first publish). Mocked tests pass under 5.1; pwsh is not installed locally.
- Guard fail-closed branch (grep exit >= 2) is implemented but not exercised by a test.
- Pandoc version differences between the sandbox and ubuntu-latest.
- Real Copilot grounding behavior on the generated .docx files.

## Key decisions already made (do not relitigate without the owner)
- Public repo, generic content only, one-way flow.
- Upstream/org split in SharePoint; upstream never overwrites org.
- Text-only repo; CI generates binaries.
- Copilot Notebooks do not ground on .md, so releases ship .docx copies.
- The earlier idea of GitHub issue forms for events was **removed** because it breaks the one-way rule.
- Decided 2026-10-25: Lists are the system of record; one Copilot Studio agent with Agent Builder as quickstart; the agent never sends or deletes; every outbound message has a human approval step; nothing from a real event returns to this repo, lessons go to the AAR report in org SharePoint.

## Owner context (for judgment calls)
- Security engineer in a regulated healthcare environment (HIPAA / HITRUST / SOC 2). Expert in security; prefers concise, practical, security-first output.
- Work environment's only AI tool is M365 Copilot. Agent Builder supports up to 20 knowledge sources; agent/notebook availability depends on licensing.
- SIEM at work is Google SecOps; hunts stay SIEM-agnostic in the repo, translated queries live only in the org workspace.

## Backlog (prioritized)
Superseded by `docs/ROADMAP.md` for M1 onward. The P0 items below remain the M0 definition.

### P0-1 Initialize and publish
- `git init -b main`, commit, `gh repo create mwill20/rapid-exposure-response --public --source=. --push` (ask before running).
- If a repo with that name already exists (possible partial create from the failed connector), stop and ask.
- Run `gh workflow run release` if the first push did not trigger it.
- **AC:** guard workflow green; release v0.1.0 contains `rer-kit-v0.1.0.zip` and `SHA256SUMS.txt`; zip contains tracker .xlsx and all .docx files.

### P0-2 Cross-reference checker
- `scripts/check_refs.py`: every referenced playbook Section number, CTL-xx, Vx, Hx, and Event Pack section exists. Fail with a clear message.
- Run it in guard.yml and in the pre-commit hook.
- **AC:** passes now; fails when a reference is broken in a test.

### P0-3 Validate the work-side updater
- Add a `windows-latest` job running PSScriptAnalyzer on `Get-RERUpdate.ps1`.
- After P0-1, run a real download + checksum + extract test against the published release (in CI or locally with pwsh).
- **AC:** analyzer clean; end-to-end test succeeds; mismatch path tested (corrupted checksum fails).

### P1-4 Supply-chain hardening
- Pin all Actions to full commit SHAs; add Dependabot for github-actions.
- Add build provenance attestation to releases (e.g., `actions/attest-build-provenance`) and document `gh attestation verify` in README and SECURITY.md. This closes the gap that a same-release checksum cannot detect a compromised account.
- **AC:** release has an attestation; docs updated.

### P1-5 Style lint
- Add an em dash and long-line check for Markdown to guard.sh (or a separate lint step).
- **AC:** CI fails on an em dash in any .md.

### P1-6 Better .docx output
- Optional styled `templates/reference.docx` (Arial, bordered tables, marker highlighting via a pandoc Lua filter for `[FILL]` / `[COPILOT]`).
- **AC:** rendered playbook and Event Pack match the original design closely; tables readable.

### P2-7 Tracker polish
- Move dropdown lists to a hidden Lists sheet; add conditional formatting for OVERDUE / Due soon / E1.
- **AC:** formulas still evaluate; example row still demonstrates every column.

### P2-8 More worked examples
- One or two additional examples built only from public sources (different vuln classes, e.g., an edge-device auth bypass).

## Out of scope
- Anything that sends data from the work side to GitHub or any external service.
- Copilot Studio flows or automation inside the work tenant (possible v2, owner-led).
