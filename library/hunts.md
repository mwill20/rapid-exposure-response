# Retro-hunt hypotheses (SIEM-agnostic)

Translate each into your SIEM's query language (for example, YARA-L in Google SecOps, KQL, SPL). Keep the translated queries in your org workspace, not here.

**Hunt window:** start at the earliest of leak, pre-announcement, PoC release, or disclosure, minus a buffer. Patched does not mean clean.

## H1. Web runtime spawns a shell or interpreter
- **Data:** process creation with parent/child (EDR).
- **Logic:** parent is a web server or language runtime worker; child is a shell, scripting interpreter, or download utility.
- **Tune:** baseline legitimate children first (some apps call helpers).

## H2. New or modified files in web roots
- **Data:** file creation/modification events, file integrity monitoring.
- **Logic:** new script files in served directories, especially with recent timestamps, odd names, or written by the web service account.

## H3. Unusual outbound from affected hosts
- **Data:** firewall, proxy, DNS logs.
- **Logic:** first-seen destinations, rare ports, beacon-like intervals, connections to new or low-reputation domains from servers that rarely initiate outbound.

## H4. Persistence
- **Data:** EDR, OS audit logs.
- **Logic:** new accounts, scheduled tasks or cron entries, new services, SSH key changes, startup modifications on affected hosts.

## H5. Anomalous requests in web logs
- **Data:** web server, WAF, load balancer logs.
- **Logic:** requests matching published exploit characteristics; spikes in errors or crashes on affected endpoints (memory or crash-related bugs often leave error trails).

## H6. Published IOCs
- **Data:** all of the above.
- **Logic:** match vendor or Tier 1 IOCs. Treat Tier 2/3 IOCs as leads, not proof.

## Outcomes
- **No evidence:** document the window, data sources, and queries; close.
- **Suspicious:** escalate to the IR lead.
- **Confirmed:** invoke the IR plan and notify compliance.
