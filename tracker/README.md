# RER Tracker

The workbook is generated at release time by `scripts/build_tracker.py` so the repo stays text-only and diffable.

Get it from the latest release zip (`tracker/RER_Tracker.xlsx`), or build it locally:

```bash
pip install openpyxl
python scripts/build_tracker.py tracker/RER_Tracker.xlsx
```

Sheets: README, Owners, Registry, Controls_Menu, Events, Event_Assets, Temp_Controls, Metrics. Row 2 on each sheet is an EXAMPLE row.

Never commit a filled tracker. `tracker/*.xlsx` is gitignored.
