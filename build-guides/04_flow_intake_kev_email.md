# Build guide 04: KEV email intake flow

Builds Flow 04 (`flows/04_intake_kev_email.md`): a CISA KEV alert email creates a draft RER_Events row and a Teams post. No AI in this flow. About 45 minutes.

**Verified on 2026-10-25 against:**
- Email triggers: https://learn.microsoft.com/en-us/power-automate/email-triggers
- Office 365 Outlook connector: https://learn.microsoft.com/en-us/connectors/office365/

Inputs: the RER shared mailbox exists and your account has full access; one real KEV alert in that mailbox to copy the sender and subject pattern from; the RER Teams channel.

## Step 1. Create the flow
- **Goal:** an automated flow with the shared-mailbox trigger.
- **Where:** https://make.powerautomate.com > **My flows** > **New flow** > **Automated cloud flow**.
- **Do:** Flow name `RER 04 KEV intake`. Search triggers for `shared mailbox`. Select **When a new email arrives in a shared mailbox (V2)** (Office 365 Outlook). **Create**.
- **Expect:** the designer opens with the trigger card.
- **If different:** if the alerts land in a personal mailbox, use **When a new email arrives (V3)** instead; the rest is identical.
- **Verify:** the trigger card shows a Mailbox Address field.

## Step 2. Configure the trigger filters
- **Goal:** only KEV alerts start the flow, so runs are not wasted.
- **Where:** trigger card > **Advanced parameters** (new designer) or **Show advanced options** (classic).
- **Do:** Mailbox Address `[FILL]`. Folder: Inbox. From: the exact sender address from the real alert. Subject Filter: the constant subject fragment from the real alert. Include Attachments: No.
- **Expect:** fields saved.
- **If different:** recovery prompt from guide 00 with these lines.
- **Verify:** after step 6, a non-matching email produces no run.

## Step 3. Compose the temporary Event ID
- **Where:** **+** > search `Compose` (Data Operation).
- **Do:** rename to `EventId`. Inputs: the expression from the flow spec step 1.
- **Verify:** the expression saves without a red underline.

## Step 4. Create the RER_Events row
- **Where:** **+** > search `SharePoint Create item`.
- **Do:** Site Address: the RER site. List Name: RER_Events. Fill the columns exactly as the flow spec step 2 lists them: Event_ID from `EventId`, Name from the trigger's **Subject**, Source `CISA KEV email`, Source_Tier `Tier 1`, Lane `Prepare`, Stage `S0 Intake`, Blocker text from the spec, Status `Open`, Declared_At `utcNow()`.
- **Expect:** the choice fields show dropdowns with the values from guide 01.
- **If different:** if a choice value is rejected, the list's Choice values differ from `lists/DATA_MODEL.md`; fix the list, not the flow.
- **Verify:** no required field is empty.

## Step 5. Post to Teams and mark read
- **Where:** **+** > `Post message in a chat or channel` (Microsoft Teams); then **+** > `Mark as read or unread (V3)` (Office 365 Outlook).
- **Do:** Teams: Post as Flow bot, Post in Channel, the RER team and channel, message from the spec step 3 with the Subject, Event_ID and **Link to item** from step 4. Mark read: Message Id from the trigger, Mailbox Address as in step 2.
- **Verify:** both cards saved.

## Step 6. Failure path and ownership
- **Where:** Teams card > **Settings** > **Run after**; flow **Details** > **Owners**.
- **Do:** add a second Teams post card configured to run only if **Create item** **has failed**, with the spec's failure message. Add a co-owner from the RER roles. **Save**.
- **Verify:** the flow saves with no errors; two owners listed.

## Step 7. Test
- **Do:** follow the flow spec test: send a matching test email (use the drill advisory as the body), then a non-matching one.
- **Expect:** one row, one post, one run; the second email produces no run.
- **Verify:** 28-day run history shows exactly one successful run. Mark the row `DRILL` and close it.

Record the flow name and owners in the org playbook, Section 0. Go to guide 05.
