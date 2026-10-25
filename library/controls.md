# Compensating control library

Each control lists when to use it, typical limits, how to verify it, how to roll it back, and the evidence to keep. Tiers match Playbook Section 2.1 (A = non-disruptive, B = service-affecting, C = isolate or shut down).

## CTL-01 WAF / edge virtual patch (Tier A)
- **Use when:** a trusted source publishes request characteristics (paths, parameters, headers, body patterns) for the exploit.
- **Limits:** bypassable by encoding or alternate paths; useless for non-HTTP vectors; only covers traffic that actually traverses the WAF.
- **Do:** deploy in log mode for a short window if safe, then block. Confirm all exposed hosts sit behind the WAF.
- **Verify:** send a benign request matching the rule pattern and confirm block plus log entry. Confirm no direct-to-origin path exists.
- **Rollback:** disable the rule.
- **Evidence:** rule ID, deploy time, test request and result, coverage list.

## CTL-02 Disable vulnerable feature, module, or configuration (Tier A/B)
- **Use when:** the vendor names a feature-level mitigation.
- **Limits:** often partial; may break functionality; config drift can silently revert it.
- **Do:** apply via config management where possible so it is consistent and reversible.
- **Verify:** read back the effective runtime configuration on each host, not just the file.
- **Rollback:** revert the config change.
- **Evidence:** before/after config, host list, readback output.

## CTL-03 Restrict access: allowlist, VPN-only, geo (Tier B)
- **Use when:** the service does not need broad reachability.
- **Limits:** insiders and compromised internal hosts still reach it.
- **Verify:** test from an outside, disallowed location and from an allowed one.
- **Rollback:** remove the rule.
- **Evidence:** rule ID, test results from both vantage points.

## CTL-04 Segment or isolate (Tier B/C)
- **Use when:** patching is far off and exposure is high.
- **Limits:** dependencies break; isolation of clinical or critical systems needs Tier C approval.
- **Verify:** connectivity tests from representative segments.
- **Rollback:** restore network paths.
- **Evidence:** change record, connectivity test results.

## CTL-05 Extra logging plus detection rule (Tier A)
- **Use when:** always, and mandatory when mitigations are partial.
- **Do:** raise log verbosity on affected services, confirm logs reach the SIEM, deploy behavior detections (see library/hunts.md).
- **Verify:** trigger the detection with a safe lab simulation and confirm the alert routes to a human.
- **Rollback:** reduce verbosity after the hunt closes.
- **Evidence:** rule ID, test alert, log source health check.

## CTL-06 Credential, session, or key rotation (Tier B)
- **Use when:** compromise is possible or secrets may be exposed on affected hosts.
- **Limits:** disruptive; coordinate with owners.
- **Verify:** old credentials fail; services run on new ones.
- **Evidence:** rotation log, validation results.

## CTL-07 Take offline (Tier C)
- **Use when:** E1, exploitation confirmed or highly likely, and no other control is sufficient.
- **Verify:** service unreachable from all vantage points.
- **Rollback:** restore after fix is verified.
- **Evidence:** approval record, downtime window, restoration verification.

## Rules for every control
1. Owner, approver, rollback, and **expiry date** recorded in the tracker before or at deployment.
2. A control that has not been verified does not count.
3. Expired controls are removed or re-approved, never silently kept.
