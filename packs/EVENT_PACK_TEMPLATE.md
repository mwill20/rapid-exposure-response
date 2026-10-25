# RER Event Pack: [EVENT-ID] [Vulnerability name / CVEs]

> One Event Pack per vulnerability. Save the filled copy ONLY in your org workspace (e.g., `RER/org/events/`). Never commit a filled pack to GitHub.
>
> Markers: `[FILL: ...]` you complete. `[COPILOT: ...]` Copilot drafts with the RER-MAP prompt, a human verifies. Copilot must write UNKNOWN when the advisory or org documents do not say.
>
> Sections map to the playbook stages: A and B are S0, C is S1, D is S2, H is S3, E is S4, F is S5, G is S6, I is S7. Ask "RER-NEXT" at any time to get the current stage, what blocks exit, and the next three actions.

## Stage gates
| Stage | Exit criteria met? | Blocker | Exit artifact (link) |
|---|---|---|---|
| S0 Intake | [FILL: Y/N] | | Event row, sections A and B |
| S1 Triage | | | Event_Assets rows with grades and evidence |
| S2 Contain | | | Temp_Controls rows with verification evidence |
| S3 Communicate | | | Owner acknowledgments, first leadership update |
| S4 Remediate | | | Remediation_Status per asset |
| S5 Verify | | | Evidence_Link per asset, temporary controls retired |
| S6 Hunt | | | Outcome per hypothesis |
| S7 Close | | | AAR report in org SharePoint |

## A. Intake
| Field | Value |
|---|---|
| Event ID | [FILL] |
| Vulnerability / CVEs | [FILL] |
| Affected product and versions | [COPILOT: from advisory text only] |
| Fixed versions | [COPILOT: from advisory text only] |
| Vulnerability class (DT-2 wording: for example unauthenticated RCE over HTTP, auth bypass on edge device) | [COPILOT] |
| Attack preconditions (auth needed? feature enabled? network position?) | [COPILOT] |
| Exploitation status (none known / PoC public / exploited / KEV) | [COPILOT: cite source and date] |
| Sources and tiers (Playbook Section 4) | [FILL] |
| Declared at / Triage Lead | [FILL] |

## B. Trigger decision (Playbook Section 3)
- Trigger met? [COPILOT: which trigger, quote the playbook line]
- Lane: Prepare / Fire drill / Routine. [COPILOT: recommend with one-sentence reason]
- Human decision: [FILL: lane, who decided, time]

## C. Exposure (Stage S1, grades from DT-1)
Search terms for asset tools: [COPILOT: package names, binary names, service banners, file paths to search for, derived from the advisory]

Per asset, answer the DT-1 questions and record the row that produced the grade:

| Asset | Q1 run it | Q2 vuln version | Q3 internet, no auth | Q4 internal broad | Q5 feature enabled | Q6 segmentation verified | Q7 sensitive data | DT-1 row | Grade | Priority | Evidence |
|---|---|---|---|---|---|---|---|---|---|---|---|
| [FILL] | | | | | | | | [COPILOT] | [COPILOT] | [COPILOT] | [FILL: scanner, EDR, CMDB query] |

Embedded in vendor products or appliances? [COPILOT: candidates from vendor docs] Vendor confirmation: [FILL]

Exposure summary: E1 [FILL] / E2 [FILL] / E3 [FILL] / E4 [FILL] / Not affected [FILL]

Lane re-check: if no E1 or E2 remains, downgrade to Routine (Playbook Section 3) and record who decided.

## D. Compensating control plan (Stage S2, from DT-2 and DT-3)
DT-2 row used: [COPILOT: row number and class]. Modifiers that apply: [COPILOT]

| Control | Why it fits this vuln | What it does not cover | Tier | Evidence standard (DT-3) | Plain-language determination | Approver | Expiry |
|---|---|---|---|---|---|---|---|
| [COPILOT: candidate 1] | [COPILOT] | [COPILOT] | [COPILOT] | [COPILOT] | [COPILOT: fill the DT-2 template with control and asset] | [FILL] | [FILL] |
| [COPILOT: candidate 2] | [COPILOT] | [COPILOT] | [COPILOT] | [COPILOT] | [COPILOT] | [FILL] | [FILL] |
| CTL-05 Extra logging + detection | Always required when mitigations are partial | Detects, does not prevent | A | Alert from lab test reached a human | [COPILOT] | [FILL] | [FILL] |

Vendor-stated mitigations (quote the advisory, do not paraphrase config values): [COPILOT]

Rule: if the vendor says a mitigation is partial or no config-only fix exists, pair containment with detection and pull the patch timeline forward.

## E. Remediation plan (Stage S4)
| Item | Value |
|---|---|
| Target fixed version(s) | [COPILOT: from advisory] |
| Change type | [FILL: emergency / standard] |
| Patch order (by DT-1 priority, P1 first) | [COPILOT: from section C] |
| Dependencies or vendor actions needed | [FILL] |
| Target completion | [FILL: per Playbook Section 5] |

## F. Verification plan (Stage S5, evidence per DT-3)
| Check | Method | Evidence that counts | Done by | Result |
|---|---|---|---|---|
| V1 Fixed version present | [COPILOT: suggested method] | [COPILOT: from DT-3] | [FILL] | [FILL] |
| V2 Feature disabled (if CTL-02 used) | [COPILOT] | [COPILOT] | [FILL] | [FILL] |
| V3 Edge control blocks (if CTL-01 used) | [COPILOT] | [COPILOT] | [FILL] | [FILL] |
| V4 External reachability rescan | [FILL] | [COPILOT] | [FILL] | [FILL] |
| V5 Detection fires in lab | [FILL] | [COPILOT] | [FILL] | [FILL] |
| V6 Temporary controls removed or extended | [FILL] | [COPILOT] | [FILL] | [FILL] |
| V7 Evidence filed and linked | [FILL] | [COPILOT] | [FILL] | [FILL] |

## G. Retro-hunt plan (Stage S6, hypotheses from DT-4)
- Hunt window start (earliest of leak / pre-notice / PoC / disclosure, minus buffer): [COPILOT: earliest date found in sources] minus [FILL] days
- DT-4 class row: [COPILOT]
- Vendor or Tier 1 IOCs: [COPILOT: list with source; mark UNVERIFIED if Tier 2 or 3]

| Hypothesis | Required data present for the full window? | Outcome | Query / evidence link |
|---|---|---|---|
| [COPILOT: from DT-4] | [FILL: Y / N] | [FILL: No evidence / Insufficient data / Suspicious / Confirmed] | [FILL] |

Event Hunt_Result (worst outcome): [FILL]

## H. Communications (Stage S3)
- Owner notices drafted (Playbook 8.1): [COPILOT] / sent at [FILL] / all acknowledged or escalated at [FILL]
- Leadership update cadence and first update (8.2): [FILL]
- Compliance notified (if sensitive data and compromise not ruled out): [FILL: time, decision]

## I. Close-out (Stage S7)
- Closed at: [FILL]
- Metrics recorded in tracker: [FILL]
- AAR report (reports/AAR_REPORT_TEMPLATE.md) stored at: [FILL: org SharePoint link]
- Lessons and follow-ups: recorded in the AAR report, section 6. They stay in the org workspace.
