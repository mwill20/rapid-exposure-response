# Lists data model

Five SharePoint Lists are the system of record during an event. The generated workbook `lists/RER_Lists_Import.xlsx` (in every release zip) has one Excel table per list so each list is created with **Lists > New list > From Excel** (build guide 01). The RER Tracker workbook remains the offline fallback.

Verified against Microsoft Learn on 2026-10-25:
- Create a list from Excel: https://support.microsoft.com/en-us/office/create-a-list-based-on-a-spreadsheet-380cfeb5-6e14-438e-988a-c2b9bea574fa (tables up to 5,000 rows; column types are inferred from the data)
- Agent Builder knowledge limits: https://learn.microsoft.com/en-us/microsoft-365/copilot/extensibility/agent-builder-add-knowledge (one SharePoint list per agent; selecting a site does not include its lists)

## Grounding decision (Tier A)
Agent Builder grounds on **one** list. The RER Assistant uses **RER_Events** as that list, plus the `RER/org/events/` folder where each event's filled Event Pack (.docx) lives. The Event Pack is the per-event working document that carries asset grades, controls and hunt outcomes, so RER-NEXT reads the Event row and the Event Pack. Rows from the other four lists are pasted into prompts when needed (the prompts say so). Tier B (Copilot Studio) can ground on all five.

## Conventions
- The first column of every table becomes the list's **Title** column. Keep it as the natural key shown.
- Import infers types: dates become Date and time, numbers become Number, everything else Single line of text. After import, convert the columns marked **Choice** below (guide 01, step 5) and the ones marked **Multi** to Multiple lines of text.
- `Event_ID` format: `EVT-YYYY-NNN`. `Asset_ID`: your registry ID. `Log_ID`, `Hunt_ID`, `Evidence_ID`: `TC-`, `HT-`, `EV-` plus a number.
- Every list has an EXAMPLE row (first data row). Delete it after import; it exists so the importer infers the right types.
- Never store credentials, secrets, or patient data. The lists are an attack-surface map: restrict the site to RER roles.

## RER_Events (one row per event, the agent's grounded list)
| Column | Type | Values / notes |
|---|---|---|
| Event_ID (Title) | Text | EVT-YYYY-NNN |
| Name | Text | Vulnerability name |
| CVEs | Text | Comma separated |
| Source | Text | Advisory source |
| Source_Tier | Choice | Tier 1, Tier 2, Tier 3 |
| Lane | Choice | Prepare, Fire drill, Routine |
| Stage | Choice | S0 Intake, S1 Triage, S2 Contain, S3 Communicate, S4 Remediate, S5 Verify, S6 Hunt, S7 Closed |
| Blocker | Multi | What blocks exit of the current stage, in one line |
| Declared_At | Date and time | |
| Triage_Lead | Text (or Person) | |
| Owners_Identified_At | Date and time | |
| Exposure_Answered_At | Date and time | |
| First_Control_At | Date and time | |
| Fix_Verified_At | Date and time | |
| Hunt_Complete_At | Date and time | |
| Hunt_Result | Choice | Pending, No evidence, Insufficient data, Suspicious, Confirmed |
| Sensitive_Data_Impact | Choice | Y, N, Unknown |
| Compliance_Notified_At | Date and time | |
| Status | Choice | Open, Monitoring, Closed |
| Closed_At | Date and time | |
| Event_Pack_Link | Hyperlink | The filled Event Pack in RER/org/events |
| AAR_Link | Hyperlink | |
| Hrs_to_Owners | Calculated (Number) | `=ROUND(([Owners_Identified_At]-[Declared_At])*24,1)` |
| Hrs_to_Exposure | Calculated (Number) | `=ROUND(([Exposure_Answered_At]-[Declared_At])*24,1)` |
| Hrs_to_Control | Calculated (Number) | `=ROUND(([First_Control_At]-[Declared_At])*24,1)` |
| Hrs_to_Verified | Calculated (Number) | `=ROUND(([Fix_Verified_At]-[Declared_At])*24,1)` |

Calculated columns are added by hand after import (guide 01, step 6). Set the output type to Number. Calculated columns cannot use TODAY(), so anything that depends on "now" is done with column formatting instead.

## RER_Assets (one row per affected asset per event)
| Column | Type | Values / notes |
|---|---|---|
| Asset_Ref (Title) | Text | `EVT-YYYY-NNN / AST-NNN` |
| Event_ID | Text | |
| Asset_ID | Text | Registry ID |
| System_Name | Text | |
| Owner | Text (or Person) | |
| Version_Found | Text | |
| Q1_Runs_It | Choice | Y, N, Unknown |
| Q2_Vuln_Version | Choice | Y, N, Unknown |
| Q3_Internet_NoAuth | Choice | Y, N, Unknown |
| Q4_Internal_Broad | Choice | Y, N, Unknown |
| Q5_Feature_Enabled | Choice | Y, N, Unknown |
| Q6_Segmentation_Verified | Choice | Y, N, Unknown |
| Q7_Sensitive_Data | Choice | Y, N, Unknown |
| DT1_Row | Number | The DT-1 row that produced the grade |
| Grade | Choice | E1, E2, E3, E4, Not affected |
| Priority | Choice | P1, P2, P3, P4 |
| Owner_Notified_At | Date and time | |
| Owner_Ack_At | Date and time | |
| Remediation_Status | Choice | Not started, Control in place, Patched, Verified, Not affected, Exception |
| Verified_At | Date and time | |
| Evidence_Link | Hyperlink | |
| Notes | Multi | |

## RER_Controls (one row per temporary control)
| Column | Type | Values / notes |
|---|---|---|
| Log_ID (Title) | Text | TC-NNN |
| Event_ID | Text | |
| Asset_ID | Text | or `ALL` |
| Control_ID | Choice | CTL-01, CTL-02, CTL-03, CTL-04, CTL-05, CTL-06, CTL-07 |
| DT2_Row | Number | DT-2 row used |
| Determination | Multi | Plain-language determination from DT-2, filled in |
| Implemented_At | Date and time | |
| Implemented_By | Text | |
| Approved_By | Text | Per Playbook Section 2.1 |
| Rollback_Plan | Multi | |
| Expiry_Date | Date and time | Required |
| Status | Choice | Active, Extended, Removed |
| Verified | Choice | Y, N |
| Evidence_Link | Hyperlink | Must meet DT-3 |

## RER_Hunts (one row per hypothesis per event)
| Column | Type | Values / notes |
|---|---|---|
| Hunt_ID (Title) | Text | HT-NNN |
| Event_ID | Text | |
| Hypothesis | Choice | H1, H2, H3, H4, H5, H6, H7 |
| Required_Data | Text | From library/hunts.md |
| Data_Present_Full_Window | Choice | Y, N |
| Window_Start | Date and time | |
| Window_End | Date and time | |
| Outcome | Choice | Pending, No evidence, Insufficient data, Suspicious, Confirmed |
| Run_By | Text | |
| Run_At | Date and time | |
| Query_Link | Hyperlink | Saved search in the org SIEM workspace |
| Notes | Multi | |

## RER_Evidence (one row per artifact)
| Column | Type | Values / notes |
|---|---|---|
| Evidence_ID (Title) | Text | EV-NNN |
| Event_ID | Text | |
| Asset_ID | Text | or `ALL` |
| Item | Choice | CTL-01 to CTL-07, V1 to V7 |
| Standard_Met | Choice | Y, N |
| Captured_By | Text | |
| Captured_At | Date and time | |
| Link | Hyperlink | Where the artifact is stored |
| Notes | Multi | Why it meets or fails DT-3 |

## Views to create (guide 01, step 7)
| List | View | Filter and sort |
|---|---|---|
| RER_Events | Open by stage | Status is not Closed; group by Stage |
| RER_Assets | E1 not verified | Grade is E1 and Remediation_Status is not Verified and not Not affected; sort Priority |
| RER_Assets | Awaiting acknowledgment | Owner_Notified_At is not empty and Owner_Ack_At is empty |
| RER_Controls | Expiring or expired | Status is not Removed; sort Expiry_Date ascending |
| RER_Hunts | Gaps | Outcome is Insufficient data or Pending |

## Column formatting (guide 01, step 8)
Paste into **Column settings > Format this column > Advanced mode**. Reference: https://support.microsoft.com/en-us/office/format-a-column-to-change-how-it-looks-6ed2f787-0e9e-4908-b861-0d06571c256d. Test on the EXAMPLE row before deleting it.

Grade (RER_Assets):
```json
{
  "$schema": "https://developer.microsoft.com/json-schemas/sp/v2/column-formatting.schema.json",
  "elmType": "div",
  "txtContent": "@currentField",
  "style": { "padding": "0 6px", "border-radius": "4px", "font-weight": "600" },
  "attributes": {
    "class": "=if(@currentField == 'E1', 'sp-field-severity--blocked', if(@currentField == 'E2' || @currentField == 'E4', 'sp-field-severity--warning', if(@currentField == 'E3', 'sp-field-severity--low', 'sp-field-severity--good')))"
  }
}
```

Expiry_Date (RER_Controls), red when past, amber within 3 days, blank stays blank:
```json
{
  "$schema": "https://developer.microsoft.com/json-schemas/sp/v2/column-formatting.schema.json",
  "elmType": "div",
  "txtContent": "=if(@currentField == '', '', toLocaleDateString(@currentField))",
  "style": { "padding": "0 6px", "border-radius": "4px" },
  "attributes": {
    "class": "=if(@currentField == '', '', if(@currentField < @now, 'sp-field-severity--blocked', if(@currentField < @now + 259200000, 'sp-field-severity--warning', 'sp-field-severity--good')))"
  }
}
```
259200000 milliseconds is 3 days. Column formatting changes only how a value is shown; the stored value is unchanged.

## Reminders (guide 01, step 9)
- Expiry: on RER_Controls, **Automate > Set a reminder > Expiry_Date**, remind 3 days in advance. Reference: https://learn.microsoft.com/en-us/power-automate/create-sharepoint-reminder-flows
- Stage change notice: **Integrate > Rules > A column value changes** on RER_Events.Stage, notify the Triage Lead. Rules cannot notify a group address and do not work on multi-line columns. Reference: https://support.microsoft.com/en-us/sharepoint/lists/documents-and-library/create-a-rule-to-automate-a-list-or-library

## What is deliberately not here
- Registry and Owners stay in the tracker workbook or your CMDB. The lists hold event-time data only.
- No attachments. The Attachments column is not indexed for Copilot grounding; use Evidence_Link.
- No credentials, secrets or patient data, ever.
