#!/usr/bin/env python3
"""Cross-reference checker for the RER Kit.

Every reference to a playbook Section, Step or Appendix, a control (CTL-xx),
a verification check (Vx), a hunt (Hx), a stage (Sx) or an Event Pack section
letter must point at something that is defined. Fails with file:line messages.

Usage: python3 scripts/check_refs.py [--root DIR]
Exit codes: 0 all references resolve, 1 unresolved references, 2 setup error.
Stdlib only so it runs anywhere CI has python3.
"""
import argparse
import re
import sys
from pathlib import Path

# Files whose content ships in the kit and therefore must resolve.
SHIPPED_DIRS = ("playbook", "packs", "library", "copilot", "examples", "reports",
                "drills", "lists", "flows", "build-guides")
SHIPPED_ROOT_FILES = ("README.md", "SECURITY.md", "tracker/README.md")

PLAYBOOK = "playbook/RER_Playbook.md"
EVENT_PACK = "packs/EVENT_PACK_TEMPLATE.md"
DEFS = {
    # kind: (file, regex that captures the ID from a heading line)
    "CTL": ("library/controls.md", re.compile(r"^##\s+(CTL-\d{2})\b")),
    "V": ("library/verification.md", re.compile(r"^##\s+(V\d)\.")),
    "H": ("library/hunts.md", re.compile(r"^##\s+(H\d)\.")),
    "S": (PLAYBOOK, re.compile(r"^#{2,3}\s+(S\d)\.")),
    "Section": (PLAYBOOK, re.compile(r"^#{2,3}\s+(\d+(?:\.\d+)?)\.?\s")),
    "Step": (PLAYBOOK, re.compile(r"^###\s+Step\s+(\d+)\.")),
    "Appendix": (PLAYBOOK, re.compile(r"^##\s+Appendix\s+([A-Z])\.")),
    "Pack": (EVENT_PACK, re.compile(r"^##\s+([A-Z])\.\s")),
}

# Reference patterns. Each yields (kind, id). Word boundaries keep "V1" from
# matching inside "v1.2" (case-sensitive) and "H1" inside identifiers.
REFS = [
    ("CTL", re.compile(r"(?<![A-Za-z0-9_-])(CTL-\d{2})(?![0-9])")),
    ("V", re.compile(r"(?<![A-Za-z0-9_/.-])(V\d)(?![0-9A-Za-z.])")),
    ("H", re.compile(r"(?<![A-Za-z0-9_/.-])(H\d)(?![0-9A-Za-z.])")),
    ("S", re.compile(r"(?<![A-Za-z0-9_/.-])(S\d)(?![0-9A-Za-z.])")),
    ("Section", re.compile(r"\b(?:Playbook\s+)?Section\s+(\d+(?:\.\d+)?)(?![0-9.])")),
    ("Section", re.compile(r"\bPlaybook\s+(\d+\.\d+)(?![0-9.])")),
    ("Step", re.compile(r"\bStep\s+(\d+)(?![0-9])")),
    ("Appendix", re.compile(r"\bAppendix\s+([A-Z])(?![A-Za-z])")),
    ("Pack", re.compile(r"\b[Ss]ection\s+([A-Z])(?![A-Za-z])")),
]
# "sections A, B, C (search terms only), D, E, F, and G" -> each letter.
PACK_LIST = re.compile(r"\b[Ss]ections\s+((?:[A-Z]\b(?:\s*\([^)]*\))?[,\s]*(?:and\s+)?)+)")
PACK_LETTER = re.compile(r"\b([A-Z])\b")

CODE_FENCE = re.compile(r"^\s*```")


def shipped_files(root: Path):
    files = []
    for d in SHIPPED_DIRS:
        p = root / d
        if p.is_dir():
            files.extend(sorted(p.rglob("*.md")))
    for f in SHIPPED_ROOT_FILES:
        p = root / f
        if p.is_file():
            files.append(p)
    return files


def load_definitions(root: Path):
    defined = {kind: set() for kind in DEFS}
    for kind, (rel, rx) in DEFS.items():
        path = root / rel
        if not path.is_file():
            sys.exit(f"check_refs: definition file missing: {rel}")
        for line in path.read_text(encoding="utf-8").splitlines():
            m = rx.match(line)
            if m:
                defined[kind].add(m.group(1))
    # A Section N.N implies Section N exists; the regex already captures both.
    return defined


def find_references(path: Path):
    """Yield (lineno, kind, id). Fenced code blocks are included on purpose:
    the Copilot prompts live in fences and must resolve too."""
    for lineno, line in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
        for kind, rx in REFS:
            for m in rx.finditer(line):
                yield lineno, kind, m.group(1)
        for m in PACK_LIST.finditer(line):
            for letter in PACK_LETTER.findall(m.group(1)):
                yield lineno, "Pack", letter


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--root", default=".", help="repo root (default: cwd)")
    args = ap.parse_args()
    root = Path(args.root).resolve()

    defined = load_definitions(root)
    files = shipped_files(root)
    if not files:
        print("check_refs: no shipped markdown files found", file=sys.stderr)
        return 2

    problems = []
    counted = 0
    for path in files:
        rel = path.relative_to(root).as_posix()
        for lineno, kind, ident in find_references(path):
            counted += 1
            if ident not in defined[kind]:
                label = ident if kind in ("CTL", "V", "H", "S") else f"{kind} {ident}"
                problems.append(f"{rel}:{lineno}: unresolved {label}")

    for p in problems:
        print(p)
    if problems:
        print(f"check_refs: {len(problems)} unresolved reference(s) in {len(files)} files. "
              "Fix the reference or add the definition in the same change.")
        return 1
    print(f"check_refs: {counted} references in {len(files)} files all resolve.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
