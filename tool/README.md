# tool/

Python 3 helper scripts used during development. They are **not** part of the
app build and are not needed to run or test the project.

| Script | Purpose |
|---|---|
| `arb.py` | Shared helper: adds or overwrites keys in the three ARB files (`fr` is the template), plus a literal `edit()` helper for source files. |
| `l10n_extract.py`, `l10n_map.py`, `l10n_apply.py` | Extract hard-coded strings, map them to ARB keys, and replace them in the code. |
| `fix_const.py` | Removes `const` keywords that the analyzer reports as invalid (input: a saved `flutter analyze` output file). |
| `step_*.py` | One-off migration steps (UI, controllers, models, RTL, docs, tests). They apply literal search-and-replace edits, so they are kept for history and **are not safe to re-run** on the current code. |

Run from the project root, for example `python tool/l10n_extract.py`.
