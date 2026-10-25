# Build guide 05: expiry reminder flow

Builds Flow 05 (`flows/05_expiry_reminders.md`): a daily list of temporary controls expiring within three days or already expired, posted to the RER channel and emailed to the Triage Lead. About 45 minutes.

**Verified on 2026-10-25 against:**
- SharePoint connector (Get items, filter queries): https://learn.microsoft.com/en-us/connectors/sharepointonline/
- Reminder flows background: https://learn.microsoft.com/en-us/power-automate/create-sharepoint-reminder-flows

## Step 1. Create a scheduled flow
- **Where:** https://make.powerautomate.com > **New flow** > **Scheduled cloud flow**.
- **Do:** name `RER 05 control expiry`, repeat every 1 Day at [FILL: 07:00], time zone [FILL]. **Create**.
- **Verify:** a Recurrence trigger with the schedule.

## Step 2. Compute the cutoff
- **Where:** **+** > Compose.
- **Do:** rename `Cutoff`, expression `addDays(utcNow(), 3)`.
- **Verify:** saved.

## Step 3. Get the controls
- **Where:** **+** > SharePoint **Get items**.
- **Do:** Site, List RER_Controls. Advanced: Filter Query `Status ne 'Removed' and Expiry_Date le '@{outputs('Cutoff')}'`, Order By `Expiry_Date asc`, Top Count 100.
- **Expect:** no error on save. Column internal names must match; if you renamed columns after creation, use the internal name shown in list settings.
- **If different:** if the filter errors on the date, wrap the cutoff with `formatDateTime(..., 'yyyy-MM-ddTHH:mm:ssZ')`.
- **Verify:** run **Test** manually once; the output shows the EXAMPLE or DRILL rows that match.

## Step 4. Condition and table
- **Where:** **+** > Control **Condition**; in the yes branch **Select** then **Create HTML table**.
- **Do:** Condition `length(body('Get_items')?['value'])` greater than 0. Select map and Days_Left expression from the spec step 4. Create HTML table from the Select output.
- **Verify:** the yes branch has two Data Operation cards.

## Step 5. Post and email
- **Where:** yes branch > **+** > Teams **Post message in a chat or channel**; then Office 365 Outlook **Send an email (V2)**.
- **Do:** values from the spec steps 6 and 7. Insert the HTML table output in both bodies.
- **Verify:** saved.

## Step 6. Test both outcomes
- **Do:** flow spec test: one control expired, one due tomorrow, run manually; then both far out, run again.
- **Expect:** post and email on the first run with negative and positive Days_Left; nothing on the second.
- **Verify:** run history shows both runs succeeded.

## Step 7. Retire the guide 01 reminder
- **Do:** in RER_Controls > Automate > Power Automate > See your flows, turn off the **Set a reminder** flow created in guide 01 step 9 so people get one message, not two.
- **Verify:** only `RER 05 control expiry` is on.

Record the flow in the org playbook, Section 0. Go to guide 06.
