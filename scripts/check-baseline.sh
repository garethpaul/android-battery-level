#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
MAIN_ACTIVITY="$ROOT_DIR/app/src/main/java/garethpaul/com/chargeme/MainActivity.java"
BAT_INFO_RECEIVER="$ROOT_DIR/app/src/main/java/garethpaul/com/chargeme/mBatInfoReceiver.java"
CURRENT_READER="$ROOT_DIR/app/src/main/java/garethpaul/com/chargeme/CurrentReader.java"
SMEM_TEXT_READER="$ROOT_DIR/app/src/main/java/garethpaul/com/chargeme/SMemTextReader.java"
BATT_ATTR_TEXT_READER="$ROOT_DIR/app/src/main/java/garethpaul/com/chargeme/BattAttrTextReader.java"
LAYOUT="$ROOT_DIR/app/src/main/res/layout/activity_main.xml"
README="$ROOT_DIR/README.md"
VISION="$ROOT_DIR/VISION.md"
SECURITY="$ROOT_DIR/SECURITY.md"
CHANGES="$ROOT_DIR/CHANGES.md"
RES_DIR="$ROOT_DIR/app/src/main/res"
PERCENT_CLAMP_PLAN="$ROOT_DIR/docs/plans/2026-06-09-battery-percent-clamp.md"
BACKUP_PLAN="$ROOT_DIR/docs/plans/2026-06-09-battery-backup-policy.md"
CURRENT_PREFIX_PLAN="$ROOT_DIR/docs/plans/2026-06-09-battery-current-prefix-parsing.md"
INTENT_NULL_PLAN="$ROOT_DIR/docs/plans/2026-06-09-battery-intent-null-guards.md"
CI_PLAN="$ROOT_DIR/docs/plans/2026-06-10-ci-baseline.md"
CI_WORKFLOW="$ROOT_DIR/.github/workflows/check.yml"

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

if ! grep -A5 "private static Intent batteryStatusIntent(Context context)" "$MAIN_ACTIVITY" | grep -Fq "if (context == null)"; then
  printf '%s\n' "Battery status intent helper must tolerate missing contexts." >&2
  exit 1
fi

if grep -Fq "getActionBar().set" "$MAIN_ACTIVITY"; then
  printf '%s\n' "ActionBar configuration must guard nullable getActionBar() results." >&2
  exit 1
fi

if ! grep -Fq 'android:allowBackup="false"' "$ROOT_DIR/app/src/main/AndroidManifest.xml"; then
  printf '%s\n' "Battery app must disable Android backups for local diagnostic state." >&2
  exit 1
fi

if grep -Fq 'android:allowBackup="true"' "$ROOT_DIR/app/src/main/AndroidManifest.xml"; then
  printf '%s\n' "Battery app must not allow Android backups." >&2
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

if ! grep -Fq "status: completed" "$BACKUP_PLAN" || ! grep -Fq "make check" "$BACKUP_PLAN"; then
  printf '%s\n' "Battery backup policy plan must record completed make check verification." >&2
  exit 1
fi

if [ ! -f "$CI_WORKFLOW" ]; then
  printf '%s\n' "GitHub Actions check workflow is missing." >&2
  exit 1
fi

for workflow_contract in \
  "permissions:" \
  "contents: read" \
  "runs-on: ubuntu-24.04" \
  "cancel-in-progress: true" \
  "timeout-minutes: 5" \
  "workflow_dispatch:" \
  "actions/checkout@df4cb1c069e1874edd31b4311f1884172cec0e10" \
  'ANDROID_HOME: ""' \
  'ANDROID_SDK_ROOT: ""' \
  "make check"; do
  if ! grep -Fq "$workflow_contract" "$CI_WORKFLOW"; then
    printf '%s\n' "GitHub Actions check workflow must keep contract: $workflow_contract" >&2
    exit 1
  fi
done

for make_contract in \
  'ROOT := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))' \
  'ANDROID_SDK := $(if $(ANDROID_HOME),$(ANDROID_HOME),$(ANDROID_SDK_ROOT))'; do
  if ! grep -Fq "$make_contract" "$ROOT_DIR/Makefile"; then
    printf '%s\n' "Makefile must keep contract: $make_contract" >&2
    exit 1
  fi
done

if grep -Fq "/home/gjones" "$ROOT_DIR/Makefile"; then
  printf '%s\n' "Makefile must not embed a maintainer-specific Android SDK path." >&2
  exit 1
fi

if ! grep -Fq "GitHub Actions" "$README"; then
  printf '%s\n' "README must document the GitHub Actions check." >&2
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

if ! grep -Fq "local battery diagnostic state out of Android" "$README"; then
  printf '%s\n' "README must document the battery backup policy." >&2
  exit 1
fi

if ! grep -Fq "local battery diagnostic state out of Android" "$VISION"; then
  printf '%s\n' "VISION must document the battery backup policy." >&2
  exit 1
fi

if ! grep -Fq "local battery diagnostic state out of Android" "$SECURITY"; then
  printf '%s\n' "SECURITY must document the battery backup policy." >&2
  exit 1
fi

if ! grep -Fq "local battery diagnostic state out of Android" "$CHANGES"; then
  printf '%s\n' "CHANGES must record the battery backup policy." >&2
  exit 1
fi

if ! grep -Fq "Locale.US" "$CURRENT_READER"; then
  printf '%s\n' "CurrentReader must avoid default-locale model matching." >&2
  exit 1
fi

for pattern in \
  'final String currentFieldHead = "I_MBAT: ";' \
  "line.startsWith(currentFieldHead)" \
  "line.substring(currentFieldHead.length()).trim()"; do
  if ! grep -Fq "$pattern" "$SMEM_TEXT_READER"; then
    printf '%s\n' "Missing smem current field parsing contract: $pattern" >&2
    exit 1
  fi
done

if grep -Fq 'line.contains("I_MBAT")' "$SMEM_TEXT_READER"; then
  printf '%s\n' "SMemTextReader must require the exact I_MBAT field prefix." >&2
  exit 1
fi

for pattern in \
  "line.startsWith(chargeFieldHead)" \
  "line.substring(chargeFieldHead.length()).trim()" \
  "line.startsWith(dischargeFieldHead)" \
  "line.substring(dischargeFieldHead.length()).trim()"; do
  if ! grep -Fq "$pattern" "$BATT_ATTR_TEXT_READER"; then
    printf '%s\n' "Missing batt_attr current field parsing contract: $pattern" >&2
    exit 1
  fi
done

if grep -Fq "line.contains(chargeField)" "$BATT_ATTR_TEXT_READER" || \
   grep -Fq "line.contains(dischargeField)" "$BATT_ATTR_TEXT_READER"; then
  printf '%s\n' "BattAttrTextReader must require exact current field prefixes." >&2
  exit 1
fi

if ! grep -Fq "status: completed" "$CURRENT_PREFIX_PLAN"; then
  printf '%s\n' "Battery current prefix parsing plan must be marked completed." >&2
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

for pattern in \
  "stateText.setText(batteryStatusText(" \
  "BatteryManager.EXTRA_STATUS" \
  "private static String batteryStatusText(int status)" \
  "BatteryManager.BATTERY_STATUS_CHARGING" \
  "BatteryManager.BATTERY_STATUS_DISCHARGING" \
  "BatteryManager.BATTERY_STATUS_FULL" \
  "BatteryManager.BATTERY_STATUS_NOT_CHARGING" \
  "technologyText.setText(batteryTechnologyText(batteryStatus))" \
  "private static String batteryTechnologyText(Intent batteryStatus)" \
  "BatteryManager.EXTRA_TECHNOLOGY" \
  "technology == null || technology.length() == 0"; do
  if ! grep -Fq "$pattern" "$MAIN_ACTIVITY"; then
    printf '%s\n' "Missing battery status/technology display contract: $pattern" >&2
    exit 1
  fi
done

if ! grep -A6 "private static String batteryTechnologyText(Intent batteryStatus)" "$MAIN_ACTIVITY" | grep -Fq "if (batteryStatus == null)"; then
  printf '%s\n' "Battery technology display helper must tolerate missing battery intents." >&2
  exit 1
fi

for pattern in \
  "private static String batteryHealthText(int health)" \
  "private static String batteryPluggedText(int chargePlug)" \
  "BatteryManager.BATTERY_PLUGGED_WIRELESS"; do
  if ! grep -Fq "$pattern" "$MAIN_ACTIVITY"; then
    printf '%s\n' "Missing battery display mapping contract: $pattern" >&2
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

if ! grep -Fq "battery state and technology fields" "$README"; then
  printf '%s\n' "README must document battery state and technology display handling." >&2
  exit 1
fi

if ! grep -Fq "Sticky battery intent helper paths tolerate missing contexts" "$README"; then
  printf '%s\n' "README must document null-safe battery intent helper handling." >&2
  exit 1
fi

if ! grep -Fq "Current text-file readers require exact field prefixes" "$README"; then
  printf '%s\n' "README must document exact current field prefix parsing." >&2
  exit 1
fi

if ! grep -Fq "make check" "$ROOT_DIR/docs/plans/2026-06-09-battery-status-technology-display.md"; then
  printf '%s\n' "Battery status and technology display plan must document make check verification." >&2
  exit 1
fi

if ! grep -Fq "Status: Completed" "$INTENT_NULL_PLAN" || ! grep -Fq "make check" "$INTENT_NULL_PLAN"; then
  printf '%s\n' "Battery intent null guard plan must record completed make check verification." >&2
  exit 1
fi

if ! grep -Fq "if (intent == null)" "$BAT_INFO_RECEIVER"; then
  printf '%s\n' "Battery info receiver must ignore missing broadcast intents." >&2
  exit 1
fi

if grep -Fq "(float)(temp / 10)" "$BAT_INFO_RECEIVER"; then
  printf '%s\n' "Battery info receiver must not truncate tenths before casting temperature." >&2
  exit 1
fi

if ! grep -Fq "return temp / 10.0f;" "$BAT_INFO_RECEIVER"; then
  printf '%s\n' "Battery info receiver must preserve one-decimal temperature values." >&2
  exit 1
fi

if ! grep -Fq "!intent.hasExtra(BatteryManager.EXTRA_TEMPERATURE)" "$BAT_INFO_RECEIVER"; then
  printf '%s\n' "Battery info receiver must explicitly ignore broadcasts without temperature data." >&2
  exit 1
fi

if ! grep -Fq "receivedTemperature != Integer.MIN_VALUE" "$BAT_INFO_RECEIVER"; then
  printf '%s\n' "Battery info receiver must reject invalid temperature sentinels." >&2
  exit 1
fi

for live_temperature_contract in \
  "interface TemperatureListener" \
  "temperatureListener.onTemperatureChanged(receivedTemperature);"; do
  if ! grep -Fq "$live_temperature_contract" "$BAT_INFO_RECEIVER"; then
    printf '%s\n' "Battery receiver live updates must keep contract: $live_temperature_contract" >&2
    exit 1
  fi
done

for activity_temperature_contract in \
  "implements mBatInfoReceiver.TemperatureListener" \
  "new mBatInfoReceiver(this)" \
  "public void onTemperatureChanged(int temperatureTenths)" \
  "batteryTemp.setText(batteryTemperatureText(temperatureTenths));"; do
  if ! grep -Fq "$activity_temperature_contract" "$MAIN_ACTIVITY"; then
    printf '%s\n' "Battery activity live updates must keep contract: $activity_temperature_contract" >&2
    exit 1
  fi
done

if ! grep -Fq "batteryTemperatureText(batteryStatusIntent(context))" "$MAIN_ACTIVITY"; then
  printf '%s\n' "Battery temperature display must use the shared intent formatter." >&2
  exit 1
fi

if ! grep -Fq "!intent.hasExtra(BatteryManager.EXTRA_TEMPERATURE)" "$MAIN_ACTIVITY"; then
  printf '%s\n' "Battery temperature display must reject missing extras." >&2
  exit 1
fi

if ! grep -Fq "temperatureTenths == Integer.MIN_VALUE" "$MAIN_ACTIVITY"; then
  printf '%s\n' "Battery temperature display must reject invalid sentinels." >&2
  exit 1
fi

if ! grep -Fq "Integer.MIN_VALUE);" "$MAIN_ACTIVITY"; then
  printf '%s\n' "Battery temperature extraction must use the invalid-value sentinel." >&2
  exit 1
fi

if ! grep -Fq 'String.format(Locale.US, "%.1f \u2103", temperatureTenths / 10.0f)' "$MAIN_ACTIVITY"; then
  printf '%s\n' "Battery temperature display must preserve one decimal and Celsius units." >&2
  exit 1
fi

if ! grep -Fq "receiver temperature" "$README"; then
  printf '%s\n' "README must document battery receiver temperature handling." >&2
  exit 1
fi

if ! grep -Fq "make check" "$ROOT_DIR/docs/plans/2026-06-09-battery-receiver-temperature-guard.md"; then
  printf '%s\n' "Battery receiver temperature guard plan must document make check verification." >&2
  exit 1
fi

if ! grep -Fq "Status: Completed" "$ROOT_DIR/docs/plans/2026-06-10-battery-live-temperature.md" || \
   ! grep -Fq "make check" "$ROOT_DIR/docs/plans/2026-06-10-battery-live-temperature.md"; then
  printf '%s\n' "Battery live-temperature plan must record completed status and make check verification." >&2
  exit 1
fi

if [ ! -f "$CI_PLAN" ]; then
  printf '%s\n' "Battery CI baseline plan is missing." >&2
  exit 1
fi

if ! grep -Fq "Status: Completed" "$CI_PLAN" || ! grep -Fq "make check" "$CI_PLAN"; then
  printf '%s\n' "Battery CI baseline plan must record completed status and make check verification." >&2
  exit 1
fi

printf '%s\n' "Battery receiver lifecycle checks passed."
