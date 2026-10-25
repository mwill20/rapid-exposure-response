# Flow 04: KEV email intake

Turns a CISA Known Exploited Vulnerabilities alert email into a draft RER_Events row and a Teams notice. Deterministic: no AI step, no agent call. A human reads the row and runs RER-MAP. This is on purpose: Microsoft warns that trigger payloads can carry injected instructions, so the advisory text never enters the agent through automation.

**Verified on 2026-10-25 against:**
- Email triggers: https://learn.microsoft.com/en-us/power-automate/email-triggers
- Office 365 Outlook connector (shared mailbox trigger V2): https://learn.microsoft.com/en-us/connectors/office365/

Connectors: Office 365 Outlook, SharePoint, Microsoft Teams. All standard.

## Trigger
| Field | Value |
|---|---|
| Trigger | **When a new email arrives in a shared mailbox (V2)** (Office 365 Outlook). Use **When a new email arrives (V3)** if the alerts land in a personal mailbox. |
| Mailbox Address | [FILL: the RER intake shared mailbox] |
| Folder | Inbox, or the folder your mail rule routes KEV alerts to |
| From | [FILL: the exact CISA sender address shown on a received alert] |
| Subject Filter | [FILL: the constant part of the alert subject, for example the catalog name] |
| Include Attachments | No |

Filter in the trigger, not in a later condition, so non-matching mail does not consume runs. The account that owns the flow needs access to the shared mailbox; allow time for Exchange permissions to propagate.

## Steps
| # | Action | Connector | Settings |
|---|---|---|---|
| 1 | **Compose** `EventId` | Data Operation | `concat('EVT-', formatDateTime(utcNow(),'yyyy'), '-', formatDateTime(utcNow(),'MMdd-HHmm'))` (temporary ID; the Triage Lead renames to the next sequence number in S0) |
| 2 | **Create item** | SharePoint | Site: RER site. List: RER_Events. Event_ID: output of step 1. Name: email **Subject**. CVEs: `[FILL in S0]`. Source: `CISA KEV email`. Source_Tier: `Tier 1`. Lane: `Prepare`. Stage: `S0 Intake`. Blocker: `KEV alert received. Triage Lead: open the email, paste the advisory into RER-MAP, decide the lane.` Status: `Open`. Declared_At: `utcNow()`. Event_Pack_Link: blank. |
| 3 | **Post message in a chat or channel** | Microsoft Teams | Post as: Flow bot. Post in: Channel. Team and channel: [FILL: RER channel]. Message: `New KEV alert: <Subject>. Draft event <Event_ID> created in RER_Events. Triage Lead: run RER-MAP and set the lane. Link: <link to item>` |
| 4 | **Mark as read or unread (V3)** | Office 365 Outlook | Mark the triggering message as read |

## Failure handling
- If step 2 fails (list renamed, permission lost), configure **Run after** on step 3 to run on failure and post `Intake flow could not create the event row for <Subject>. Create it by hand.` Set the flow's **Retry policy** on step 2 to default.
- Duplicate alerts (CISA sends updates): the Triage Lead merges or closes the duplicate in S0. Do not try to deduplicate in the flow.

## Test
1. Send a test message to the shared mailbox from the configured sender with the subject pattern. Use the drill advisory text as the body.
2. Expect a new RER_Events row with Stage S0 Intake and a Teams post within two minutes.
3. Send a message with a different subject. Expect no run (check **28-day run history**).
4. Mark the drill row `DRILL` and close it after the test.

## Security notes
- The flow reads only the mailbox it is pointed at. It writes one list row and one Teams post. No data leaves the tenant.
- The email body is not copied into the list; only the subject. The Triage Lead reads the body in Outlook.
- Owner of the flow: the Triage Lead role account, not a personal account that leaves with its owner. Add a co-owner.
