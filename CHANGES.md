# Changes

## 2026-06-09

- Guarded the battery receiver against missing broadcast intents and preserved
  one-decimal temperature precision in receiver-backed reads.
- Guarded sticky battery intent helpers when callers or broadcast intents are
  unavailable, preserving `Unknown` display fallbacks.
- Added SDK-free baseline coverage for null-safe battery intent helpers.
- Required exact field prefixes before parsing legacy battery current text files
  so unrelated keys cannot be mistaken for current readings.
- Populated battery state and technology display fields from Android battery
  broadcast extras and added SDK-free source contracts for the mappings.
- Clamped normalized battery percentages to the 0 through 100 display range
  before icon threshold selection.
- Guarded nullable action-bar access before applying the battery icon/title
  presentation and added an SDK-free source contract for the startup path.
- Displayed missing battery current readings as `Unknown` instead of the
  literal `null` text when no supported device current file is available.
- Kept local battery diagnostic state out of Android backups by default.

## 2026-06-08

- Added `make check` as the root wrapper for battery source, lint, test, and
  debug build verification.
- Added a repository changelog and expanded the documented Android verification
  gate to include lint, tests, and debug assembly.
- Cleaned Android lint findings by moving UI text into resources, replacing
  hardcoded left/right layout attributes, and adding an accessibility label for
  the battery indicator.
- Moved active bitmap assets to `drawable-nodpi`, removed unused starter images
  and menu resources, and documented the narrow legacy lint baseline.
- Fixed battery current model matching to use `Locale.US` instead of the
  device default locale.
- Added battery status intent guards and normalized displayed battery level
  against Android's reported battery scale.
- Tightened battery icon thresholds so 30 and 31 percent no longer fall through
  to the green state.
- Converted raw battery millivolt readings into one-decimal volt display text.
