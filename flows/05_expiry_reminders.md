# Flow 05: temporary-control expiry reminders

Every morning, lists temporary controls that expire within three days or already expired and posts one message to the RER channel plus one email to the Triage Lead. Replaces the single-column **Set a reminder** from build guide 01 with something that names the controls and the events.

**Verified on 2026-10-25 against:**
- Reminder flows: https://learn.microsoft.com/en-us/power-automate/create-sharepoint-reminder-flows
- SharePoint connector actions: https://learn.microsoft.com/en-us/connectors/sharepointonline/

Connectors: SharePoint, Microsoft Teams, Office 365 Outlook. All standard.

## Trigger
| Field | Value |
|---|---|
| Trigger | **Recurrence** |
| Interval | 1 Day, at [FILL: 07:00 local], time zone [FILL] |

## Steps
| # | Action | Connector | Settings |
|---|---|---|---|
| 1 | **Compose** `Cutoff` | Data Operation | `addDays(utcNow(), 3)` |
| 2 | **Get items** | SharePoint | List: RER_Controls. Filter Query: `Status ne 'Removed' and Expiry_Date le '<output of step 1>'`. Order By: `Expiry_Date asc`. Top Count: 100. |
| 3 | **Condition** | Control | `length(body('Get_items')?['value'])` is greater than 0 |
| 4 (yes) | **Select** | Data Operation | From: step 2 value. Map: `Log_ID`, `Event_ID`, `Control_ID`, `Expiry_Date` (formatted `formatDateTime(item()?['Expiry_Date'],'yyyy-MM-dd')`), `Status`, and `Days_Left` = `div(sub(ticks(item()?['Expiry_Date']), ticks(utcNow())), 864000000000)` |
| 5 (yes) | **Create HTML table** | Data Operation | From: step 4 output |
| 6 (yes) | **Post message in a chat or channel** | Microsoft Teams | Channel: [FILL: RER channel]. Message: `Temporary controls expiring within 3 days or expired:` followed by the HTML table and `Extend with documented approval or remove, then update RER_Controls.` |
| 7 (yes) | **Send an email (V2)** | Office 365 Outlook | To: [FILL: Triage Lead role mailbox]. Subject: `RER: <count> temporary controls need a decision`. Body: the HTML table. |
| 8 (no) | (nothing) | | No post on quiet days. |

## Failure handling
- If **Get items** fails, the run shows as failed in run history. Add a **Run after: has failed** email to the flow owner. No retry beyond default.
- If the list has more than 100 matching rows, raise Top Count; that situation is itself a finding for the AAR.

## Test
1. Set one EXAMPLE or DRILL control's Expiry_Date to yesterday and another to tomorrow. Run the flow manually (**Test > Manually**).
2. Expect a Teams post and an email listing both rows with negative and positive Days_Left.
3. Set both to 30 days out. Run again. Expect no post.

## Security notes
- Read-only against the list. Posts to one channel and one mailbox inside the tenant.
- Determinism: the filter is the rule. There is no judgment step.
