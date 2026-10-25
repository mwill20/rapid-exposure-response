# Build guides: read first

These guides stand up the RER kit inside a Microsoft 365 tenant. They are written to be followed **with Microsoft 365 Copilot as your walkthrough partner**, because that is the only AI tool available on the work side. Each guide is also a plain checklist you can follow alone.

## Order
| Guide | Builds | Needs |
|---|---|---|
| 01 SharePoint site and Lists | Restricted site, folders, five Lists, views, formatting, reminders | Site creation rights or an admin who has them |
| 02 Agent Builder quickstart | The RER Assistant agent (Tier A) | Microsoft 365 Copilot licence with Agent Builder |
| 09 Verification drill | Proof that 01 and 02 work, scored against an answer key | 01 and 02 done |
| 03 Copilot Studio agent | The Tier B agent: five lists as knowledge, confirm-before-run write tools, published to Microsoft 365 Copilot | Copilot Studio access, Dataverse entitlement |
| 04 KEV intake flow | A CISA KEV email becomes a draft event row and a Teams post | Shared mailbox, Power Automate |
| 05 Expiry reminder flow | Daily list of controls expiring or expired | Power Automate |
| 06 Notices with approval | The only send path, behind a Triage Lead approval | 03 done |
| 07 AAR report flow | Saves the agent's AAR draft into the org workspace | 03 done |
| 08 Tier B verification and operations | The Tier B drill, the operating routine, fallback to Tier A | 03 to 07 done |

## Before you start: tenant checks
Ask your M365 admin, or check yourself, and write the answers in your org edition (never here):
1. You hold a Microsoft 365 Copilot licence and **New agent** appears in the Copilot app left pane.
2. **Restricted SharePoint Search** is off. If it is on, SharePoint cannot be used as agent knowledge.
3. You can create a SharePoint site, or an admin will create one for you with you as owner.
4. **Lists > New list > From Excel** shows an **Upload file** button that is not greyed out.
5. Your software policy allows the updater script, or you will use the browser download path in the README.

## How to use a guide with Copilot
1. Download the latest release zip and extract it into `RER/upstream/vX.Y.Z` in the restricted site (README, "Use it at work"). The guides are in `build-guides/` as .docx.
2. Open Microsoft 365 Copilot (work mode) and paste the walkthrough prompt below, naming the guide.
3. Work one step at a time. Say `done` to advance, `stuck` to get the recovery prompt, `verify` to run the step's check.

Walkthrough prompt:
```text
You are walking me through RER build guide {NN} ({title}), stored in RER/upstream/{version}/build-guides. Read the guide. Present one step at a time in this order: Goal, Where, Do, Expect, Verify. Then wait. When I say "done", confirm the Verify line is satisfied and move to the next step. When I say "stuck", run that step's "If different" prompt. Do not skip steps, do not add steps, do not change any value in the guide. If a menu or button in the guide does not exist in my tenant, say so and use the "If different" prompt; do not guess a new path.
```

## Step format
Every step has six lines:
- **Goal**: what the step achieves.
- **Where**: the exact UI path, with the Microsoft page it was verified against and the date.
- **Do**: the clicks and the values to enter.
- **Expect**: what you see when it worked.
- **If different**: a prompt to paste into Copilot when the UI has moved. Copilot with web grounding can read Microsoft Learn; if web grounding is off, open the linked page yourself.
- **Verify**: a check you can perform, not a feeling.

Recovery prompt (used by every "If different" line):
```text
The RER build guide {NN} step {n} says: "{paste the Where and Do lines}". My tenant shows something else: {describe}. Using only Microsoft Learn or Microsoft Support pages, find the current path for the same action, quote the page title and URL, and give me the steps. If you cannot find it, say so.
```

## Guides age
Microsoft changes these products monthly. Each guide carries a **Verified on** date and the Learn or Support URLs the steps came from. A step older than a quarter deserves a quick check of its URL before you rely on it. Report a stale step as a generic note to the kit owner through the channel your organization uses for upstream feedback. Never include tenant names, URLs, or screenshots from your environment.

## What never goes into Copilot or into these guides
Credentials, tokens, patient data, personal data, internal hostnames or IP addresses. The guides use `[FILL]` where a value is yours; keep the filled copy in `RER/org`.
