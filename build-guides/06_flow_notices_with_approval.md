# Build guide 06: owner notices with approval (agent flow)

Builds Flow 06 (`flows/06_owner_notices_with_approval.md`) as an agent flow and adds it to the Copilot Studio agent as the **Send owner notice** tool. This is the only path in the kit that sends anything, and it waits for a human. About one hour.

**Verified on 2026-10-25 against:**
- Create an agent flow as a tool: https://learn.microsoft.com/en-us/microsoft-copilot-studio/advanced-flow-create
- Approvals: https://learn.microsoft.com/en-us/power-automate/modern-approvals

Inputs: guide 03 complete; the RER shared mailbox (to send as); the Triage Lead address.

## Step 1. Create the agent flow from the agent
- **Where:** Copilot Studio > your agent > **Tools** > **Add a tool** > **New tool** > **Agent flow**.
- **Do:** the designer opens with **When an agent calls the flow** and **Respond to the agent** already present. Name the flow `RER 06 owner notice`.
- **Expect:** the two required cards.
- **If different:** use **Flows** (left pane) > **New flow** > **Agent flow**; the same template opens.
- **Verify:** the trigger card is **When an agent calls the flow**.

## Step 2. Define the inputs
- **Where:** trigger card > **Add an input**.
- **Do:** add the seven inputs from the flow spec with the types given (EventId, AssetId, AssetItemId as Number, OwnerEmail, Deadline, NoticeSubject, NoticeBody). Give each a one-line description; the agent uses it to fill the value.
- **Verify:** seven inputs listed.

## Step 3. Respond first
- **Where:** **Respond to the agent** card.
- **Do:** move it directly after the trigger. Add output `Result` (Text) with the queued message from the spec step 1. Open the card **Settings** > **Networking** > **Asynchronous response: Off**.
- **Expect:** the response card is second in the flow.
- **Verify:** Asynchronous response shows Off.

## Step 4. Approval
- **Where:** **+** after Respond > search `approval` > **Start and wait for an approval** (Standard approvals).
- **Do:** Approval type **Custom responses - Wait for one response**. Response options `Send` and `Hold`. Title, Assigned to, Details (Markdown) and Item link from the spec step 2.
- **Expect:** the card accepts the custom responses.
- **If different:** if custom responses are not offered, use **Approve/Reject - First to respond** and treat Approve as Send.
- **Verify:** Assigned to is a person, not a group.

## Step 5. Branch on the outcome
- **Where:** **+** > **Condition**: `Outcome` is equal to `Send`.
- **Do:** yes branch: **Send an email (V2)** to OwnerEmail with NoticeSubject and NoticeBody, **From (Send as)** the RER shared mailbox; then SharePoint **Update item** on RER_Assets (Id = AssetItemId) setting Owner_Notified_At `utcNow()`. No branch: **Update item** appending the hold note to Notes.
- **Verify:** both branches have an Update item card.

## Step 6. Publish the flow
- **Where:** **Publish** (top right of the flow designer).
- **Do:** Save, then Publish.
- **Expect:** published status.
- **Verify:** the flow appears under **Flows** as published.

## Step 7. Configure the tool on the agent
- **Where:** agent > **Tools** > the new tool (or **Add a tool** > **Flow** > select it > **Add and configure**).
- **Do:** Name `Send owner notice` (exact). Description from the spec. **Ask the end user before running: Yes**. Inputs: Dynamically fill with AI. Completion: **Send specific response** containing the `Result` output.
- **Verify:** the tool is enabled; the instructions' `/Send owner notice` reference resolves.

## Step 8. Test the whole path
- **Do:** flow spec test: RER-NOTICES for a drill asset with your own address as owner; accept; choose **Hold**; repeat and choose **Send**.
- **Expect:** "queued" response; approval in Teams Approvals app; Hold updates Notes and sends nothing; Send emails you from the shared mailbox and stamps Owner_Notified_At.
- **Verify:** both outcomes observed in run history and in the list.

Publish the agent again (guide 03 step 9) so the new tool is live. Go to guide 07.
