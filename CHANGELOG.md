# Changelog

Format: version, date, then Added / Changed / Removed. Keep entries generic.

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
