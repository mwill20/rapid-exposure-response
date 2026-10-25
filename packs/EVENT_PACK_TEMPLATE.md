# RER Event Pack: [EVENT-ID] [Vulnerability name / CVEs]

> One Event Pack per vulnerability. Save the filled copy ONLY in your org workspace (e.g., `RER/org/events/`). Never commit a filled pack to GitHub.
>
> Markers: `[FILL: ...]` you complete. `[COPILOT: ...]` Copilot drafts with the RER-MAP prompt, a human verifies. Copilot must write UNKNOWN when the advisory or org documents do not say.

## A. Intake
| Field | Value |
|---|---|
| Event ID | [FILL] |
| Vulnerability / CVEs | [FILL] |
| Affected product and versions | [COPILOT: from advisory text only] |
| Fixed versions | [COPILOT: from advisory text only] |
| Vulnerability class (RCE, auth bypass, info disclosure...) | [COPILOT] |
| Attack preconditions (auth needed? feature enabled? network position?) | [COPILOT] |
| Exploitation status (none known / PoC public / exploited / KEV) | [COPILOT: cite source and date] |
| Sources and tiers (Playbook Section 4) | [FILL] |
| Declared at / Triage Lead | [FILL] |

## B. Trigger decision (Playbook Section 3)
- Trigger met? [COPILOT: which trigger, quote the playbook line]
- Lane: Prepare / Fire drill / Routine. [COPILOT: recommend with one-sentence reason]
- Human decision: [FILL: lane, who decided, time]

## C. Exposure questions (Playbook Step 2)
| Question | Answer | Evidence / source |
|---|---|---|
| Do we run it? Which systems, versions? | [FILL] | [FILL: scanner, EDR, CMDB query] |
| Embedded in vendor products or appliances? | [COPILOT: candidates from vendor docs] | [FILL: vendor confirmation] |
| Reachable? (internet / internal / segmented) | [FILL] | [FILL] |
| Vulnerable feature or config enabled? | [FILL] | [FILL] |
| Sensitive data on affected systems? | [FILL] | [FILL] |
| Signs of prior exploitation? | [FILL] | [FILL: hunt reference] |

Exposure summary: E1 [FILL] / E2 [FILL] / E3 [FILL] / E4 [FILL]

Search terms for asset tools: [COPILOT: package names, binary names, service banners, file paths to search for, derived from the advisory]

## D. Compensating control plan (library/controls.md)
| Control | Why it fits this vuln | Limits / partial? | Tier | Approver | Expiry |
|---|---|---|---|---|---|
| [COPILOT: candidate 1] | [COPILOT] | [COPILOT] | [COPILOT] | [FILL] | [FILL] |
| [COPILOT: candidate 2] | [COPILOT] | [COPILOT] | [COPILOT] | [FILL] | [FILL] |
| Extra logging + detection | Always required when mitigations are partial | | A | [FILL] | [FILL] |

Vendor-stated mitigations (quote the advisory, do not paraphrase config values): [COPILOT]

Rule: if the vendor says a mitigation is partial or no config-only fix exists, pair containment with detection and push the patch timeline.

## E. Remediation plan
| Item | Value |
|---|---|
| Target fixed version(s) | [COPILOT: from advisory] |
| Change type | [FILL: emergency / standard] |
| Patch order (E1 first) | [FILL] |
| Dependencies or vendor actions needed | [FILL] |
| Target completion | [FILL: per Playbook Section 5] |

## F. Verification plan (library/verification.md)
| Check | Method | Done by | Result |
|---|---|---|---|
| Fixed version present | [COPILOT: suggested method] | [FILL] | [FILL] |
| Control blocks benign test | [COPILOT] | [FILL] | [FILL] |
| External reachability rescan | [FILL] | [FILL] | [FILL] |
| Detection fires in lab | [FILL] | [FILL] | [FILL] |
| Temp controls removed or extended | [FILL] | [FILL] | [FILL] |

## G. Retro-hunt plan (library/hunts.md)
- Hunt window start (earliest of leak / pre-notice / PoC / disclosure, minus buffer): [COPILOT: earliest date found in sources] minus [FILL] days
- Hypotheses to run: [COPILOT: pick from library/hunts.md and explain fit]
- Vendor or Tier 1 IOCs: [COPILOT: list with source; mark UNVERIFIED if Tier 2/3]
- Result: [FILL: No evidence / Suspicious / Confirmed]

## H. Communications
- Owner notices drafted (Playbook 8.1): [COPILOT] / sent at [FILL]
- Leadership update cadence and first update (8.2): [FILL]
- Compliance notified (if sensitive data and compromise not ruled out): [FILL]

## I. Close-out
- Closed at: [FILL]
- Metrics recorded in tracker: [FILL]
- Top 3 lessons (generic wording, eligible to carry home from memory): [FILL]
