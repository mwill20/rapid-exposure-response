# Build guide 07: AAR report flow

Builds Flow 07 (`flows/07_aar_report.md`) as an agent flow and adds it as the **Save AAR report** tool. Standard connectors only. About 45 minutes.

**Verified on 2026-10-25 against:**
- Create an agent flow as a tool: https://learn.microsoft.com/en-us/microsoft-copilot-studio/advanced-flow-create
- Word Online (Business) is a Premium connector: https://learn.microsoft.com/en-us/connectors/wordonlinebusiness/

## Step 1. Create the agent flow
- **Where:** Copilot Studio > agent > **Tools** > **Add a tool** > **New tool** > **Agent flow**.
- **Do:** name `RER 07 save AAR`. Inputs on the trigger: EventId (Text), EventItemId (Number), ReportHtml (Text) with one-line descriptions.
- **Verify:** three inputs.

## Step 2. Build the file name and document
- **Where:** **+** > Compose, twice.
- **Do:** `FileName` and `Document` expressions from the flow spec steps 1 and 2.
- **Verify:** both expressions save.

## Step 3. Create the file and link it
- **Where:** **+** > SharePoint **Create file**; then SharePoint **Update item**.
- **Do:** Create file: Site, Folder Path `/Shared Documents/RER/org/events` (pick it with the folder picker to get the exact path), File Name from `FileName`, File Content from `Document`. Update item: RER_Events, Id = EventItemId, AAR_Link = **Link to item** from Create file.
- **If different:** if your library is not named Shared Documents, use the picker; the path differs by site language.
- **Verify:** no red fields.

## Step 4. Respond last
- **Where:** **Respond to the agent** card at the end.
- **Do:** output `Result` with the saved message from the spec step 5, including `FileName` and `EventId`. Asynchronous response Off.
- **Verify:** the response is the last card.

## Step 5. Publish and configure the tool
- **Do:** Publish the flow. On the agent, name the tool `Save AAR report`, description from the spec, **Ask the end user before running: Yes**, Completion **Send specific response** with `Result`.
- **Verify:** tool enabled; `/Save AAR report` resolves in the instructions.

## Step 6. Test
- **Do:** RER-AAR for the drill event; accept Save AAR report.
- **Expect:** a new `.html` under `RER/org/events`, readable in the browser; AAR_Link set on the event; the response names the file.
- **Verify:** open the file in Word from SharePoint and Save as .docx once to confirm the manual conversion path.

## Optional premium upgrade
If Power Automate Premium is licensed, follow the flow spec's optional section to fill a .docx template with **Populate a Microsoft Word template**. Keep the HTML path as fallback.

Publish the agent again. Go to guide 08.
