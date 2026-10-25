# Build guide 03: Copilot Studio agent (Tier B)

Builds the Tier B RER Assistant in Copilot Studio from the Tier A agent: adds the five lists as knowledge, four confirm-before-run write tools, and publishes to Microsoft 365 Copilot for the RER group. The two agent flows are added in guides 06 and 07. About two hours the first time. Spec: `copilot/studio-agent-spec.md`.

**Verified on 2026-10-25 against:**
- Copy from Agent Builder: https://learn.microsoft.com/en-us/microsoft-365/copilot/extensibility/copy-agent-to-copilot-studio
- Quickstart: https://learn.microsoft.com/en-us/microsoft-copilot-studio/fundamentals-get-started
- SharePoint knowledge: https://learn.microsoft.com/en-us/microsoft-copilot-studio/knowledge-add-sharepoint
- Tools: https://learn.microsoft.com/en-us/microsoft-copilot-studio/add-tools-custom-agent
- Publish to Teams and Microsoft 365 Copilot: https://learn.microsoft.com/en-us/microsoft-copilot-studio/publication-add-bot-to-microsoft-teams
- Licensing: https://learn.microsoft.com/en-us/microsoft-copilot-studio/billing-licensing

## Before you start: tenant checks
1. You can sign in at https://copilotstudio.microsoft.com and see an environment picker. A Microsoft 365 Copilot licence grants access; publishing needs more than a trial.
2. Your account has the **Common Data Service (Dataverse)** entitlement (needed for Copy to Copilot Studio and for list knowledge).
3. The environment is not a developer environment with automatic cleanup, or you accept re-creating it.
4. The SharePoint connector is not blocked by a data policy (Tools > Add a tool shows SharePoint enabled).
5. Ask your admin whether connector tool runs and agent flows consume Copilot Credits under your plan, and whether a capacity pack or pay-as-you-go is attached to the environment.

## Step 1. Copy the Tier A agent
- **Goal:** start from the tested agent so instructions, folders and prompts carry over.
- **Where:** Microsoft 365 Copilot > your agents > RER Assistant > **More options (…)** > **Copy to Copilot Studio** > choose the environment.
- **Do:** copy. Wait for the Copilot Studio tab to open on the new agent's **Overview** page. Select **Save**.
- **Expect:** Name, Description, Instructions and the two SharePoint folder knowledge sources are present. The RER_Events list is not copied; embedded files are not copied.
- **If different:** if the menu item is missing, create the agent by hand: Copilot Studio > **Home** > describe the agent in one line, then replace the generated name, description and instructions with the spec values.
- **Verify:** Overview shows the instructions block ending with the FINAL CHECK heading.

## Step 2. Append the tool instructions
- **Goal:** the agent knows when to offer each tool.
- **Where:** Overview > **Instructions** > Edit.
- **Do:** append the `# TOOLS (Copilot Studio only)` section from the spec. Tool names must match step 5 exactly; type `/` to pick them once they exist, or paste now and fix after step 5.
- **Expect:** instructions saved without a length warning.
- **Verify:** the `/Create RER event` reference resolves to a tool chip after step 5.

## Step 3. Add the five lists as knowledge
- **Goal:** RER-NEXT reads the lists instead of asking for pastes.
- **Where:** **Knowledge** > **Add knowledge** > in the **Upload file** section select **SharePoint** > **Browse items** > **Recent lists**. Page: SharePoint knowledge.
- **Do:** select RER_Events, RER_Assets, RER_Controls, RER_Hunts, RER_Evidence (open each list once in SharePoint first so it appears under Recent lists). **Confirm selection**. Enter the names and descriptions from the spec. **Add to agent**.
- **Expect:** five list sources, each eventually **Ready**. Ingestion can take minutes.
- **If different:** if a list is missing from Recent lists, paste its URL. If SharePoint is refused, Restricted SharePoint Search is on or Dataverse search is unavailable; stop and talk to your admin.
- **Verify:** Test pane: "Which RER_Assets rows have Grade E1?" returns the drill asset(s).

## Step 4. Knowledge settings
- **Goal:** answers come only from the kit and the lists.
- **Where:** **Settings** > **Generative AI**.
- **Do:** **Use general knowledge** off. **Web search** off. Leave **Allow ungrounded responses** on for now.
- **Expect:** saved.
- **Verify:** Test pane: "What is the capital of France?" is declined or redirected.

## Step 5. Add the four write tools
- **Goal:** the agent can record rows, but only after showing the values and getting a yes.
- **Where:** **Tools** > **Add a tool** > **Connector** > search `SharePoint` > **Create item** (or **Update item**) > **Add and configure**.
- **Do:** for each tool in the spec table: set **Name** exactly, paste the **Description**, **Authentication: End user**, **Allow agent to decide dynamically** on, **Ask the end user before running: Yes**. Inputs: Site Address and List Name as **Custom value**; the fixed columns in the spec as Custom value (`S0 Intake`, `Open`, `Active`, `N`, `Pending`); the rest **Dynamically fill with AI**. Completion: **Don't respond**. Save.
- **Expect:** four tools listed and enabled: Create RER event, Update RER event, Create RER control, Create RER hunt row.
- **If different:** if the SharePoint connector is disabled with an information icon, a data policy blocks it; ask your admin. If column names do not appear, enter the required inputs, save, and reopen.
- **Verify:** Test pane: run RER-MAP with the drill advisory, say "yes, create it", and confirm the agent shows the values, asks, then creates a row in RER_Events. Delete the test row by hand.

## Step 6. Confirm the forbidden list
- **Goal:** no delete, no direct send.
- **Where:** **Tools** page.
- **Do:** confirm there is no Delete item, Send an email or Post message tool on the agent. The only send path arrives with guide 06 and sits behind an approval.
- **Verify:** Test pane: "Delete event EVT-DRILL-001" is refused.

## Step 7. Authentication and sharing
- **Goal:** only RER roles can use the agent, with their own permissions.
- **Where:** **Settings** > **Security** > **Authentication**: **Authenticate with Microsoft**. Then **Share** (top right).
- **Do:** keep Authenticate with Microsoft. Share with the RER security group [FILL] only.
- **Expect:** group listed under shared users.
- **Verify:** a non-member cannot open the agent link in step 9.

## Step 8. Suggested prompts and icon
- **Goal:** the welcome page shows the commands.
- **Where:** Overview > **Suggested prompts**; agent icon > **Change icon**.
- **Do:** add the prompts from the spec (up to 10). Upload the 192 x 192 PNG under 72 KB made from `assets/logo.png`.
- **Verify:** prompts saved; icon shows in the top bar.

## Step 9. Publish and connect to Microsoft 365 Copilot
- **Goal:** the agent appears in Copilot and Teams for the group.
- **Where:** **Publish** > **Publish**. Then **Channels** > **Teams and Microsoft Copilot** tile.
- **Do:** keep **Make agent available in Microsoft Copilot** selected > **Add channel**. **Availability options** > **Copy link**. Install it for yourself with **See agent in Teams** > **Add**.
- **Expect:** the agent appears in the Microsoft 365 Copilot left pane; in Copilot Chat, `@RER Assistant` works.
- **If different:** if **Add channel** is blocked, a connector policy for the Teams + M365 channel is in place; ask your admin. If the agent shows a SystemError after republish, turn the Teams channel off and on, then republish (documented known issue).
- **Verify:** from Microsoft 365 Copilot, run spec test case 2 (RER-NEXT without pastes).

## Step 10. Run the spec test cases
- **Do:** all eight test cases in `copilot/studio-agent-spec.md`, in Microsoft 365 Copilot, not only the Test pane.
- **Verify:** all pass. Record the date and the Copilot Studio agent name in the org playbook, Appendix C.

## On each kit release
Edit the Upstream knowledge source URL to the new version folder after UPSTREAM-DIFF, update the instructions block if the changelog says so, **Publish**. No admin approval needed for content changes.

Go to guides 04 and 05 (flows that run on their own), then 06 and 07 (flows the agent calls), then 08.
