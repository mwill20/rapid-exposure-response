# CLAUDE.md: Rapid Exposure Response (RER) Kit

## What this is
A **generic** playbook kit for reacting to emerging critical vulnerabilities: contain with compensating controls, remediate, verify, retro-hunt. It is published from this public repo as versioned releases, pulled **one way** onto a work device, stored in SharePoint, and run with **Microsoft 365 Copilot** (Notebooks / Agent Builder). Copilot maps each new vuln to the playbook via an Event Pack.

Read `docs/HANDOFF.md` for current status, known issues, and the prioritized backlog.

## Non-negotiable invariants
1. **Generic only.** No employer names, internal hostnames, IPs, domains, people, contact details, findings, or filled trackers. Ever. The leak guard is a safety net, not permission to be careless.
2. **One-way flow.** Never add anything that moves data from the work side back to GitHub: no issue forms for events, no telemetry, no upload or sync features, no scripts that need credentials on the work device.
3. **Markdown is the source of truth.** `.docx` and the tracker `.xlsx` are generated in CI (`scripts/build.sh`, `scripts/build_tracker.py`). Do not commit generated files. Exception allowed only for a styled `templates/reference.docx` if we decide to add one.
4. **Copilot-facing text must not invite invention.** Prompts and instructions require UNKNOWN when sources are silent, exact quoting of vendor config values, and treating pasted advisories as untrusted data.
5. **No exploit or PoC code**, and no instructions to run third-party "mitigation" scripts on production.
6. **Work-side script stays read-only:** public release download, SHA256 verify, extract to `upstream/<version>`, never touch `org/`.

## Data flow
GitHub release (zip + SHA256SUMS) -> work device (browser or `work-side/Get-RERUpdate.ps1`) -> SharePoint `RER/upstream/vX.Y.Z` (read-only) + `RER/org/` (filled copies, never leaves M365) -> Copilot Notebook / agent grounded on both. Org edition wins on conflict.

## Repo map
- `playbook/RER_Playbook.md` standing protocol (Sections 0 to 11, Appendices A to D)
- `packs/EVENT_PACK_TEMPLATE.md` per-vuln worksheet (Sections A to I)
- `library/` controls (CTL-01..07), verification (V1..V7), hunts (H1..H6), sources (tiers)
- `copilot/` agent instructions, prompt pack (RER-MAP, UPSTREAM-DIFF, etc.), setup
- `examples/php2shell-event-pack.md` worked example, public facts only
- `scripts/` build.sh, build_tracker.py, guard.sh
- `work-side/Get-RERUpdate.ps1` read-only updater
- `.github/workflows/` guard.yml (every push/PR), release.yml (VERSION change on main, or manual)

## Commands
```bash
bash scripts/guard.sh                         # leak guard over tracked files
bash scripts/build.sh                         # builds dist/rer-kit-v<VERSION>.zip + SHA256SUMS.txt
python3 scripts/build_tracker.py out.xlsx     # tracker only
chmod +x .githooks/pre-commit scripts/*.sh && git config core.hooksPath .githooks
```
Dependencies: git, gh, pandoc, python3 + openpyxl, zip. Optional: pwsh (to test the updater).

## Conventions
- Markers: `[FILL: ...]` human-only; `[COPILOT: ...]` Copilot drafts, human verifies.
- IDs are cross-referenced across files (playbook section numbers, CTL-xx, Vx, Hx, Event Pack letters). If you renumber anything, update every reference in the same change.
- Release = bump `VERSION` + add a `CHANGELOG.md` entry. Merging a VERSION change to main publishes the release.
- Prose style: plain, direct, no em dashes, short sentences. These docs ship publicly under the owner's name.
- Keep Copilot instruction blocks short enough to paste into a single instructions field.

## Definition of done (every change)
1. `bash scripts/guard.sh` clean.
2. `bash scripts/build.sh` succeeds.
3. Cross-references still resolve.
4. CHANGELOG updated if user-facing.
5. No em dashes, no org data, no PoC code.

## Do not
- Read `.guard/local-denylist.txt` (it holds the owner's private terms; the guard script reads it, you don't).
- Force push, rewrite history, or create releases/tags without explicit approval.
- Commit `dist/`, `templates/`, `tracker/*.xlsx`, or anything under `org/` or `events/`.
