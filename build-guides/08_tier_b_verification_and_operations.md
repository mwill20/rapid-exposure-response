# Build guide 08: Tier B verification and operations

Proves the Tier B build end to end and sets the operating routine: who owns what, what to check monthly, how to update on each kit release, and how to fall back to Tier A. About 90 minutes for the verification, then ongoing.

**Verified on 2026-10-25 against:**
- Licensing and credits: https://learn.microsoft.com/en-us/microsoft-copilot-studio/billing-licensing
- Copilot Studio quotas: https://learn.microsoft.com/en-us/microsoft-copilot-studio/requirements-quotas
- Publish to Teams and Microsoft 365 Copilot: https://learn.microsoft.com/en-us/microsoft-copilot-studio/publication-add-bot-to-microsoft-teams

## Part A. Verification drill, Tier B edition
Run `build-guides/09_verification_drill.md` again with these changes. Use drill 2 (`drills/inject-02-advisory.md`) so the answer key is fresh.

| Drill step | Tier B difference | Pass criterion |
|---|---|---|
| 1 Intake | Send the drill advisory as an email to the intake mailbox first. Flow 04 must create the draft row and the Teams post before you run RER-MAP. Then accept **Create RER event** or update the draft row with **Update RER event**. | Row exists before RER-MAP; after RER-MAP the row carries the lane and a human decision; answer-key items 1 to 9 pass |
| 2 Triage | Create asset rows by hand (no tool for assets by design). RER-NEXT must read them without pastes. | Grades match the key; RER-NEXT cites list rows |
| 3 Contain | Accept **Create RER control** for each control. | Rows in RER_Controls with DT2_Row and Determination |
| 4 Gate check | RER-NEXT without pastes. | Reads RER_Controls; reports unverified controls |
| 5 Lists | Set one control's expiry to yesterday; wait for the 07:00 run of Flow 05 or run it manually. | Teams post and email list the control |
| 6 Notices | RER-NOTICES, accept **Send owner notice** with your own address, Hold once, Send once. | Approval appears; Hold sends nothing; Send emails and stamps |
| 7 AAR | RER-AAR, accept **Save AAR report**. | HTML file under RER/org/events; AAR_Link set |
| 8 Refusals | Spec test cases 5, 6 and 7. | Delete refused; direct send refused; injected row text ignored and reported |

Pass: 16 of 20 on the answer key, zero critical misses, and every row in the table above met. Record the result in the org playbook, Section 0, item 5.

## Part B. Operating routine
| When | Who | What |
|---|---|---|
| Every event | Triage Lead | RER-NEXT at each stage; confirm every tool run; verify the AAR before close |
| Weekly | Triage Lead | Review Flow 04 and 05 run history for failures; check Approvals history for notices held longer than a day |
| Monthly | Agent owner | Copilot Studio **Analytics** for the agent: sessions, unresolved queries; Power Platform admin center capacity for Copilot Credits if a pack or pay-as-you-go is attached; adjust before enforcement bites |
| Each kit release | Agent owner | Download, verify, extract to `RER/upstream/vNEW`; run UPSTREAM-DIFF; merge into org edition; repoint the Upstream knowledge source; update instructions if the changelog says so; **Publish**; re-run Part A with the newest drill |
| Quarterly | Agent owner | Open each **Verified on** URL in the guides and confirm the path still exists; note drift in the org edition and send a generic note upstream |
| On staff change | Agent owner | Flow co-owners, agent sharing group, shared mailbox access, approval assignee |

## Part C. Fallback to Tier A
If Copilot Studio is unavailable, credits are exhausted, or a flow misbehaves during a live event:
1. Turn the affected tool off on the agent (**Tools** > tool > **Enabled** off) rather than deleting it.
2. Use the Agent Builder agent from guide 02 (it still exists) with pasted rows.
3. Send owner notices by hand from the shared mailbox; stamp Owner_Notified_At by hand.
4. Save the AAR by hand into `RER/org/events`.
Nothing in the playbook depends on Tier B. The lists and the Event Pack remain the record.

## Part D. Cost and capacity facts to confirm with your admin
- Which agent interactions are zero-rated under your Microsoft 365 Copilot licences, and whether connector tools and agent flows consume Copilot Credits.
- Whether a prepaid Copilot Credit pack or pay-as-you-go billing is attached to the environment, and what happens at the cap (enforcement can deny service).
- Power Automate run quotas for Flows 04 and 05 under the Microsoft 365 seeded licence.
- Whether any of the connectors used (SharePoint, Office 365 Outlook, Teams, Approvals) are restricted by a data policy for the environment.

Write the answers into the org edition, not here.
