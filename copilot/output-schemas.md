# Output schemas

Every stage command returns a fixed table so the result pastes straight into a list (`lists/DATA_MODEL.md`) or an Event Pack section. Columns appear in this order, with these exact headers. Cells the sources do not support contain `UNKNOWN`. Cells only a human can fill contain `[FILL]`. No extra columns, no prose before the table except the one-line row citation the command asks for.

## RER-MAP (Stage S0)
Returns Event Pack sections A, B, C (search terms and the empty DT-1 grid), D, E, F, G as Markdown in the template's own structure, then this row for `RER_Events`:

| Event_ID | Name | CVEs | Source | Source_Tier | Lane | Stage | Blocker | Sensitive_Data_Impact | Status |
|---|---|---|---|---|---|---|---|---|---|
| [FILL] | from advisory | from advisory | from advisory | Tier n | recommended lane | S0 Intake | human lane decision pending | Unknown | Open |

Then: `Decisions in the next hour:` followed by exactly three bullets, each with an owner role.

## RER-NEXT (any stage)
| Field | Value |
|---|---|
| Event_ID | |
| Current stage | S0 to S7 with the gate question quoted from Playbook Section 6 |
| Exit criteria | one line per criterion: `met` or `not met`, then the evidence used |
| Blocker | one sentence, suitable for `RER_Events.Blocker` |
| Controls past expiry | Log_IDs or `none` |
| E1 assets without evidence | Asset_IDs or `none` |

Then `Next three actions:` as a table:

| # | Action | Owner role | Stage exit criterion it satisfies |
|---|---|---|---|

## RER-CONTAIN (Stage S2)
First line: `DT-2 row <n> (<class>, <grade>). Modifiers: <list or none>.` or `NO ROW`.

| Control_ID | Asset_ID | Why it fits | What it does not cover | Tier | Approver role | Evidence standard (DT-3) | Determination | Suggested expiry |
|---|---|---|---|---|---|---|---|---|

The Determination column is the DT-2 template with `{control}` and `{asset}` replaced by the control name and the system name. Rows paste into `RER_Controls` (Control_ID, Asset_ID, DT2_Row, Determination, Expiry_Date).

## RER-NOTICES (Stage S3)
One block per owner, each under 120 words, in Playbook 8.1 order: What, Why you, What we need, By when, How to confirm, Questions. The "What we need" line includes the Determination sentence for the control that affects that owner's system.

## RER-UPDATE (Stage S3)
Playbook 8.2 fields as a two-column table (Field, Value): Status, Exposure, Controls in place, Fix ETA, Evidence of compromise, Decisions needed. Then a table of exceptions:

| Type | ID | Detail |
|---|---|---|
| Control past expiry / E1 unverified / Hunt insufficient data | | |

## RER-VERIFY (Stage S5)
| Asset_ID | Missing check | Suggested method | Evidence that counts (DT-3) | Owner |
|---|---|---|---|---|

## RER-HUNT (Stage S6)
First line: `DT-4 row: <class>.`

| Hypothesis | Required_Data | Window_Start | Window_End | Data_Present_Full_Window | Outcome | Notes |
|---|---|---|---|---|---|---|

Outcome is `Pending` on creation. Rows paste into `RER_Hunts`.

## RER-AAR (Stage S7)
The `reports/AAR_REPORT_TEMPLATE.md` structure with every `[COPILOT]` marker filled or set to `UNKNOWN`, `[FILL]` markers left in place, and section 6 follow-ups as a table with Owner and Due columns.

## Rules that apply to every schema
- Dates in `yyyy-mm-dd hh:mm`, 24-hour, with the time zone named once above the table.
- IDs exactly as they appear in the lists. Never invent an ID; write `[FILL]`.
- Vendor config values quoted verbatim inside backticks.
- A grade, control or hypothesis is always followed by the table row that produced it, for example `(DT-1 row 4)`.
