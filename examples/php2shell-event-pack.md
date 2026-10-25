# Worked example: PHP2Shell (October 2026)

> Built only from public reporting as of late October 2026. Facts can change; re-verify against the PHP project and Tier 1 sources before reuse. Org-specific sections are left as [FILL] on purpose.

## A. Intake
| Field | Value |
|---|---|
| Vulnerability / CVEs | PHP2Shell: CVE-2026-109618, CVE-2026-109619 |
| Affected | PHP core; public reporting says versions from PHP 5 onward |
| Fixed versions | 8.5.12, 8.4.27, 8.3.36, 8.2.35 (released October 21, 2026) |
| Class | Unauthenticated remote code execution (vendor CVSS v4.0 9.2 each) |
| Preconditions | Reported to involve request handling; one flaw tied to out-of-memory handling, the other to stale state / use-after-free |
| Exploitation status | Exploitation attempts reported by security firms, including before patches; early reports conflicted; verify KEV status |
| Sources | PHP project advisory (Tier 1), CERT-EU advisory (Tier 1), SANS ISC (Tier 2), multiple vendor research teams (Tier 2) |

## B. Trigger decision
- Triggers met: maintainer pre-announcement of critical release; critical RCE in internet-facing technology.
- Lane: **Fire drill.**

## C. Exposure
- Search terms: `php`, `php-fpm`, `php-cgi`, `libphp`, `mod_php`, PHP container base images, CMS platforms and vendor appliances that bundle PHP.
- Key question: which instances still run versions below the fixed releases, and which are internet-facing?
- Org answers: [FILL]

## D. Compensating controls
| Control | Fit | Limits |
|---|---|---|
| CTL-02: set `session.upload_progress.enabled = Off` | Early guidance (SANS ISC) called this a **partial** mitigation; the default is On | Partial only; reporting said neither flaw had a universal configuration-only fix |
| CTL-01: WAF rule for published request patterns | Useful once trusted patterns are published | Bypassable; only covers WAF-fronted hosts |
| CTL-03: restrict non-public PHP apps | Reduces reachable population | Does not protect public apps |
| CTL-05: detection for web runtime spawning shells, new files in web roots | Mandatory because mitigations are partial | Detects, does not prevent |

## E. Remediation
Upgrade to the fixed version for each branch. Unsupported branches (no fix) need a migration plan plus CTL-03/04 until retired.

## F. Verification
V1 version check on every instance including containers; V2 runtime config readback for the mitigation; V4 external rescan; V5 detection lab test.

## G. Retro-hunt
- Window: from the October 20, 2026 leak, minus a buffer.
- Hypotheses: H1, H2, H3, H5.

## Lessons this example teaches
1. A pre-announcement is a head start. Use the Prepare lane immediately.
2. Exploitation can begin before the patch exists.
3. "Mitigation available" often means partial. Always pair with detection.
4. Unofficial "fix" scripts appear within hours. Treat them as untrusted code.
