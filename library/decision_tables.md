# Decision tables

These tables make the security decisions deterministic. Copilot cites a row. It does not reason its way to a grade, a control, or a hunt. A human approves every control (Playbook Section 2.1) and attaches the evidence.

Rules for every table:
- **First matching row wins.** Read top to bottom.
- **No row fits:** answer NO ROW and hand the decision to the Triage Lead. Never improvise.
- **Unknown is an answer.** An Unknown input selects the Unknown row; it never selects the safer-looking row.
- Rows are generic. Add org-specific rows to the org edition only.

## DT-1 Exposure rubric (per asset, Stage S1)

Inputs are the S1 questions. Answer each Y, N, or Unknown, with the evidence source beside it.

| Q | Question | Evidence that answers it |
|---|---|---|
| Q1 | Do we run the affected product or component on this asset? | CMDB, EDR software inventory, container image scan |
| Q2 | Is the installed version inside the affected range? | Authenticated scan, package query, vendor appliance version page (V1 method) |
| Q3 | Reachable from the internet without authentication? | External attack surface scan, load balancer and firewall config |
| Q4 | Broadly reachable from the internal network? | Firewall rules, network scan from a user segment |
| Q5 | Is the vulnerable feature, module, or configuration enabled? | Effective runtime config readback (V2 method), not the config file |
| Q6 | Are segmentation or access controls verified for this asset? | Connectivity test from representative segments |
| Q7 | Does the asset store or process sensitive data (for example ePHI, PII)? | Data classification, registry Data_Sensitivity |

| Row | Condition | Grade | Note |
|---|---|---|---|
| 1 | Q1 = N, confirmed by inventory and scan | Not affected | Record the query output. Close the asset row. |
| 2 | Q2 = N, version at or above the fixed version, confirmed by the V1 method | Not affected | Record the version string and method. |
| 3 | Q1 or Q2 = Unknown | E4 | Treat as E2 until proven. Orphan assets (no owner) are at least E2 (Playbook Section 2.1). |
| 4 | Q3 = Y and Q5 = Y or Unknown | E1 | Highest urgency. Start S6 hunt now. |
| 5 | Q3 = Y and Q5 = N, confirmed by runtime readback | E2 | Config can drift. Re-read the runtime config daily until S5 Verified. |
| 6 | Q3 = N and Q4 = Y | E2 | |
| 7 | Q3 = N, Q4 = N, Q6 = Y | E3 | Verified segmentation. Still patch within the E2 target. |
| 8 | Q3 = N, Q4 = N, Q6 = N or Unknown | E2 | Unverified segmentation counts as broad reach. |

Priority for patch order and notices (after the grade):

| Priority | Condition |
|---|---|
| P1 | E1 with Q7 = Y, or E1 with confirmed exploitation or KEV listing |
| P2 | Any other E1, or E2 with Q7 = Y |
| P3 | Any other E2 or E4 |
| P4 | E3 |

## DT-2 Control selection matrix (Stage S2)

Pick the row by vulnerability class and the asset's grade. Controls are listed in the order to try. The approver in Playbook Section 2.1 decides. Every control carries its evidence standard from DT-3 and the plain-language determination below, which Copilot completes with the control name and scope.

| Row | Vulnerability class | Grade | Controls in order | Partial? | Plain-language determination (template) |
|---|---|---|---|---|---|
| 1 | Unauthenticated remote code execution over HTTP or HTTPS (web app, framework, language runtime) | E1 | CTL-01 if a Tier 1 or Tier 2 source published request indicators; CTL-02 if the vendor names a feature-level mitigation; CTL-05 always; CTL-03 if the service has a known audience; CTL-07 if exploited, no patch, and nothing else is sufficient | CTL-01 and CTL-02 are usually partial | "{control} stops known exploit requests before they reach {asset}. It does not stop variants or traffic that avoids the edge, so detection stays on and the patch date stands." |
| 2 | Same class as row 1 | E2, E4 | CTL-03 to the sources that need the service; CTL-02 if available; CTL-05 always | CTL-03 does not stop an attacker already inside the allowed group | "{control} limits who can reach {asset} to the systems that need it. Anyone already inside that group is not stopped, so detection stays on." |
| 3 | Authentication bypass or hard-coded credential on an edge, identity, or management interface (VPN, firewall, SSO, admin console) | E1, E2 | CTL-03 management interface to the admin network or VPN only; CTL-06 rotate credentials and sessions if the interface was exposed during the exploitation window; CTL-05 always; CTL-07 if KEV-listed, internet-exposed management plane, and no patch | CTL-03 leaves the user-facing side open if the flaw is on it | "{control} removes {asset}'s management interface from reach of the internet. If the flaw is on the user-facing side, this does not cover it, which is why the patch is still urgent." |
| 4 | Code execution or injection that requires an authenticated user (post-auth RCE, deserialization, template injection) | E1, E2 | CTL-03 restrict to required accounts and enforce MFA; CTL-02 disable the affected endpoint or module; CTL-05 always | Yes, a valid account still works | "{control} reduces the number of accounts that could trigger the flaw on {asset}. A compromised allowed account is not stopped." |
| 5 | Information disclosure, memory leak, or credential exposure | E1, E2 | CTL-01 if request indicators are published; CTL-06 rotate any secret the affected process could read; CTL-05 always | Yes | "{control} limits what someone who already read data from {asset} can do with it. It does not stop the read itself, so the patch stays urgent." |
| 6 | Local privilege escalation or post-compromise flaw (needs a foothold first) | Any | CTL-05 with endpoint detections for the escalation path; CTL-03 restrict interactive logon to the affected hosts | Detect only | "{control} alerts us if someone tries the escalation on {asset}. It does not prevent it. The patch is the fix." |
| 7 | Server-side request forgery in an internet-facing service | E1 | CTL-03 outbound allowlist from the affected host (block cloud metadata and internal ranges); CTL-01 if request indicators are published; CTL-05 always | Yes | "{control} stops {asset} from reaching internal systems or cloud metadata on an attacker's behalf. Requests to allowed destinations still work, so the patch date stands." |
| 8 | Denial of service or crash only, no code execution | E1 | CTL-01 rate limit or pattern block; CTL-05 for error and crash spikes | Yes | "{control} reduces how often {asset} can be crashed from outside. It does not remove the flaw." |
| 9 | Component embedded in a vendor appliance or SaaS that we cannot patch ourselves | Any | CTL-03 or CTL-04 until the vendor ships a fix; CTL-05 always; open a vendor ticket and record the vendor's stated mitigation verbatim | Yes | "{control} keeps {asset} reachable only by the systems that need it until the vendor fixes it. We cannot change the vulnerable component ourselves." |

Modifiers. Apply every one that matches, after the row:

| Modifier | Effect |
|---|---|
| Vendor states the mitigation is partial, or no configuration-only fix exists | CTL-05 is mandatory. Pull the patch target forward. Say "partial" in the determination. |
| No fix available | Add CTL-03 or CTL-04. Set a review date. For E1 with exploitation, put CTL-07 in front of the approver. |
| Exploited in the wild or KEV-listed | Start S6 hunt immediately. Add CTL-06 if the asset was reachable before controls were in place. |
| Asset holds sensitive data (Q7 = Y) | Notify the Compliance / Privacy Liaison in S3. Consider CTL-06. |
| Asset is clinical, safety-related, or Tier C | CTL-04 and CTL-07 need Tier C approval. Try CTL-01 and CTL-03 first. |

## DT-3 Evidence standards (Stages S2 and S5)

An artifact counts only if it shows **what** (rule ID, hostname, or asset ID), **when** (timestamp), and **who** captured it, and it is stored at the evidence location and linked in the tracker's Evidence_Link column.

| Item | Counts as proof | Does not count |
|---|---|---|
| CTL-01 | Rule export or screenshot showing rule ID, mode = block, deploy time; plus the benign test request, the block response, and the matching log line (V3) | "Rule is on" in chat; a rule in log-only mode |
| CTL-02 | Effective runtime configuration readback from each host showing the setting (V2); the change record | The config file contents alone; a vendor KB link |
| CTL-03 | Rule export; test from an allowed location (works) and a disallowed location (blocked) | One test from one side |
| CTL-04 | Change record; connectivity test matrix from representative segments | A network diagram |
| CTL-05 | Alert screenshot or export from a safe lab trigger showing it reached a human queue (V5); log source health check | The rule text without a fired alert |
| CTL-06 | Rotation log; a test showing the old credential fails | A ticket marked done |
| CTL-07 | Approval record; unreachability test from every vantage point | A statement that it is down |
| V1 fixed version | Scanner or package query output with the version string per asset, including containers and appliances | The patch ticket closed |
| V4 external exposure closed | External scan report after the change, compared with the S1 list | An internal scan |
| V6 temporary controls retired | Removal or re-approval record per control, plus V4 rerun | Expiry date passed with no record |
| V7 evidence filed | Link resolves from the tracker to the artifact | Artifact in someone's downloads folder |

## DT-4 Hunt selection (Stage S6)

Pick hypotheses by vulnerability class. Each hypothesis in `library/hunts.md` lists the data it needs. If a data source is missing or retention is shorter than the hunt window, record **Insufficient data** for that hypothesis and log the gap as a follow-up. Never record No evidence for a query that could not run.

| Vulnerability class | Hypotheses | Minimum data |
|---|---|---|
| Unauthenticated or post-auth RCE on a web runtime | H1, H2, H3, H5, H6 | EDR process events, web server logs |
| Auth bypass on edge, identity, or management interface | H7, H3, H4, H6 | Device admin and audit logs, firewall logs |
| Information disclosure or credential exposure | H5, H3, H6, then H7 for any credential the leak could expose | Web or WAF logs |
| Local privilege escalation | H4, H1, H6 | EDR process and audit events |
| SSRF | H3 (destinations: internal ranges, cloud metadata), H5 | Proxy, firewall, or cloud flow logs |
| Denial of service only | H5 | Web server error logs |

Hunt window: the earliest of leak, pre-announcement, PoC release, or disclosure, minus the org buffer (Playbook Section 10). Outcomes per hypothesis: No evidence, Insufficient data, Suspicious, Confirmed.
