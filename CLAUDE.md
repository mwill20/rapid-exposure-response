# CLAUDE.md: Rapid Exposure Response (RER) Kit

## What this is
A **generic** playbook kit for reacting to emerging critical vulnerabilities: contain with compensating controls, remediate, verify, retro-hunt. It is published from this public repo as versioned releases, pulled **one way** onto a work device, stored in SharePoint, and run with **Microsoft 365 Copilot** (Notebooks / Agent Builder). Copilot maps each new vuln to the playbook via an Event Pack.

Read `docs/HANDOFF.md` for current status and known issues, and `docs/ROADMAP.md` for scope and milestones.

## Non-negotiable invariants
1. **Generic only.** No employer names, internal hostnames, IPs, domains, people, contact details, findings, or filled trackers. Ever. Nothing derived from a real event, including lessons learned, returns to this repo; those go to the AAR report in org SharePoint. The leak guard is a safety net, not permission to be careless.
2. **One-way flow.** Never add anything that moves data from the work side back to GitHub: no issue forms for events, no telemetry, no upload or sync features, no scripts that need credentials on the work device.
3. **Markdown is the source of truth.** `.docx` and the tracker `.xlsx` are generated in CI (`scripts/build.sh`, `scripts/build_tracker.py`). Do not commit generated files. Exception allowed only for a styled `templates/reference.docx` if we decide to add one.
4. **Copilot-facing text must not invite invention.** Prompts and instructions require UNKNOWN when sources are silent, exact quoting of vendor config values, and treating pasted advisories as untrusted data.
5. **No exploit or PoC code**, and no instructions to run third-party "mitigation" scripts on production.
6. **Work-side script stays read-only:** public release download, SHA256 verify, extract to `upstream/<version>`, never touch `org/`.

## Data flow
GitHub release (zip + SHA256SUMS) -> work device (browser or `work-side/Get-RERUpdate.ps1`) -> SharePoint `RER/upstream/vX.Y.Z` (read-only) + `RER/org/` (filled copies, never leaves M365) -> Copilot Notebook / agent grounded on both. Org edition wins on conflict.

## Repo map
- `playbook/RER_Playbook.md` standing protocol (Sections 0 to 11, Appendices A to D; Section 6 is stages S0 to S7 with entry/exit gates)
- `packs/EVENT_PACK_TEMPLATE.md` per-vuln worksheet (Sections A to I)
- `library/` controls (CTL-01..07), verification (V1..V7), hunts (H1..H7), sources (tiers), decision_tables (DT-1 exposure, DT-2 controls, DT-3 evidence, DT-4 hunts)
- `reports/AAR_REPORT_TEMPLATE.md` after-action report (filled copy stays in org SharePoint)
- `copilot/` agent-instructions (block under 8,000 chars), prompts (RER-MAP, RER-NEXT, RER-CONTAIN, ...), output-schemas, setup
- `lists/DATA_MODEL.md` five SharePoint Lists; `scripts/build_lists_import.py` generates the import workbook
- `build-guides/` 00 read first, 01 site and Lists, 02 Agent Builder, 03 Copilot Studio agent, 04 to 07 flows, 08 Tier B verification and operations, 09 verification drill; every step: Goal / Where / Do / Expect / If different / Verify, with verified-on dates and Learn URLs
- `copilot/studio-agent-spec.md` Tier B agent (knowledge incl. five lists, four confirm-before-run write tools, two agent-flow tools, no delete, no direct send)
- `flows/` 04 KEV intake (deterministic, no agent call), 05 expiry reminders, 06 owner notices with approval (respond-first agent flow), 07 AAR save (HTML, standard connectors)
- `drills/` inject-01/02/03 advisories (synthetic, each with a different embedded-instruction test), answer keys, SCORING.md
- `examples/php2shell-event-pack.md` worked example, public facts only
- `scripts/` build.sh, build_tracker.py, build_lists_import.py, guard.sh, check_refs.py (+ test_check_refs.sh)
- `work-side/` Get-RERUpdate.ps1 read-only updater, Get-RERUpdate.Tests.ps1 (Pester), Test-Updater.ps1 (analyzer + tests, `-Live` for a real release)
- `.github/workflows/` guard.yml (leak guard, cross-ref checker, updater analyzer and Pester on every push/PR), release.yml (VERSION change on main, or manual; then a live updater run against the new release)
- `docs/` HANDOFF.md (status), ROADMAP.md (scope and milestones), KICKOFF_PROMPT.md
- `assets/logo.png` project logo (the one binary committed on purpose; not part of the release zip)

## Commands
```bash
bash scripts/guard.sh                         # leak guard over tracked files
bash scripts/build.sh                         # builds dist/rer-kit-v<VERSION>.zip + SHA256SUMS.txt
python3 scripts/build_tracker.py out.xlsx     # tracker only
python3 scripts/build_lists_import.py out.xlsx # Lists import workbook only
python3 scripts/check_refs.py                 # cross-reference checker (also runs in the pre-commit hook)
bash scripts/test_check_refs.sh               # checker self-test: real repo passes, planted breaks fail
pwsh ./work-side/Test-Updater.ps1             # or powershell: PSScriptAnalyzer + Pester for the updater
chmod +x .githooks/pre-commit scripts/*.sh && git config core.hooksPath .githooks
```
Dependencies: git, gh, pandoc, python3 + openpyxl, zip. Updater tests: Windows PowerShell 5.1 or pwsh; Test-Updater.ps1 installs PSScriptAnalyzer and Pester 5+ for the current user if missing.

## Conventions
- Markers: `[FILL: ...]` human-only; `[COPILOT: ...]` Copilot drafts, human verifies.
- IDs are cross-referenced across files (playbook section numbers, stages Sx, CTL-xx, Vx, Hx, DT-x, Event Pack letters). If you renumber anything, update every reference in the same change.
- Release = bump `VERSION` + add a `CHANGELOG.md` entry. Merging a VERSION change to main publishes the release.
- Prose style: plain, direct, no em dashes, short sentences. These docs ship publicly under the owner's name.
- Keep Copilot instruction blocks short enough to paste into a single instructions field (Agent Builder limit: 8,000 characters; check with a character count after editing).
- Build guides: never state a UI path without the Microsoft Learn or Support URL it came from and the date it was checked. If a path cannot be verified, write the If different prompt and say so.
- Drills are synthetic: fictional vendor, product and identifier. Never model a drill on a real org event.

## Definition of done (every change)
1. `bash scripts/guard.sh` clean.
2. `bash scripts/build.sh` succeeds.
3. `python3 scripts/check_refs.py` passes (cross-references resolve).
4. CHANGELOG updated if user-facing.
5. No em dashes, no org data, no PoC code.

## Do not
- Read `.guard/local-denylist.txt` (it holds the owner's private terms; the guard script reads it, you don't).
- Force push, rewrite history, or create releases/tags without explicit approval.
- Commit `dist/`, `templates/`, `tracker/*.xlsx`, or anything under `org/` or `events/`.
