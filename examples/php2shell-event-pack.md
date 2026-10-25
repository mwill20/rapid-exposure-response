# Worked example: PHP2Shell (October 2026)

> Built only from public reporting as of late October 2026. Facts can change; re-verify against the PHP project and Tier 1 sources before reuse. Org-specific sections are left as [FILL] on purpose. This example shows how the decision tables are cited; it is not a record of any real event.

## A. Intake (Stage S0)
| Field | Value |
|---|---|
| Vulnerability / CVEs | PHP2Shell: CVE-2026-109618, CVE-2026-109619 |
| Affected | PHP core; public reporting says versions from PHP 5 onward |
| Fixed versions | 8.5.12, 8.4.27, 8.3.36, 8.2.35 (released October 21, 2026) |
| Class (DT-2 wording) | Unauthenticated remote code execution over HTTP (language runtime), vendor CVSS v4.0 9.2 each |
| Preconditions | Reported to involve request handling; one flaw tied to out-of-memory handling, the other to stale state / use-after-free. No authentication reported as required. |
| Exploitation status | Exploitation attempts reported by security firms, including before patches; early reports conflicted; verify KEV status |
| Sources | PHP project advisory (Tier 1), CERT-EU advisory (Tier 1), SANS ISC (Tier 2), multiple vendor research teams (Tier 2) |

## B. Trigger decision (Stage S0)
- Triggers met: maintainer pre-announcement of a critical security release; critical RCE in internet-facing technology.
- Lane: **Fire drill.** Human decision: [FILL]

## C. Exposure (Stage S1, DT-1)
- Search terms: `php`, `php-fpm`, `php-cgi`, `libphp`, `mod_php`, PHP container base images, CMS platforms and vendor appliances that bundle PHP.
- Key question: which instances still run versions below the fixed releases, and which are internet-facing?
- How the grid resolves for typical assets (illustrative):

| Asset type | Q1 | Q2 | Q3 | Q4 | Q5 | Q6 | DT-1 row | Grade |
|---|---|---|---|---|---|---|---|---|
| Public web tier running PHP 8.3.30 | Y | Y | Y | Y | Y (request handling is core, treat as enabled) | n/a | 4 | E1 |
| Internal intranet app on PHP 8.2.20 | Y | Y | N | Y | Y | n/a | 6 | E2 |
| Container image, PHP version not yet confirmed | Y | Unknown | N | Y | Y | n/a | 3 | E4 |
| Vendor appliance that bundles PHP, vendor silent | Unknown | Unknown | N | N | Unknown | Unknown | 3 | E4 |

- Org answers: [FILL]

## D. Compensating controls (Stage S2, DT-2 row 1 for E1 assets, row 2 for E2 and E4)
Modifiers that apply: vendor mitigation reported as partial (CTL-05 mandatory, patch target pulled forward); exploitation reported (start S6 now).

| Control | Fit | What it does not cover | Evidence standard (DT-3) | Plain-language determination |
|---|---|---|---|---|
| CTL-02: set `session.upload_progress.enabled = Off` | Early guidance (SANS ISC) called this a **partial** mitigation; the default is On | Reporting said neither flaw had a universal configuration-only fix | Runtime config readback per host showing the setting | "Turning off upload progress tracking removes one reported path to the flaw on the web tier. It is partial, so detection stays on and the upgrade date stands." |
| CTL-01: WAF rule for published request patterns | Useful once trusted patterns are published | Bypassable; only covers WAF-fronted hosts | Rule ID in block mode plus a benign test request blocked and logged | "The edge rule stops known exploit requests before they reach the web tier. It does not stop variants or traffic that avoids the WAF." |
| CTL-03: restrict non-public PHP apps | Reduces reachable population for E2 assets | Does not protect public apps | Rule export plus tests from an allowed and a disallowed location | "Only the systems that need the intranet app can reach it. Anyone already inside that group is not stopped." |
| CTL-05: detection for web runtime spawning shells, new files in web roots | Mandatory because mitigations are partial | Detects, does not prevent | Alert from a lab trigger reaching a human queue | "We will be alerted if the server starts behaving like it was exploited. This does not prevent exploitation." |

## E. Remediation (Stage S4)
Upgrade to the fixed version for each branch, P1 assets first. Unsupported branches (no fix) need a migration plan plus CTL-03 or CTL-04 until retired.

## F. Verification (Stage S5)
V1 version check on every instance including containers; V2 runtime config readback for the mitigation; V3 benign request blocked for the WAF rule; V4 external rescan; V5 detection lab test; V6 temporary controls retired; V7 evidence linked. Evidence per DT-3.

## G. Retro-hunt (Stage S6, DT-4 row: RCE on a web runtime)
- Window: from the October 20, 2026 leak, minus a buffer.
- Hypotheses: H1, H2, H3, H5, H6. Before running, confirm EDR process events and web server logs exist for every affected host over the whole window; otherwise record Insufficient data for that hypothesis.

## Lessons this example teaches
1. A pre-announcement is a head start. Use the Prepare lane immediately.
2. Exploitation can begin before the patch exists.
3. "Mitigation available" often means partial. Always pair with detection.
4. Unofficial "fix" scripts appear within hours. Treat them as untrusted code.
5. An Unknown version is E4, not "probably fine". Containers and appliances are where the Unknowns hide.
