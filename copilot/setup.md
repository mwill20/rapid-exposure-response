# Copilot setup (work side)

## Folder layout in a restricted SharePoint site
```
RER/
  upstream/
    v0.1.0/        <- extracted release, treat as read-only
  org/
    RER_Playbook_ORG.docx
    RER_Tracker_ORG.xlsx
    events/
      EVT-2026-001_EventPack.docx
```
Permissions: RER roles only. Copilot shows content to anyone who can access it.

## Option 1: Copilot Notebook "RER Command" (fastest)
1. Create the notebook and share it with RER roles only.
2. Add references: the `RER/upstream/vX.Y.Z` folder (the .docx files) and the `RER/org` folder.
3. Paste `agent-instructions.md` into the notebook's custom instructions.
4. Note: notebooks ground on Office files and PDFs. Use the .docx versions from the release, not the .md files.

## Option 2: Agent Builder "RER Assistant"
1. Copilot Chat > Create an agent.
2. Knowledge: the `RER/upstream/vX.Y.Z` and `RER/org` folders.
3. Web content: off, unless your organization approves it.
4. Instructions: paste `agent-instructions.md`. Add the conversation starters.
5. Share with RER roles only.

## On each new release
1. Extract to `RER/upstream/vNEW`. Keep the previous version until you finish the diff.
2. Update the notebook or agent references to point at vNEW.
3. Run UPSTREAM-DIFF and merge by hand into `RER/org`.

## Licensing
Notebook and agent features and costs depend on your M365 licensing. Confirm with your M365 admin before rollout.
