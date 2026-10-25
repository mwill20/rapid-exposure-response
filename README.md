# Rapid Exposure Response (RER) Kit

A generic, reusable playbook kit for reacting to emerging critical vulnerabilities: **contain fast with compensating controls, remediate, verify, and hunt**. Built to be pulled one way into a work environment and run with Microsoft 365 Copilot.

> **One-way rule:** GitHub to work. Nothing from work ever comes back here. This repo holds templates only, never organization data.

## How it works

```
 [ This repo (generic) ]
          |  tagged release: rer-kit-vX.Y.Z.zip + SHA256SUMS.txt
          v
 [ Work device ]  download (browser or work-side/Get-RERUpdate.ps1)
          |  extract into a OneDrive/SharePoint-synced folder
          v
 [ SharePoint: RER/upstream/vX.Y.Z ]  read-only reference copy
          |
          v
 [ SharePoint: RER/org ]  your filled playbook, tracker, Event Packs
          |
          v
 [ M365 Copilot Notebook or agent ]  grounded on upstream + org
```

## What is in the kit

| Path | Purpose |
|---|---|
| `playbook/RER_Playbook.md` | The standing protocol (source of truth) |
| `packs/EVENT_PACK_TEMPLATE.md` | One per vulnerability: Copilot maps the advisory to the playbook |
| `library/controls.md` | Compensating controls with verification recipes |
| `library/verification.md` | How to prove a fix or control works |
| `library/hunts.md` | Retro-hunt hypotheses, SIEM-agnostic |
| `library/sources.md` | Trusted intel sources by tier |
| `copilot/` | Agent instructions, prompt pack, setup guide |
| `scripts/build_tracker.py` | Generates the tracker workbook (in every release zip) |
| `examples/php2shell-event-pack.md` | Worked example from public information |
| `work-side/Get-RERUpdate.ps1` | Optional read-only updater for the work device (tested with Pester, see `Test-Updater.ps1`) |
| `scripts/check_refs.py` | Cross-reference checker: every Section, CTL, V, H and Event Pack reference must exist |

Each release converts every Markdown file to `.docx`, because Copilot Notebooks ground on Office files and PDFs, not Markdown.

## Use it at work (no scripts required)

1. On the work device, open the repo's **Releases** page in a browser.
2. Download `rer-kit-vX.Y.Z.zip` and `SHA256SUMS.txt`.
3. Verify: `Get-FileHash .\rer-kit-vX.Y.Z.zip -Algorithm SHA256` and compare to the checksum file.
4. Extract into a synced folder such as `RER/upstream/vX.Y.Z` in a **restricted** SharePoint site.
5. First time only: copy the playbook and tracker into `RER/org/` and fill them in there.
6. Ground Copilot on both folders (see `copilot/setup.md`).
7. When a vulnerability drops: copy the Event Pack into `RER/org/events/` and run the **RER-MAP** prompt.

## Updating

1. Download the new release into `RER/upstream/vNEW` (keep the old version).
2. Read `CHANGELOG.md`.
3. Run the **UPSTREAM-DIFF** prompt so Copilot lists what to adopt into your org edition.
4. Merge by hand. Upstream never overwrites org files.

## Maintaining the repo (home side)

```bash
chmod +x .githooks/pre-commit scripts/*.sh
git config core.hooksPath .githooks    # enable the leak guard locally
cp .guard/local-denylist.example.txt .guard/local-denylist.txt   # add your private terms (gitignored)
# edit Markdown, bump VERSION, add CHANGELOG entry
bash scripts/guard.sh && python3 scripts/check_refs.py   # what the hook and CI run
git push origin main   # a VERSION change on main makes CI build and publish the release
```

## Security

See [SECURITY.md](SECURITY.md). Short version: generic content only, signed and checksummed releases, read-only consumption at work, and treat every advisory as untrusted data.

## Disclaimer

Generic guidance, not a substitute for your organization's policies, legal or compliance advice, or vendor instructions. Verify every control in your own environment.
