# Retro-hunt hypotheses (SIEM-agnostic)

Translate each into your SIEM's query language (for example, YARA-L in Google SecOps, KQL, SPL). Keep the translated queries in your org workspace, not here. Pick hypotheses with DT-4 in `library/decision_tables.md`.

**Hunt window:** start at the earliest of leak, pre-announcement, PoC release, or disclosure, minus a buffer. Patched does not mean clean.

**Before you run anything:** confirm each required data source exists for the affected hosts and that retention covers the whole window. If not, the outcome for that hypothesis is **Insufficient data**, and the gap goes to the after-action follow-ups.

## H1. Web runtime spawns a shell or interpreter
- **Data:** process creation with parent and child (EDR). Retention must cover the window.
- **Logic:** parent is a web server or language runtime worker; child is a shell, scripting interpreter, or download utility.
- **Tune:** baseline legitimate children first (some apps call helpers).

## H2. New or modified files in web roots
- **Data:** file creation and modification events, or file integrity monitoring, on the served directories.
- **Logic:** new script files in served directories, especially with recent timestamps, odd names, or written by the web service account.

## H3. Unusual outbound from affected hosts
- **Data:** firewall, proxy, DNS, or cloud flow logs for the affected hosts.
- **Logic:** first-seen destinations, rare ports, beacon-like intervals, connections to new or low-reputation domains from servers that rarely initiate outbound. For SSRF, destinations in internal ranges or cloud metadata addresses.

## H4. Persistence
- **Data:** EDR and OS audit logs.
- **Logic:** new accounts, scheduled tasks or cron entries, new services, SSH key changes, startup modifications on affected hosts.

## H5. Anomalous requests in web logs
- **Data:** web server, WAF, or load balancer logs for the affected endpoints.
- **Logic:** requests matching published exploit characteristics; spikes in errors or crashes on affected endpoints (memory or crash-related bugs often leave error trails).

## H6. Published IOCs
- **Data:** all of the above.
- **Logic:** match vendor or Tier 1 IOCs. Treat Tier 2 and Tier 3 IOCs as leads, not proof.

## H7. Unexpected administrative access or configuration change on edge or identity devices
- **Data:** device admin login and audit logs, configuration change logs, identity provider sign-in logs.
- **Logic:** admin sessions from new source addresses or outside maintenance windows; configuration exports; new admin accounts; changes to authentication settings, certificates, or logging.

## Outcomes
Record one outcome per hypothesis, with the query, the window, and the data sources used.

- **No evidence:** the query ran over the full window with the required data and matched nothing. Document and close.
- **Insufficient data:** the data source is missing, incomplete, or retention is shorter than the window. Log the gap as a follow-up. This is not No evidence.
- **Suspicious:** matches that need analyst review. Escalate to the IR lead.
- **Confirmed:** evidence of exploitation. Invoke the IR plan and notify compliance.

The event's overall Hunt_Result is the worst outcome across hypotheses, in the order Confirmed, Suspicious, Insufficient data, No evidence.
