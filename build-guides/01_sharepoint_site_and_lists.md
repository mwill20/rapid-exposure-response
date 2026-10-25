# Build guide 01: SharePoint site and Lists

Builds the restricted RER site, the folder layout, the five Lists from the import workbook, the views, the column formatting, and the reminders. About 90 minutes the first time.

**Verified on 2026-10-25 against:**
- Create a team or communication site: https://support.microsoft.com/en-us/office/create-a-team-or-communication-site-551e190a-8fbe-47ae-a88a-798b443c46b1
- Create a list based on a spreadsheet: https://support.microsoft.com/en-us/office/create-a-list-based-on-a-spreadsheet-380cfeb5-6e14-438e-988a-c2b9bea574fa
- Format a column: https://support.microsoft.com/en-us/office/format-a-column-to-change-how-it-looks-6ed2f787-0e9e-4908-b861-0d06571c256d
- Create a rule: https://support.microsoft.com/en-us/sharepoint/lists/documents-and-library/create-a-rule-to-automate-a-list-or-library
- Reminder flow: https://learn.microsoft.com/en-us/power-automate/create-sharepoint-reminder-flows

Inputs: the release zip extracted locally, `lists/RER_Lists_Import.xlsx` from it, `lists/DATA_MODEL.md` (the .docx copy is fine) open beside you.

## Step 1. Create the restricted site
- **Goal:** one SharePoint site that only RER roles can open. Copilot shows content to anyone who can access it, so the site boundary is the privacy boundary.
- **Where:** SharePoint start page > **Create site** (or the **Site** card under Build) > **Team site**. Support page: create a team or communication site.
- **Do:** Template **Standard team**. Name `[FILL: e.g., RER Command]`. Privacy **Private**. Sensitivity label `[FILL: your label for internal confidential]`. Add the RER roles as members, one backup owner.
- **Expect:** the new site opens with Documents and a Microsoft 365 group.
- **If different:** recovery prompt with these Where and Do lines. If **Create site** is missing, self-service site creation is off; ask your SharePoint admin to create a private team site with you as owner.
- **Verify:** open the site in a private browser window as a non-member test account, or ask a colleague outside RER to try. They must be denied.

## Step 2. Create the folder layout
- **Goal:** the upstream and org split from the README.
- **Where:** site > **Documents**.
- **Do:** create `RER/upstream/` and `RER/org/`, then `RER/org/events/` and `RER/org/evidence/`. Extract the release into `RER/upstream/vX.Y.Z/` (keep the version folder name). Copy the playbook and Event Pack .docx into `RER/org/` and rename them with an `_ORG` suffix.
- **Expect:** `RER/upstream/vX.Y.Z/playbook/RER_Playbook.docx` exists; `RER/org/RER_Playbook_ORG.docx` exists.
- **If different:** none needed; this is file management.
- **Verify:** `RER/upstream/vX.Y.Z/VERSION` opens and shows the version you downloaded.

## Step 3. Create the five Lists from the import workbook
- **Goal:** RER_Events, RER_Assets, RER_Controls, RER_Hunts, RER_Evidence, with the right column types inferred from the EXAMPLE row.
- **Where:** site > **New** > **List** > **From Excel**. Support page: create a list based on a spreadsheet.
- **Do:** **Upload file** > choose `RER_Lists_Import.xlsx`. Select the table `RER_Events`. Keep all columns. Confirm the first column is the Title column. Name the list `RER_Events`. **Save to** this site. **Create**. Repeat for the other four tables, one list each.
- **Expect:** five lists, each with one italic EXAMPLE row. Date columns show as dates, `DT1_Row` and `DT2_Row` as numbers.
- **If different:** if **Upload file** is greyed out you lack permission to create lists from spreadsheets; ask the site admin. If a date column imported as text, delete the list, open the workbook in Excel, confirm the cells are real dates (not text), and import again.
- **Verify:** on RER_Events, open the EXAMPLE row. `Declared_At` shows a date picker. On RER_Assets, `DT1_Row` is a number field.

## Step 4. Confirm the Title column mapping
- **Goal:** the natural key (`Event_ID`, `Asset_Ref`, `Log_ID`, `Hunt_ID`, `Evidence_ID`) is the Title column, so it is the link text everywhere.
- **Where:** each list > **Settings** (gear) > **List settings** > Columns.
- **Do:** if the importer created a separate `Title` column and a text column for the key, rename `Title` to the key name and move the key values into it, then delete the duplicate. On a fresh list this is one copy-paste in grid view.
- **Expect:** the first column in the default view is the key.
- **If different:** recovery prompt.
- **Verify:** clicking the EXAMPLE row's key opens the item.

## Step 5. Convert Choice columns
- **Goal:** fixed vocabularies so Copilot and humans use the same words.
- **Where:** list > column header > **Column settings** > **Edit** > change type to **Choice**.
- **Do:** for every column marked **Choice** in `DATA_MODEL.md`, set the type and enter the values exactly as listed. Turn off "Can add values manually". Repeat for columns marked **Multi**: type **Multiple lines of text**, plain text.
- **Expect:** the column shows a dropdown with the values.
- **If different:** if the editor will not change a text column to Choice, create a new Choice column with the same name plus `2`, copy the values in grid view, delete the old column, rename.
- **Verify:** on RER_Assets, `Grade` offers E1, E2, E3, E4, Not affected and nothing else.

## Step 6. Add the calculated hour columns on RER_Events
- **Goal:** response-time metrics without a spreadsheet.
- **Where:** RER_Events > **Add column** > **More** > **Calculated**.
- **Do:** create `Hrs_to_Owners`, `Hrs_to_Exposure`, `Hrs_to_Control`, `Hrs_to_Verified` with the formulas in `DATA_MODEL.md`. Data type returned: **Number**, 1 decimal.
- **Expect:** the EXAMPLE row shows 1.5, 5, 9 and 40.
- **If different:** if the formula errors, set the return type to Number first and retype the formula without the leading `=`. SharePoint calculated columns cannot use TODAY(); that is why "overdue" is done with formatting in step 8.
- **Verify:** the four numbers on the EXAMPLE row match 1.5, 5, 9, 40.

## Step 7. Create the views
- **Goal:** one view per gate question.
- **Where:** list > view switcher (top right) > **Create new view** > **List**.
- **Do:** create the five views in `DATA_MODEL.md` with the filters and sorts given. Make **Open by stage** the default view of RER_Events.
- **Expect:** each view appears in the switcher.
- **If different:** recovery prompt.
- **Verify:** RER_Controls **Expiring or expired** shows the EXAMPLE control.

## Step 8. Apply column formatting
- **Goal:** E1 and overdue controls are red at a glance.
- **Where:** column header > **Column settings** > **Format this column** > **Advanced mode**. Support page: format a column.
- **Do:** paste the `Grade` JSON from `DATA_MODEL.md` on RER_Assets and the `Expiry_Date` JSON on RER_Controls. **Save**.
- **Expect:** EXAMPLE asset `E1` is red; the EXAMPLE control expiry is green (30 days out).
- **If different:** if the pane shows a designer without Advanced mode, scroll to the bottom of the pane. If the JSON is rejected, paste it into Copilot with: "Validate this SharePoint column formatting JSON and show the corrected version without changing its logic."
- **Verify:** edit the EXAMPLE control's `Expiry_Date` to yesterday; it turns red. Set it back.

## Step 9. Reminders and rules
- **Goal:** a nudge before a temporary control expires, and a notice when an event changes stage.
- **Where:** RER_Controls > **Automate** > **Set a reminder** > `Expiry_Date`. RER_Events > **Integrate** > **Rules** > **Create a rule**. Pages: reminder flow; create a rule.
- **Do:** reminder: name `RER control expiry`, 3 days in advance, **Create**. Rule: **A column value changes** > column `Stage` > notify `[FILL: Triage Lead]`. Rules cannot notify a group address and cannot use multi-line columns.
- **Expect:** the reminder flow appears under Automate > Power Automate > See your flows; the rule appears under Manage rules.
- **If different:** if **Set a reminder** is missing, Power Automate may be unlicensed or blocked in your tenant; note it as a tenant gap and continue. Guide 05 (v0.4.0) replaces this with a proper flow.
- **Verify:** change the EXAMPLE event's Stage; the Triage Lead receives an email from the SharePoint Online no-reply address within a few minutes.

## Step 10. Permissions review
- **Goal:** only RER roles see the site; nobody outside can be added by accident.
- **Where:** site > **Settings** > **Site permissions**.
- **Do:** confirm members are RER roles only. Set **Site sharing** so only owners can share. Confirm the Microsoft 365 group is private.
- **Expect:** members list matches your Section 2 roles.
- **If different:** recovery prompt.
- **Verify:** the EXAMPLE rows are still present (you will delete them in guide 09 after the drill), and a non-member still cannot open the site.

Done. Record the site URL, list names and any tenant gaps in your org edition playbook, Section 0. Go to guide 02.
