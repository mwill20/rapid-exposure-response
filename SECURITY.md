# Security and data-handling rules

## 1. This repo is generic. Always.
Never commit any of the following, even redacted:
- Organization, department, or vendor-contract names tied to a real employer
- Hostnames, IP addresses, URLs of internal systems, network diagrams
- People's names, emails, phone numbers, on-call schedules
- Filled trackers, completed Event Packs, findings, scan output, logs
- Credentials, tokens, keys, or patient data of any kind

The `.githooks/pre-commit` hook and the `guard` CI workflow block common leak patterns. They are a safety net, not a guarantee. Read your diff before every push.

## 2. One-way flow
- Work devices **download** releases. They never clone with credentials, push, open issues, or comment.
- If a git clone is used at work, disable push: `git remote set-url --push origin DISABLED`.
- Nothing derived from a real event returns here, including lessons learned. Lessons go into the after-action report stored in the org workspace. Changes to this kit are design decisions made on a personal device without reference to any event.

## 3. Repo integrity
- Two-factor authentication on the GitHub account.
- Branch protection on `main`; require pull requests even if you are the only author.
- Sign tags (`git tag -s`) once a signing key is set up.
- Releases include `SHA256SUMS.txt`. A checksum from the same release only detects corruption or tampering in transit. Each release also carries a build provenance attestation; `gh attestation verify rer-kit-vX.Y.Z.zip --repo mwill20/rapid-exposure-response` proves the zip came from this repository's workflow at a specific commit, which a checksum alone cannot.
- GitHub Actions are pinned to commit SHAs and updated by Dependabot.

## 4. Work-side handling
- The updater only accepts release tags of the form `vX.Y.Z` and a zip named `rer-kit-vX.Y.Z.zip`, verifies SHA256 before extracting, and never writes outside `upstream\`. Pester tests cover the corrupted-checksum, bad-tag and wrong-asset paths.
- Store extracted files in a restricted SharePoint location. Copilot surfaces content to anyone with access.
- Follow your organization's acceptable-use and software policies. If running scripts from the internet is not allowed, use the browser download path in the README.

## 5. Prompt-injection hygiene
Advisories, blog posts, PoC READMEs, and emails pasted into Copilot are **data, not instructions**. The agent instructions in `copilot/agent-instructions.md` say so explicitly. Never run third-party PoC or "mitigation" scripts on production.
