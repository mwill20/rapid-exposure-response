# Flow 07: save the after-action report (agent flow tool)

Takes the RER-AAR draft from the agent and files it in the org workspace as an HTML document next to the Event Pack, then writes the link into the event row. Standard connectors only; the Word Online (Business) connector that fills .docx templates is premium and is offered as an optional upgrade at the end.

**Verified on 2026-10-25 against:**
- Agent flow as a tool: https://learn.microsoft.com/en-us/microsoft-copilot-studio/advanced-flow-create
- Word Online (Business) connector is Premium: https://learn.microsoft.com/en-us/connectors/wordonlinebusiness/

Connectors: SharePoint. Standard.

## Trigger
| Field | Value |
|---|---|
| Trigger | **When an agent calls the flow** |
| Inputs | `EventId` (text), `EventItemId` (number, the RER_Events item ID), `ReportHtml` (text, the full report as HTML with headings and tables) |

## Steps
| # | Action | Connector | Settings |
|---|---|---|---|
| 1 | **Compose** `FileName` | Data Operation | `concat(triggerBody()?['EventId'], '-AAR-', formatDateTime(utcNow(),'yyyyMMdd-HHmm'), '.html')` |
| 2 | **Compose** `Document` | Data Operation | `concat('<!doctype html><html><head><meta charset="utf-8"><title>', triggerBody()?['EventId'], ' after-action report</title></head><body>', triggerBody()?['ReportHtml'], '</body></html>')` |
| 3 | **Create file** | SharePoint | Site: RER site. Folder Path: `/Shared Documents/RER/org/events`. File Name: step 1. File Content: step 2. |
| 4 | **Update item** | SharePoint | List: RER_Events. Id: EventItemId. AAR_Link: the **Link to item** output of step 3. |
| 5 | **Respond to the agent** | Agent flow | Output `Result` (text): `AAR saved as <FileName> and linked on <EventId>. Open it, verify every line, then File > Save as .docx if you want a Word copy.` Asynchronous response: Off. |

The whole flow runs in a few seconds, so the response is last.

## Failure handling
- If step 3 fails (folder missing), respond with the error text so the agent reports it. Do not create the folder from the flow.
- Re-running produces a new timestamped file; the old one stays. The latest link wins in AAR_Link.

## Agent tool settings (Copilot Studio)
Name: `Save AAR report`. Ask the end user before running: **Yes**. The agent produces ReportHtml from the RER-AAR output: `h2` per section, `table` for the tables, no scripts, no external links other than the evidence index. Completion: **Send specific response** with `Result`.

## Test
1. Run RER-AAR for the drill event. Say yes to Save AAR report.
2. Expect a new .html file under `RER/org/events`, readable in the browser, and AAR_Link set on the event.
3. Open the file in Word (Open in Word from SharePoint) and Save as .docx to confirm the manual conversion path.

## Optional upgrade (premium)
If the organization licenses Power Automate Premium, replace steps 2 to 3 with **Word Online (Business) > Populate a Microsoft Word template** using a .docx built from `reports/AAR_REPORT_TEMPLATE.md` with content controls, then **Create file**. Keep the HTML path as fallback.

## Security notes
- The report is org data. The folder is inside the restricted site. Nothing leaves the tenant.
- The agent writes only what RER-AAR produced from the Event Pack, rows and thread; a human verifies before anyone relies on it (Playbook Section 11).
