#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
MAIN_ACTIVITY="$ROOT_DIR/app/src/main/java/garethpaul/com/chargeme/MainActivity.java"
CURRENT_READER="$ROOT_DIR/app/src/main/java/garethpaul/com/chargeme/CurrentReader.java"
LAYOUT="$ROOT_DIR/app/src/main/res/layout/activity_main.xml"
README="$ROOT_DIR/README.md"
RES_DIR="$ROOT_DIR/app/src/main/res"
PERCENT_CLAMP_PLAN="$ROOT_DIR/docs/plans/2026-06-09-battery-percent-clamp.md"

if grep -A3 "public void onPause()" "$MAIN_ACTIVITY" | grep -Fq "setup();"; then
  printf '%s\n' "onPause must unregister the battery receiver instead of calling setup()." >&2
  exit 1
fi

if grep -A3 "public void onStop()" "$MAIN_ACTIVITY" | grep -Fq "setup();"; then
  printf '%s\n' "onStop must unregister the battery receiver instead of calling setup()." >&2
  exit 1
fi

for pattern in \
  "private void configureActionBar()" \
  "ActionBar actionBar = getActionBar();" \
  "if (actionBar == null)" \
  "actionBar.setDisplayShowTitleEnabled(false);" \
  "actionBar.setIcon(R.drawable.battery_icon);" \
  "private boolean batteryReceiverRegistered;" \
  "private void registerBatteryReceiver()" \
  "private void unregisterBatteryReceiver()" \
  "unregisterReceiver(myBatInfoReceiver);" \
  "private static Intent batteryStatusIntent(Context context)" \
  "private int batteryLevelPercent(Intent batteryStatus)" \
  "batteryStatus == null" \
  "BatteryManager.EXTRA_SCALE"; do
  if ! grep -Fq "$pattern" "$MAIN_ACTIVITY"; then
    printf '%s\n' "Missing lifecycle guard pattern: $pattern" >&2
    exit 1
  fi
done

if grep -Fq "getActionBar().set" "$MAIN_ACTIVITY"; then
  printf '%s\n' "ActionBar configuration must guard nullable getActionBar() results." >&2
  exit 1
fi

if grep -Fq "level > 31" "$MAIN_ACTIVITY"; then
  printf '%s\n' "Battery icon threshold must not skip levels 30 and 31." >&2
  exit 1
fi

if grep -Fq "return Math.round((rawLevel * 100.0f) / scale);" "$MAIN_ACTIVITY"; then
  printf '%s\n' "Battery level display must clamp normalized percentages." >&2
  exit 1
fi

if ! grep -Fq "Math.max(0, Math.min(100, percent));" "$MAIN_ACTIVITY"; then
  printf '%s\n' "Battery level percentages must be clamped to 0 through 100." >&2
  exit 1
fi

if ! grep -Fq "status: completed" "$PERCENT_CLAMP_PLAN"; then
  printf '%s\n' "Battery percentage clamp plan must be marked completed." >&2
  exit 1
fi

if ! grep -Fq "level < 65" "$MAIN_ACTIVITY"; then
  printf '%s\n' "Battery icon threshold must keep orange below 65 percent." >&2
  exit 1
fi

if ! grep -Fq 'buildToolsVersion "24.0.3"' "$ROOT_DIR/app/build.gradle"; then
  printf '%s\n' "Android build-tools must stay pinned to 24.0.3 for 64-bit aapt." >&2
  exit 1
fi

if ! grep -Fq "Android build-tools 24.0.3" "$ROOT_DIR/README.md"; then
  printf '%s\n' "README must document the pinned Android build-tools version." >&2
  exit 1
fi

if [ ! -f "$ROOT_DIR/CHANGES.md" ]; then
  printf '%s\n' "CHANGES.md is missing." >&2
  exit 1
fi

if ! grep -Fq "Locale.US" "$CURRENT_READER"; then
  printf '%s\n' "CurrentReader must avoid default-locale model matching." >&2
  exit 1
fi

if grep -Fq 'String.valueOf(getVoltage()) + "V"' "$MAIN_ACTIVITY"; then
  printf '%s\n' "Battery voltage must not display raw millivolts as volts." >&2
  exit 1
fi

if grep -Fq "String.valueOf(CurrentReader.getValue())" "$MAIN_ACTIVITY"; then
  printf '%s\n' "Battery current must not render missing readings as null." >&2
  exit 1
fi

for pattern in \
  "batteryVoltageText(getVoltage())" \
  "private static String batteryVoltageText(int millivolts)" \
  "String.format(Locale.US, \"%.1fV\", millivolts / 1000.0f)" \
  "return \"Unknown\";"; do
  if ! grep -Fq "$pattern" "$MAIN_ACTIVITY"; then
    printf '%s\n' "Missing voltage display contract: $pattern" >&2
    exit 1
  fi
done

for pattern in \
  "batteryCurrentText(CurrentReader.getValue())" \
  "private static String batteryCurrentText(Long currentValue)" \
  "if (currentValue == null)" \
  "return String.valueOf(currentValue);"; do
  if ! grep -Fq "$pattern" "$MAIN_ACTIVITY"; then
    printf '%s\n' "Missing current display contract: $pattern" >&2
    exit 1
  fi
done

if [ -f "$ROOT_DIR/app/src/main/res/menu/menu_main.xml" ]; then
  printf '%s\n' "Unused starter menu resource must not be restored." >&2
  exit 1
fi

for image in battery_icon battery_red battery_orange battery_green; do
  if [ ! -f "$RES_DIR/drawable-nodpi/$image.png" ]; then
    printf '%s\n' "Battery image must stay in drawable-nodpi: $image.png" >&2
    exit 1
  fi
done

for removed in ac_charge battery_empty usb; do
  if [ -f "$RES_DIR/drawable/$removed.png" ] || [ -f "$RES_DIR/drawable-nodpi/$removed.png" ]; then
    printf '%s\n' "Unused battery image must not be restored: $removed.png" >&2
    exit 1
  fi
done

if [ -d "$RES_DIR/drawable" ] && find "$RES_DIR/drawable" -name '*.png' | grep -q .; then
  printf '%s\n' "Battery PNG controls must not live in density-scaled drawable/." >&2
  exit 1
fi

if grep -Fq 'android:background="#ecf0f1"' "$LAYOUT"; then
  printf '%s\n' "Screen background must live in the theme to avoid layout overdraw." >&2
  exit 1
fi

if grep -Eq 'android:text="[^@]' "$LAYOUT"; then
  printf '%s\n' "Layout text must use string resources." >&2
  exit 1
fi

if grep -Eq 'paddingLeft|layout_marginLeft|layout_marginRight' "$LAYOUT"; then
  printf '%s\n' "Layout spacing must use start/end attributes." >&2
  exit 1
fi

if ! grep -Fq 'android:contentDescription="@string/battery_indicator_description"' "$LAYOUT"; then
  printf '%s\n' "Battery indicator must have an accessibility description." >&2
  exit 1
fi

if ! grep -Fq "LintError" "$ROOT_DIR/app/lint.xml"; then
  printf '%s\n' "lint.xml must document the obsolete lint API database limitation." >&2
  exit 1
fi

if ! grep -Fq "IconMissingDensityFolder" "$ROOT_DIR/app/lint.xml"; then
  printf '%s\n' "lint.xml must document the nodpi bitmap asset baseline." >&2
  exit 1
fi

if ! grep -Fq "./gradlew lint --no-daemon" "$README"; then
  printf '%s\n' "README must document Gradle lint verification." >&2
  exit 1
fi

if ! grep -Fq "./gradlew test --no-daemon" "$README"; then
  printf '%s\n' "README must document Gradle test verification." >&2
  exit 1
fi

if ! grep -Fq "./gradlew assembleDebug --no-daemon" "$README"; then
  printf '%s\n' "README must document Gradle build verification." >&2
  exit 1
fi

if ! grep -Fq "clamped to the 0 through 100 display range" "$README"; then
  printf '%s\n' "README must document battery percentage clamping." >&2
  exit 1
fi

printf '%s\n' "Battery receiver lifecycle checks passed."
