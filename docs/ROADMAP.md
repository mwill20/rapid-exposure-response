# Roadmap: RER Kit as a build kit for the work tenant

Source of truth for scope and sequencing. `docs/HANDOFF.md` holds current status and known issues. Update both in the same change.

## Goal
Move the team from exposure risk through containment, remediation, verification and retro-hunt with one question per stage ("what blocks exit?") and one command that answers it. M365 Copilot does the steps, recommendations, evidence guidance, report generation and notification drafting. Humans decide, run tools, attach evidence and approve every send.

## Operating idea
The repo ships two things: the playbook content, and the build guides that let the owner stand up the tenant side with M365 Copilot as the walkthrough partner. Claude is not available at work, so every tenant task is written to be pasted into Copilot and followed step by step.

## Architecture (target)
- **System of record:** five SharePoint Lists in a restricted site (Events, Assets, Controls, Hunts, Evidence). The generated .xlsx is the import source and the fallback.
- **Advisor:** one Copilot Studio agent, "RER Assistant". Agent Builder is the quickstart only.
- **Actions the agent may take:** create and update list rows, post drafts. **Never:** send a message, delete anything, change a control, run a query.
- **Flows (Power Automate):** KEV email intake to draft event row; temporary-control expiry reminders; owner notices behind a human approval step; AAR report generated into org SharePoint.
- **Decisions:** deterministic tables in `library/`. The agent cites a row; it does not reason its way to a control.
- **Intake source (v0.4.0):** CISA KEV email alerts. Vendor lists later.

## Invariants added by this roadmap
- Nothing derived from a real event goes to this repo. Lessons go to the AAR report in org SharePoint. The earlier "generic rewrites from memory" allowance is withdrawn.
- Every outbound message in a flow has a human approval step.
- Guides carry a verified-on date and Microsoft Learn URLs. Review quarterly.

## Milestones

### M0 (v0.1.x) Pipeline
P0-1 initialize and publish; P0-2 cross-reference checker; P0-3 updater validated. Guard hardening (fail closed on pattern errors).
**Done when:** guard and release workflows green; `check_refs.py` fails on a planted break; analyzer and Pester green; live download test passes.

### M1 (v0.2.0) Staged playbook and decision tables
- Playbook Section 6 rewritten as eight stages: Intake, Triage, Contain, Communicate, Remediate, Verify, Hunt, Closed. Each has entry criteria, exit criteria, exit artifact, time target, owner role, and a stage ID (S0..S7) for cross-reference.
- Event Pack aligned to stages; section I captures lessons for the AAR, not for the repo.
- `library/decision_tables.md`: control matrix (class x preconditions x exposure tier -> controls, limits, evidence standard, plain-language determination); exposure rubric (yes/no answers -> E1..E4); verification evidence standards.
- `library/hunts.md`: required log sources per hypothesis; outcomes No evidence / Insufficient data / Suspicious / Confirmed.
- `reports/AAR_REPORT_TEMPLATE.md`, built to .docx.
- Remove "carry home" language from SECURITY.md, playbook Section 11, Event Pack I.
- `check_refs.py` learns stage IDs.
**Done when:** checker and build pass; drill 1 answer key is consistent with the tables.

### M2 (v0.3.0) Lists, Tier A agent, first guides
- `lists/DATA_MODEL.md` and `scripts/build_lists_import.py` producing one Excel table per list, ready for "Create a list from Excel".
- `copilot/` Tier A: Agent Builder instructions; stage prompts with fixed output schemas (RER-MAP, RER-NEXT, RER-CONTAIN, RER-NOTICES, RER-UPDATE, RER-VERIFY, RER-HUNT, RER-AAR).
- `build-guides/00_READ_FIRST.md`, `01_sharepoint_site_and_lists.md`, `02_agent_builder_quickstart.md`, `09_verification_drill.md`.
- `drills/inject-01` with answer key.
**Done when:** owner creates the Lists and agent at work, runs drill 1, scores against the key.

### M3 (v0.4.0) Copilot Studio agent and flows
- `copilot/studio/` agent spec: instructions, knowledge sources, topics, allowed actions, forbidden actions, test cases.
- `flows/` one spec per flow with trigger, steps, expressions, approval step, failure handling.
- `build-guides/03_copilot_studio_agent.md`, `04_flow_intake_kev_email.md`, `05_flow_expiry_reminders.md`, `06_flow_notices_with_approval.md`, `07_flow_aar_report.md`.
- `drills/inject-02`, `inject-03`.
**Done when:** verification drill passes at work: a KEV email creates a draft event, notices wait for approval, AAR lands in SharePoint.

### Later
- P1-4 supply chain (SHA pins, Dependabot, attestation). P1-5 style lint. P1-6 styled .docx. Vendor-list intake. Quarterly guide review.

## Build guide format (every step)
Goal / Where (UI path, verified-on date, Learn URL) / Do / Expect / If different (a ready prompt for Copilot to find the current path) / Verify.

## Tenant checks the owner must make (cannot be verified from here)
- Agent Builder and Copilot Studio knowledge grounding on List items via a SharePoint site source.
- Copilot Studio capacity and connector availability under the current licence.
- "Create a list from Excel" enabled in SharePoint.
- Knowledge-source limit per agent (20 at time of writing).
- Software policy for running the updater script; browser download is the fallback.
