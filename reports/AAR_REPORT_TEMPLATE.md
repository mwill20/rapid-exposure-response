# After-action report: [EVENT-ID] [Vulnerability name / CVEs]

> Store the filled report ONLY in your org workspace (for example `RER/org/events/`). Nothing in it goes to GitHub or any external service. Copilot drafts it with the RER-AAR prompt from the Event Pack, the tracker rows, and the Teams thread. A human verifies every line.
>
> Audience: leadership and compliance first, engineers second. Plain language. One page if possible.

## 1. Summary
| Field | Value |
|---|---|
| Event ID / name | [FILL] |
| Lane and trigger | [COPILOT: from Event Pack B] |
| Declared / closed | [COPILOT: from tracker] |
| Exposure at peak | [COPILOT: counts by E1 / E2 / E3 / E4, and Not affected] |
| Outcome | [COPILOT: one sentence. Contained, remediated, verified; hunt result] |
| Sensitive data involved | [FILL: Y / N / Unknown, and the compliance decision] |

## 2. Timeline by stage
| Stage | Entered | Exit met | Hours from declaration | Blocker, if any |
|---|---|---|---|---|
| S0 Intake | [COPILOT] | [COPILOT] | [COPILOT] | |
| S1 Triage | | | | |
| S2 Contain | | | | |
| S3 Communicate | | | | |
| S4 Remediate | | | | |
| S5 Verify | | | | |
| S6 Hunt | | | | |
| S7 Close | | | | |

## 3. What we did
### Controls applied (Stage S2)
| Control | Scope | Determination (plain language) | Evidence | Retired on |
|---|---|---|---|---|
| [COPILOT: from Temp_Controls] | | [COPILOT: from DT-2 row] | [FILL: link] | |

### Remediation and verification (Stages S4 and S5)
- Assets patched: [COPILOT: count] of [COPILOT: count affected]. Exceptions: [FILL]
- Verification complete with evidence: [COPILOT: count]. Missing: [COPILOT: list]
- External rescan: [FILL: clean / findings]

### Retro-hunt (Stage S6)
| Hypothesis | Outcome | Data gap, if any |
|---|---|---|
| [COPILOT: from hunt log] | | |

## 4. Metrics against targets (Playbook Section 5)
| Milestone | Target | Actual | Met |
|---|---|---|---|
| Owners identified | | | |
| Exposure answered | | | |
| First control in place | | | |
| Fix applied and verified | | | |
| Retro-hunt complete | | | |

## 5. What worked, what did not
- Worked: [FILL]
- Did not: [FILL]
- Controls that failed or caused an outage: [FILL: none / details]

## 6. Lessons and follow-ups
Lessons stay in this report and the org edition. They do not go upstream.

| # | Lesson or gap | Follow-up action | Owner | Due |
|---|---|---|---|---|
| 1 | | | | |
| 2 | | | | |
| 3 | | | | |

Include every Insufficient data gap from the hunt and every owner or data source that could not be found quickly.

## 7. Evidence index
| Item | Link |
|---|---|
| Event Pack | |
| Tracker rows (Events, Event_Assets, Temp_Controls) | |
| Teams thread | |
| Change records | |
| Hunt queries and results | |

Approved by: [FILL: Triage Lead] on [FILL: date]
