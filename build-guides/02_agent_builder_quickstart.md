# Build guide 02: Agent Builder quickstart (Tier A)

Builds the **RER Assistant** declarative agent in Microsoft 365 Copilot's Agent Builder, grounded on the upstream kit, your org edition and the RER_Events list. About 30 minutes. The Copilot Notebook alternative is at the end.

**Verified on 2026-10-25 against:**
- Build agents in Agent Builder: https://learn.microsoft.com/en-us/microsoft-365/copilot/extensibility/agent-builder-build-agents
- Add knowledge sources: https://learn.microsoft.com/en-us/microsoft-365/copilot/extensibility/agent-builder-add-knowledge
- Write effective instructions: https://learn.microsoft.com/en-us/microsoft-365/copilot/extensibility/declarative-agent-instructions

Limits that shape this guide (from the pages above): name 30 characters, description 1,000, instructions 8,000; knowledge per agent: 100 SharePoint files, **one** SharePoint list, four public URLs. Selecting a site does not include its lists. If Restricted SharePoint Search is on, SharePoint cannot be a knowledge source.

Inputs: guide 01 complete; `copilot/agent-instructions.md` (.docx) open; the URL of your RER site, the `RER/upstream/vX.Y.Z` folder, the `RER/org` folder and the RER_Events list (list > **Share** > **Copy link**, without query parameters).

## Step 1. Open Agent Builder
- **Goal:** start a new agent manually, so nothing is invented for you.
- **Where:** Microsoft 365 Copilot app > left pane > **New agent** > **Skip to configure**.
- **Do:** click as shown. The **Configure** tab opens.
- **Expect:** fields Name, Icon, Model, Description, Instructions, Knowledge, Starter prompts.
- **If different:** if **New agent** is missing, your licence or tenant policy does not include Agent Builder; use the Notebook alternative at the end and record the gap. Otherwise, recovery prompt.
- **Verify:** the Configure tab is visible with an empty Instructions box.

## Step 2. Name, description, model
- **Goal:** identity that is findable and honest about scope.
- **Where:** Configure tab.
- **Do:** Name `RER Assistant`. Description: `Helps the [ORG] security team run the Rapid Exposure Response playbook: maps advisories to Event Packs, cites decision-table rows for grades, controls and hunts, drafts notices and reports. It never decides, runs tools or sends anything.` Model: **Auto**.
- **Expect:** no character-limit warning.
- **If different:** recovery prompt.
- **Verify:** the name shows at the top of the Try it pane.

## Step 3. Paste the instructions
- **Goal:** the behavior contract.
- **Where:** Configure tab > **Instructions**.
- **Do:** paste the fenced block from `copilot/agent-instructions.md`. Replace `[ORG]`. Change nothing else.
- **Expect:** the box accepts it (about 4,200 characters, under the 8,000 limit).
- **If different:** if the box truncates, remove the FINAL CHECK section last; keep RESPONSE RULES intact.
- **Verify:** scroll to the bottom of the box and see the FINAL CHECK heading.

## Step 4. Add knowledge
- **Goal:** ground on the kit, the org edition and the Events list, nothing else.
- **Where:** Configure tab > **Knowledge** > **Enter URL** (or **Browse** > Attach cloud files).
- **Do:** add, one at a time, pressing Enter after each: the `RER/upstream/vX.Y.Z` folder URL; the `RER/org` folder URL; the RER_Events list URL. Toggle **Only use specified sources** on. Leave **Search all websites** off unless approved. Leave **Reference people in organization** as your policy dictates. Leave **Create images** off.
- **Expect:** three knowledge entries. New items may show **Preparing** for several minutes.
- **If different:** if a URL is refused, remove query parameters and use the site-path form `.../sites/<site>/...`. If the list cannot be added, use **Browse** > **Recent lists**. If SharePoint sources are refused entirely, Restricted SharePoint Search is on; stop and talk to your admin.
- **Verify:** on the **Try it** tab ask: "Which file defines DT-2 and how many rows does it have?" Expect `library/decision_tables` and nine rows.

## Step 5. Starter prompts
- **Goal:** the team sees the commands without reading the prompt pack.
- **Where:** Configure tab > **Starter prompts**.
- **Do:** add the six starter prompts from `copilot/agent-instructions.md`, name and text.
- **Expect:** six tiles in the Try it pane after a new chat.
- **If different:** recovery prompt.
- **Verify:** clicking the RER-NEXT tile sends the prompt.

## Step 6. Test with the drill advisory
- **Goal:** prove grounding and the untrusted-data rule before anyone relies on the agent.
- **Where:** **Try it** tab.
- **Do:** paste `drills/inject-01-advisory.md` text with the RER-MAP prompt from `copilot/prompts.md`.
- **Expect:** an Event Pack draft that quotes the trigger line, names DT-2 row 3, quotes the vendor workaround verbatim, writes UNKNOWN for KEV status, and reports that it ignored the embedded instruction in the advisory.
- **If different:** if the agent invents values, confirm **Only use specified sources** is on and the knowledge shows ready, not Preparing. If it still invents, paste the FINAL CHECK section again at the end of the instructions.
- **Verify:** compare with `drills/inject-01-answer-key.md`, items marked **critical**. All must pass before Create.

## Step 7. Create and share
- **Goal:** the agent exists and only RER roles can use it.
- **Where:** **Create** (top right) > share dialog.
- **Do:** Create. Share with the RER roles only, not the organization.
- **Expect:** the agent appears in the Copilot left pane for you and the people you shared with.
- **If different:** recovery prompt.
- **Verify:** a colleague in an RER role sees the agent; someone outside does not.

## Step 8. Record what you built
- **Goal:** your org edition knows the agent exists and what it grounds on.
- **Where:** `RER/org/RER_Playbook_ORG.docx`, Appendix C.
- **Do:** write the agent name, the three knowledge sources, the date, and any tenant gaps found. Nothing goes upstream.
- **Verify:** Appendix C in the org playbook lists the three sources.

## On each new release
Change the knowledge entry from `RER/upstream/vOLD` to `RER/upstream/vNEW` after you finish the UPSTREAM-DIFF merge. Keep one version in knowledge at a time.

## Notebook alternative (if Agent Builder is unavailable)
Copilot Notebooks ground on Office files and PDFs, not Lists. Create a notebook **RER Command**, add the two folders as references, paste the instructions block as the notebook's custom instructions (Microsoft Copilot app > ... > Instructions), and paste RER_Events rows into prompts when a command needs them. Reference: https://support.microsoft.com/en-us/microsoft-365-copilot/add-references-to-your-microsoft-365-copilot-notebook (verified 2026-10-25).

Go to guide 09 to run the drill end to end and score it.
