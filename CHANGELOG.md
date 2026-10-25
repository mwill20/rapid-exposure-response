# Changelog

Format: version, date, then Added / Changed / Removed. Keep entries generic.

## 0.3.0 (2026-10-25)
### Added
- `lists/DATA_MODEL.md`: five SharePoint Lists (RER_Events, RER_Assets, RER_Controls, RER_Hunts, RER_Evidence) with column types, choice values, calculated hour columns, views, column formatting JSON for Grade and Expiry_Date, reminders and rules
- `scripts/build_lists_import.py` and `lists/RER_Lists_Import.xlsx` in the release zip: one Excel table per list, EXAMPLE row for type inference, ready for Lists > From Excel
- `copilot/output-schemas.md`: fixed output table per stage command, mapped to list columns
- `copilot/agent-instructions.md` rewritten to Microsoft's declarative-agent structure (objective, rules, per-command steps, final check), 4,200 characters, with Agent Builder settings
- Build guides 00 (read first, walkthrough and recovery prompts), 01 (site, Lists, views, formatting, reminders), 02 (Agent Builder quickstart, Notebook alternative), 09 (verification drill), each step Goal / Where / Do / Expect / If different / Verify with verified-on dates and Learn URLs
- Drill 1: synthetic edge-device authentication bypass advisory with an embedded-instruction test, 20-item answer key, scoring sheet with critical items
### Changed
- Playbook Appendix C points at the single instruction source and the build guides; grounding note on the one-list limit
- Prompts reference the output schemas and the Tier A grounding scope

## 0.2.0 (2026-10-25)
### Added
- Playbook Section 6 rewritten as eight stages S0 to S7, each with entry criteria, checklist, exit criteria, exit artifact, owner role and Copilot command; stage summary table with the gate question per stage
- `library/decision_tables.md`: DT-1 exposure rubric (first matching row wins, Unknown gives E4, priority P1 to P4), DT-2 control selection matrix by vulnerability class and grade with modifiers, evidence standards and plain-language determinations, DT-3 evidence standards (counts / does not count), DT-4 hunt selection by class
- `library/hunts.md`: H7 (admin access or config change on edge and identity devices), required data per hypothesis, four outcomes including Insufficient data
- `reports/AAR_REPORT_TEMPLATE.md`, shipped as .docx; lessons and follow-ups live there
- Event Pack: stage gate table, DT-1 question grid per asset, evidence standard and determination columns, hunt outcome table
- Prompts: RER-NEXT, RER-CONTAIN, RER-HUNT; agent rules 11 to 13 (cite table rows, NO ROW, stage status)
### Changed
- Worked example re-mapped to the stages and decision tables
- Cross-reference checker validates stage IDs and DT-x references
### Removed
- All "carry lessons home" language. Nothing from an event returns to this repository.

## 0.1.0 (2026-10-24)
### Added
- Standing RER playbook (7-step procedure, triggers, roles, control menu, comms templates)
- Event Pack template and RER-MAP prompt
- Control, verification, hunt, and source libraries
- Copilot agent instructions, prompt pack, setup guide
- RER Tracker workbook
- PHP2Shell worked example
- Release workflow (Markdown to .docx, zip, SHA256) and leak guard
- Cross-reference checker (`scripts/check_refs.py`) with a should-fail self-test, run by the pre-commit hook and CI
- Updater validation: PSScriptAnalyzer and Pester tests on Windows PowerShell 5.1 and PowerShell 7, plus a live download test after each release
- Updater hardening: release tag and asset name validation, strict checksum parsing
- Leak guard fails closed on grep errors and escapes denylist terms literally
