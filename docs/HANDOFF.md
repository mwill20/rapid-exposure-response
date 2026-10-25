# Handoff: from Claude chat to Claude Code

## Status (v0.4.0 published, M3 complete, roadmap M0 to M3 done)
v0.4.0 released 2026-10-25 automatically on the VERSION bump; release, guard and live updater jobs green; zip has 91 entries with a .docx for every spec, guide and drill file, checksum verified after download. M3 = Tier B: Copilot Studio agent spec, four flow specs, build guides 03 to 08, drills 2 and 3. Next: the owner runs guides 01, 02, 09 (Tier A) and then 03 to 08 (Tier B) at work and records drill scores in the org edition. Remaining repo work is the Later section of the roadmap (supply-chain hardening P1-4 first). Tenant facts verified from Microsoft Learn on 2026-10-25: Copilot Studio grounds on SharePoint sites and up to 10 lists per agent; tools can require end-user confirmation and run as the end user; agent flows must respond within 100 seconds with async off; Microsoft 365 Copilot licences zero-rate generative answers in Copilot and Teams while tools and flows may consume credits; Word Online (Business) is a premium connector; trigger payloads are a documented jailbreak surface. Nothing in M3 can be verified from here; guide 08 Part A is the acceptance test the owner runs.

## Status (v0.3.0 published, M2 complete)
Public repo: `github.com/mwill20/rapid-exposure-response`. v0.3.0 released 2026-10-25 automatically on the VERSION bump; release and live updater jobs green; zip has 60 entries including `lists/RER_Lists_Import.xlsx` with five tables and a .docx for every guide and drill file, checksum verified after download. M2 = Lists data model and import workbook, output schemas, rewritten agent instructions, build guides 00/01/02/09, drill 1 with answer key and scoring. Scope and sequencing live in `docs/ROADMAP.md`. Next: the owner runs guides 01, 02 and 09 at work and records the drill score in the org edition; then M3 (v0.4.0).

M2 acceptance that only the owner can complete: create the Lists from the import workbook, build the agent, run drill 1, score 16/20 with no critical misses. Tenant facts verified from Microsoft Learn on 2026-10-25 and recorded in the guides: one SharePoint list per Agent Builder agent, 100 SharePoint files, 8,000-character instructions, Restricted SharePoint Search blocks SharePoint knowledge, Lists from Excel up to 5,000 rows.

M1 acceptance: checker 100+ references resolve including DT-x and Sx; guard clean; updater tests green; the worked example cites DT-1 rows, a DT-2 row and the DT-4 class. The drill-1 answer key (M2) will be the first independent consistency check of the tables.

### Verified in GitHub Actions (2026-10-25)
- `guard` workflow green on the first push: leak guard, checker self-test, Windows job (PSScriptAnalyzer + Pester under PowerShell 5.1 and 7).
- `release` workflow green by `workflow_dispatch`: pandoc build on ubuntu-latest, release `v0.1.0` with `rer-kit-v0.1.0.zip` (33 entries, a .docx beside every .md, `tracker/RER_Tracker.xlsx`) and `SHA256SUMS.txt`; checksum verified independently after download.
- `verify-updater-live` job: `Get-RERUpdate.ps1` downloaded, verified and extracted v0.1.0 on windows-latest under PowerShell 5.1. P0-3 end-to-end acceptance met.
- Finding: the `paths: ['VERSION']` push trigger does **not** fire when the branch is created by the first push. Manual dispatch is the documented fallback and works. Confirmed on v0.2.0: a VERSION bump pushed to the existing `main` fires the release automatically; build, publish and the live updater job all passed. The v0.2.0 zip has 38 entries, a .docx beside every .md including `reports/` and `library/decision_tables`, checksum verified after download.

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
- Local build on the owner's Windows machine: pandoc, zip, openpyxl and pwsh are not installed, so `build.sh` runs only in CI.
- `work-side/Get-RERUpdate.ps1` on a real work device under the org's script policy (CI proves it on windows-latest only).
- Guard fail-closed branch (grep exit >= 2) is implemented but not exercised by a test.
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

### P0-1 Initialize and publish (DONE 2026-10-25)
- `git init -b main`, commit, `gh repo create mwill20/rapid-exposure-response --public --source=. --push` (ask before running).
- If a repo with that name already exists (possible partial create from the failed connector), stop and ask.
- Run `gh workflow run release` if the first push did not trigger it.
- **AC:** guard workflow green; release v0.1.0 contains `rer-kit-v0.1.0.zip` and `SHA256SUMS.txt`; zip contains tracker .xlsx and all .docx files.

### P0-2 Cross-reference checker (DONE 2026-10-25)
- `scripts/check_refs.py`: every referenced playbook Section number, CTL-xx, Vx, Hx, and Event Pack section exists. Fail with a clear message.
- Run it in guard.yml and in the pre-commit hook.
- **AC:** passes now; fails when a reference is broken in a test.

### P0-3 Validate the work-side updater (DONE 2026-10-25)
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
