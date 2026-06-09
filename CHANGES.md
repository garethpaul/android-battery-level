# Changes

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
