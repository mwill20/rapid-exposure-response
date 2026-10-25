# Flow 06: owner notices with approval (agent flow tool)

The agent drafts the notice (RER-NOTICES). This flow queues it for the Triage Lead, sends it only on **Send**, and stamps the asset row. The agent cannot send; it can only call this flow, and the flow cannot send without a human.

**Verified on 2026-10-25 against:**
- Agent flow as a tool: https://learn.microsoft.com/en-us/microsoft-copilot-studio/advanced-flow-create
- Approvals: https://learn.microsoft.com/en-us/power-automate/modern-approvals

Connectors: Approvals, Office 365 Outlook, SharePoint. All standard.

## Why the response comes first
An agent flow must answer the agent within 100 seconds with asynchronous response off. An approval can take hours. So the flow responds immediately with "queued", and the approval, send and list update run after **Respond to the agent**, which may continue for up to 30 days.

## Trigger
| Field | Value |
|---|---|
| Trigger | **When an agent calls the flow** |
| Inputs | `EventId` (text), `AssetId` (text), `AssetItemId` (number, the RER_Assets list item ID), `OwnerEmail` (text), `Deadline` (text), `NoticeSubject` (text), `NoticeBody` (text, the RER-NOTICES draft including the determination sentence) |

## Steps
| # | Action | Connector | Settings |
|---|---|---|---|
| 1 | **Respond to the agent** | Agent flow | Output `Result` (text): `Notice for <AssetId> queued for Triage Lead approval. Nothing has been sent.` **Networking > Asynchronous response: Off.** |
| 2 | **Start and wait for an approval** | Approvals | Approval type: **Custom responses - Wait for one response**. Response options: `Send`, `Hold`. Title: `RER notice: <EventId> / <AssetId> to <OwnerEmail>`. Assigned to: [FILL: Triage Lead]. Details (Markdown): the NoticeSubject, the NoticeBody, the Deadline, and the line `Approve only if the control and determination match the Event Pack.` Item link: the RER_Assets item URL. |
| 3 | **Condition** | Control | `Outcome` is equal to `Send` |
| 4 (yes) | **Send an email (V2)** | Office 365 Outlook | To: OwnerEmail. Subject: NoticeSubject. Body: NoticeBody. From (Send as): [FILL: RER shared mailbox], so replies land in the intake mailbox. |
| 5 (yes) | **Update item** | SharePoint | List: RER_Assets. Id: AssetItemId. Owner_Notified_At: `utcNow()`. |
| 6 (no) | **Update item** | SharePoint | List: RER_Assets. Id: AssetItemId. Notes: append `Notice held by <Responder> on <date>: <Comments>`. |

## Failure handling
- If the approval times out (30 days), the flow ends; the asset row still shows no Owner_Notified_At, which RER-NEXT reports as an unmet criterion. That is the intended signal.
- If step 4 fails (bad address), add **Run after: has failed** to post to the RER channel: `Notice to <OwnerEmail> failed to send for <AssetId>.`

## Agent tool settings (Copilot Studio)
Name: `Send owner notice`. Ask the end user before running: **Yes**. Inputs: dynamically filled from the RER-NOTICES draft and the asset row; the agent must show OwnerEmail, Deadline and the body before running. Completion: **Send specific response** with the `Result` output.

## Test
1. In the agent, run RER-NOTICES for a drill asset with your own address as the owner. Accept the tool run.
2. Expect the agent to say "queued"; expect an approval in the Teams Approvals app and by email.
3. Choose **Hold**. Expect the asset Notes updated and no email.
4. Repeat and choose **Send**. Expect the email and Owner_Notified_At stamped.

## Security notes
- The only send path in the whole kit. Guarded by a named approver and logged in the Approvals history.
- Body text is drafted by the agent from the playbook template; the approver reads it in full before Send.
- Never add a group address as the approver; Approvals does not notify groups in Teams.
