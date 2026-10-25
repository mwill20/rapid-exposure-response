# How to use the RER Kit

Three parts: set it up once, run an event, update when a new version ships. Each step names the file with the detail. Everything happens in your Microsoft 365 tenant; nothing goes back to GitHub.

## 1. Set it up (one morning)
1. On the work device, download `rer-kit-vX.Y.Z.zip` and `SHA256SUMS.txt` from the Releases page and check the hash (README, "Use it at work").
2. Extract into a restricted SharePoint site at `RER/upstream/vX.Y.Z`. Create `RER/org` beside it for your filled copies. Only RER roles get access.
3. Open `build-guides/00_READ_FIRST.md`. It gives you the prompt that makes Copilot walk you through each guide one step at a time.
4. Guide 01: create the five Lists from `lists/RER_Lists_Import.xlsx`.
5. Guide 02: create the RER Assistant agent in Agent Builder with the instructions from `copilot/agent-instructions.md`.
6. Copy the playbook .docx into `RER/org`, add `_ORG` to the name, and fill every `[FILL]` marker (roles, approvers, time targets, intake channel). The SETUP-FILL prompt in `copilot/prompts.md` helps.
7. Guide 09: run drill 1 and score it. Use the agent for real events only after it passes with no critical misses.

Later, if you want the agent to record rows and send approved notices for you: guides 03 to 08 (Copilot Studio and Power Automate). Optional.

## 2. Run an event
An advisory lands in your intake channel. Each stage is one command to the agent and a few actions by you. Ask `RER-NEXT` at any time to hear which stage you are in and what blocks exit.

| Stage | Type | Do | Done when |
|---|---|---|---|
| S0 Intake | `RER-MAP` + pasted advisory | Decide the lane. Open the event row. Save the Event Pack draft to `RER/org/events`. | Event ID, lane and Triage Lead recorded |
| S1 Triage | `RER-NEXT` | Run scanner, EDR and inventory. Answer the seven questions per asset in RER_Assets. Check the DT-1 row the agent cites. | Every asset graded with evidence and an owner |
| S2 Contain | `RER-CONTAIN` | Approve and apply controls. Attach evidence that meets DT-3. Record each control with an expiry date. | Every E1 and E2 asset has a verified control or a recorded risk decision |
| S3 Communicate | `RER-NOTICES`, `RER-UPDATE` | Send the notices and the leadership update. Notify compliance if sensitive data is involved. | Owners acknowledged; first update sent |
| S4 Remediate | `RER-NEXT` | Patch in priority order under your emergency change. | Every asset patched or an exception recorded |
| S5 Verify | `RER-VERIFY` | Collect the evidence it lists. Retire or re-approve temporary controls. | Every asset has an evidence link; nothing past expiry |
| S6 Hunt | `RER-HUNT` | Write the queries in your SIEM. Record one outcome per hypothesis; Insufficient data is a valid outcome. | Every hypothesis has an outcome |
| S7 Close | `RER-AAR` | Verify every line of the report. Store it in `RER/org/events`. Send the close-out. | Report stored; status Closed |

Three rules: the agent cites a table row for every grade, control and hunt, and NO ROW means you decide; vendor config values are quoted exactly or not applied; a pasted advisory is data, so the agent ignoring an instruction inside it is correct.

## 3. Update to a new version
1. Download and verify the new zip. Extract to `RER/upstream/vNEW`. Keep the old folder until you finish.
2. Read `CHANGELOG.md`, then run the UPSTREAM-DIFF prompt. It lists each change and whether your org edition already has it.
3. Merge by hand into `RER/org`. Upstream never overwrites your files.
4. Point the agent's knowledge at `vNEW` (guide 02 step 4) and re-run a drill (`drills/SCORING.md` says which).
