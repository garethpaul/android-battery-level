#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
MAIN_ACTIVITY="$ROOT_DIR/app/src/main/java/garethpaul/com/chargeme/MainActivity.java"
BAT_INFO_RECEIVER="$ROOT_DIR/app/src/main/java/garethpaul/com/chargeme/mBatInfoReceiver.java"
CURRENT_READER="$ROOT_DIR/app/src/main/java/garethpaul/com/chargeme/CurrentReader.java"
BATTERY_TELEMETRY="$ROOT_DIR/app/src/main/java/garethpaul/com/chargeme/BatteryTelemetry.java"
ONE_LINE_READER="$ROOT_DIR/app/src/main/java/garethpaul/com/chargeme/OneLineReader.java"
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
LEVEL_DISPLAY_PLAN="$ROOT_DIR/docs/plans/2026-06-12-battery-level-unavailable-display.md"
READER_LOG_PLAN="$ROOT_DIR/docs/plans/2026-06-13-battery-reader-log-redaction.md"
CURRENT_FALLBACK_PLAN="$ROOT_DIR/docs/plans/2026-06-14-battery-current-source-fallback.md"
READER_FINALLY_PLAN="$ROOT_DIR/docs/plans/2026-06-14-battery-reader-finally-cleanup.md"
DEVICE_VERIFICATION_PLAN="$ROOT_DIR/docs/plans/2026-06-14-battery-device-verification-checklist.md"
MODEL_FALLBACK_PLAN="$ROOT_DIR/docs/plans/2026-06-14-battery-model-fallback.md"
ZERO_VOLTAGE_PLAN="$ROOT_DIR/docs/plans/2026-06-14-battery-zero-voltage-fallback.md"
DEVICE_NAME_FALLBACK_PLAN="$ROOT_DIR/docs/plans/2026-06-15-battery-device-name-fallback.md"
LAUNCHER_EXPORT_PLAN="$ROOT_DIR/docs/plans/2026-06-15-explicit-launcher-export.md"
PLUGGED_DISPLAY_PLAN="$ROOT_DIR/docs/plans/2026-06-13-battery-plugged-unavailable-display.md"
TECHNOLOGY_DISPLAY_PLAN="$ROOT_DIR/docs/plans/2026-06-13-battery-technology-normalization.md"
LIVE_STATUS_PLAN="$ROOT_DIR/docs/plans/2026-06-13-battery-live-status-refresh.md"
CI_PLAN="$ROOT_DIR/docs/plans/2026-06-10-ci-baseline.md"
HOSTED_ANDROID_PLAN="$ROOT_DIR/docs/plans/2026-06-12-hosted-android-verification.md"
WRAPPER_PLAN="$ROOT_DIR/docs/plans/2026-06-12-gradle-wrapper-verification.md"
CI_WORKFLOW="$ROOT_DIR/.github/workflows/check.yml"
CODEOWNERS="$ROOT_DIR/.github/CODEOWNERS"
GRADLEW="$ROOT_DIR/gradlew"
GRADLEW_BAT="$ROOT_DIR/gradlew.bat"
WRAPPER_JAR="$ROOT_DIR/gradle/wrapper/gradle-wrapper.jar"
WRAPPER_PROPERTIES="$ROOT_DIR/gradle/wrapper/gradle-wrapper.properties"
HOST_TEST="$ROOT_DIR/scripts/test-battery-host.sh"
MUTATION_TEST="$ROOT_DIR/scripts/test-battery-mutations.sh"

for required_path in \
  "$BATTERY_TELEMETRY" \
  "$HOST_TEST" \
  "$MUTATION_TEST" \
  "$ROOT_DIR/DEVICE_VERIFICATION.md" \
  "$DEVICE_VERIFICATION_PLAN" \
  "$MODEL_FALLBACK_PLAN" \
  "$ZERO_VOLTAGE_PLAN" \
  "$DEVICE_NAME_FALLBACK_PLAN"; do
  if [ ! -f "$required_path" ]; then
    printf '%s\n' "Required file is missing: ${required_path#"$ROOT_DIR/"}" >&2
    exit 1
  fi
done

if [ "$(grep -Fc '$(ROOT)scripts/test-battery-host.sh' "$ROOT_DIR/Makefile")" -ne 1 ] || \
   [ "$(grep -Fc '$(ROOT)scripts/test-battery-mutations.sh' "$ROOT_DIR/Makefile")" -ne 1 ]; then
  printf '%s\n' "Makefile test must run host behavior and mutation gates." >&2
  exit 1
fi

for device_contract in \
  'commit SHA and pull request' \
  'Missing or invalid level' \
  'Missing plugged extra' \
  'Earlier source invalid' \
  'Repeated refresh' \
  'Rotate during updates' \
  'Do not convert `not run` into passing evidence.' \
  'sysfs paths, malformed sensor values' \
  'every battery device and current-source row as' \
  'unexecuted'; do
  if ! grep -Fq "$device_contract" "$ROOT_DIR/DEVICE_VERIFICATION.md"; then
    printf '%s\n' "Battery device checklist must keep contract: $device_contract" >&2
    exit 1
  fi
done

if ! grep -Fq 'DEVICE_VERIFICATION.md' "$README" || \
   ! grep -Fq 'explicit unexecuted rows' "$README" || \
   ! grep -Fqi 'battery device verification matrix' "$VISION" || \
   ! grep -Fq 'every runtime row explicitly unexecuted' "$CHANGES"; then
  printf '%s\n' 'Repository guidance must document the unexecuted battery device matrix.' >&2
  exit 1
fi

for plan_contract in \
  'Status: Completed' \
  'make check' \
  'hostile mutations' \
  'No Android SDK, emulator, physical-device, battery-state, or current-source scenario was executed'; do
  if ! grep -Fq "$plan_contract" "$DEVICE_VERIFICATION_PLAN"; then
    printf '%s\n' "Battery device plan must keep completion evidence: $plan_contract" >&2
    exit 1
  fi
done

sha256_file() {
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$1" | awk '{print $1}'
  elif command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$1" | awk '{print $1}'
  else
    printf '%s\n' "A SHA-256 utility is required for wrapper verification." >&2
    exit 1
  fi
}

expected_wrapper_properties() {
  cat <<'EOF'
distributionBase=GRADLE_USER_HOME
distributionPath=wrapper/dists
distributionSha256Sum=1d7c28b3731906fd1b2955946c1d052303881585fc14baedd675e4cf2bc1ecab
distributionUrl=https\://services.gradle.org/distributions/gradle-2.2.1-all.zip
networkTimeout=10000
validateDistributionUrl=true
zipStoreBase=GRADLE_USER_HOME
zipStorePath=wrapper/dists
EOF
}

expected_ci_workflow() {
  cat <<'EOF'
name: Check

on:
  push:
    branches:
      - master
  pull_request:
  workflow_dispatch:

permissions:
  contents: read

env:
  FORCE_JAVASCRIPT_ACTIONS_TO_NODE24: true

concurrency:
  group: check-${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true

jobs:
  check:
    runs-on: ubuntu-24.04
    timeout-minutes: 15
    steps:
      - name: Check out repository
        uses: actions/checkout@df4cb1c069e1874edd31b4311f1884172cec0e10 # v6.0.3
        with:
          persist-credentials: false

      - name: Install Android SDK packages
        run: '"${ANDROID_HOME}/cmdline-tools/latest/bin/sdkmanager" "platform-tools" "platforms;android-22" "build-tools;24.0.3"'

      - name: Set up Java 8
        uses: actions/setup-java@be666c2fcd27ec809703dec50e508c2fdc7f6654 # v5.2.0
        with:
          distribution: corretto
          java-version: "8"

      - name: Run full verification
        run: make check
EOF
}

expected_current_sources() {
  cat <<'EOF'
f = new File("/sys/class/power_supply/battery/batt_current");
f = new File("/sys/devices/platform/ds2784-battery/getcurrent");
f = new File("/sys/devices/platform/i2c-adapter/i2c-0/0-0036/power_supply/ds2746-battery/current_now");
f = new File("/sys/devices/platform/i2c-adapter/i2c-0/0-0036/power_supply/battery/current_now");
f = new File("/sys/class/power_supply/battery/smem_text");
f = new File("/sys/class/power_supply/battery/batt_current");
f = new File("/sys/class/power_supply/battery/current_now");
f = new File("/sys/class/power_supply/battery/batt_chg_current");
f = new File("/sys/class/power_supply/battery/charger_current");
f = new File("/sys/class/power_supply/max17042-0/current_now");
EOF
}

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
  "mBatInfoReceiver receiver = myBatInfoReceiver;" \
  "batteryReceiverRegistered = false;" \
  "unregisterReceiver(receiver);" \
  'Log.e("ChargeMe", "battery receiver unregister failed");' \
  "private static Intent batteryStatusIntent(Context context)" \
  "private int batteryLevelPercent(Intent batteryStatus)" \
  "batteryStatus == null" \
  "BatteryManager.EXTRA_SCALE"; do
  if ! grep -Fq "$pattern" "$MAIN_ACTIVITY"; then
    printf '%s\n' "Missing lifecycle guard pattern: $pattern" >&2
    exit 1
  fi
done

if ! grep -Fq 'return BatteryTelemetry.voltageText(millivolts);' "$MAIN_ACTIVITY" || \
   ! grep -Fq 'millivolts <= 0 || millivolts > MAX_VOLTAGE_MILLIVOLTS' "$BATTERY_TELEMETRY"; then
  printf '%s\n' "Battery voltage must reject unavailable and implausible readings before formatting." >&2
  exit 1
fi

for zero_voltage_document in "$README" "$SECURITY" "$VISION" "$CHANGES"; do
  if ! grep -Fq "non-positive voltage" "$zero_voltage_document"; then
    printf '%s\n' "$zero_voltage_document must document the non-positive voltage fallback." >&2
    exit 1
  fi
done

for zero_voltage_plan_contract in "Status: Completed" "make check" "mutations"; do
  if ! grep -Fqi "$zero_voltage_plan_contract" "$ZERO_VOLTAGE_PLAN"; then
    printf '%s\n' "Zero-voltage fallback plan must preserve completion evidence: $zero_voltage_plan_contract" >&2
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

MANIFEST="$ROOT_DIR/app/src/main/AndroidManifest.xml"
exported_count=$(awk '
  {
    line = $0
    while (match(line, /android:exported=/)) {
      count++
      line = substr(line, RSTART + RLENGTH)
    }
  }
  END { print count + 0 }
' "$MANIFEST")
if [ "$exported_count" -ne 1 ]; then
  printf '%s\n' "Battery app must declare exactly one explicit component export boundary." >&2
  exit 1
fi
if ! awk '
  /<activity([[:space:]>]|$)/ {
    in_activity = 1
    name = 0
    exported = 0
    main_action = 0
    launcher_category = 0
  }
  in_activity && /android:name="\.MainActivity"/ { name = 1 }
  in_activity && /android:exported="true"/ { exported++ }
  in_activity && /android.intent.action.MAIN/ { main_action = 1 }
  in_activity && /android.intent.category.LAUNCHER/ { launcher_category = 1 }
  in_activity && /<\/activity>/ {
    if (name && exported == 1 && main_action && launcher_category) {
      valid_launcher++
    }
    in_activity = 0
  }
  END { exit !(valid_launcher == 1) }
' "$MANIFEST"; then
  printf '%s\n' "Battery launcher activity must be explicitly exported with its MAIN/LAUNCHER filter." >&2
  exit 1
fi
if grep -Fq 'android:exported="false"' "$MANIFEST"; then
  printf '%s\n' "Battery launcher activity must remain externally reachable." >&2
  exit 1
fi

for launcher_export_document in \
  "$ROOT_DIR/AGENTS.md" "$README" "$SECURITY" "$VISION" "$CHANGES"; do
  if ! grep -Fq "explicit launcher export boundary" "$launcher_export_document"; then
    printf '%s\n' "$launcher_export_document must document the explicit launcher export boundary." >&2
    exit 1
  fi
done
for launcher_export_plan_contract in \
  "status: completed" \
  'android:exported="true"' \
  'repository and external-directory `make check` passed' \
  "hostile mutations were rejected"; do
  if ! grep -Fq "$launcher_export_plan_contract" "$LAUNCHER_EXPORT_PLAN"; then
    printf '%s\n' "Battery launcher export plan must preserve completion evidence: $launcher_export_plan_contract" >&2
    exit 1
  fi
done

if grep -Fq "level > 31" "$MAIN_ACTIVITY"; then
  printf '%s\n' "Battery icon threshold must not skip levels 30 and 31." >&2
  exit 1
fi

if grep -Fq "return Math.round((rawLevel * 100.0f) / scale);" "$MAIN_ACTIVITY"; then
  printf '%s\n' "Battery level display must clamp normalized percentages." >&2
  exit 1
fi

if ! grep -Fq "Math.max(0L, Math.min(100L, roundedPercent));" "$BATTERY_TELEMETRY"; then
  printf '%s\n' "Battery level percentages must be clamped to 0 through 100." >&2
  exit 1
fi

LEVEL_FORMATTER=$(sed -n \
  '/private static String batteryLevelText(int levelPercent)/,/private static String batteryStatusText/p' \
  "$MAIN_ACTIVITY")

if ! grep -Fq "levelText.setText(batteryLevelText(level));" "$MAIN_ACTIVITY"; then
  printf '%s\n' "Battery level text must use the unavailable-data formatter." >&2
  exit 1
fi

for level_display_contract in \
  "private static String batteryLevelText(int levelPercent)" \
  "if (levelPercent < 0)" \
  'return "Unknown";' \
  "return String.valueOf(levelPercent);"; do
  if ! printf '%s\n' "$LEVEL_FORMATTER" | grep -Fq "$level_display_contract"; then
    printf '%s\n' "Battery level unavailable display must keep contract: $level_display_contract" >&2
    exit 1
  fi
done

if grep -Fq "levelText.setText(String.valueOf(level));" "$MAIN_ACTIVITY"; then
  printf '%s\n' "Battery level text must not expose the internal unavailable sentinel." >&2
  exit 1
fi

ICON_SELECTOR=$(sed -n \
  '/ImageView batteryImage =/,/TextView batteryTemp =/p' \
  "$MAIN_ACTIVITY")
for unavailable_icon_contract in \
  "if (level < 0)" \
  "batteryImage.setImageResource(R.drawable.battery_icon);"; do
  if ! printf '%s\n' "$ICON_SELECTOR" | grep -Fq "$unavailable_icon_contract"; then
    printf '%s\n' "Unavailable battery level must keep neutral icon contract: $unavailable_icon_contract" >&2
    exit 1
  fi
done

if [ ! -f "$LEVEL_DISPLAY_PLAN" ] || \
   ! grep -Fq "Status: Completed" "$LEVEL_DISPLAY_PLAN" || \
   ! grep -Fq "make check" "$LEVEL_DISPLAY_PLAN"; then
  printf '%s\n' "Battery level unavailable display plan must record completed make check verification." >&2
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

workflow_paths=$(find "$ROOT_DIR/.github/workflows" -type f \( -name '*.yml' -o -name '*.yaml' \) -print)
if [ "$workflow_paths" != "$CI_WORKFLOW" ]; then
  printf '%s\n' "check.yml must remain the only approved GitHub Actions workflow." >&2
  exit 1
fi

if [ "$(cat "$CI_WORKFLOW")" != "$(expected_ci_workflow)" ]; then
  printf '%s\n' "GitHub Actions check workflow must match the approved full Android security baseline." >&2
  exit 1
fi

if [ ! -f "$CI_PLAN" ] || \
   ! grep -Fq "Status: Completed" "$CI_PLAN" || \
   ! grep -Fq "build-tools 24.0.3" "$CI_PLAN" || \
   ! grep -Fq 'complete `make check` gate' "$CI_PLAN"; then
  printf '%s\n' "Battery CI baseline plan must document the complete hosted Android gate." >&2
  exit 1
fi

if [ ! -f "$HOSTED_ANDROID_PLAN" ] || \
   ! grep -Fq "Status: Completed" "$HOSTED_ANDROID_PLAN" || \
   ! grep -Fq "make check" "$HOSTED_ANDROID_PLAN" || \
   ! grep -Fq "OldTargetApi" "$HOSTED_ANDROID_PLAN" || \
   ! grep -Fq 'GitHub Actions `pull_request` run `27401524940` passed' "$HOSTED_ANDROID_PLAN" || \
   ! grep -Fq "b9a9611d39b80a690ba2cb3f022d23851c34241c" "$HOSTED_ANDROID_PLAN"; then
  printf '%s\n' "Hosted battery verification plan must record completed local and hosted evidence." >&2
  exit 1
fi

if [ ! -x "$GRADLEW" ] || [ ! -f "$GRADLEW_BAT" ] || \
   [ ! -f "$WRAPPER_JAR" ] || [ ! -f "$WRAPPER_PROPERTIES" ]; then
  printf '%s\n' "Generated Gradle wrapper files must be present and gradlew must be executable." >&2
  exit 1
fi

if [ "$(cat "$WRAPPER_PROPERTIES")" != "$(expected_wrapper_properties)" ]; then
  printf '%s\n' "Gradle wrapper properties must retain the reviewed Gradle 2.2.1 URL and checksum." >&2
  exit 1
fi

if [ "$(sha256_file "$WRAPPER_JAR")" != "7d3a4ac4de1c32b59bc6a4eb8ecb8e612ccd0cf1ae1e99f66902da64df296172" ]; then
  printf '%s\n' "Gradle wrapper JAR must match Gradle's published 8.14.5 wrapper checksum." >&2
  exit 1
fi

if [ "$(sha256_file "$GRADLEW")" != "b187b4c52e749f5760afdd6fadc31b2a98ad35fb249bf0dff03b72650f320409" ] || \
   [ "$(sha256_file "$GRADLEW_BAT")" != "94102713eb8fb22d032397924c0f38ab2da783ba60d07054339f1190a0c4e2cd" ]; then
  printf '%s\n' "Gradle wrapper launchers must match the reviewed generated scripts." >&2
  exit 1
fi

if ! grep -Fq "Gradle start up script for POSIX generated by Gradle." "$GRADLEW" || \
   ! grep -Fq "Gradle startup script for Windows" "$GRADLEW_BAT"; then
  printf '%s\n' "Gradle wrapper launchers must retain generated-script provenance markers." >&2
  exit 1
fi

if [ ! -f "$WRAPPER_PLAN" ] || \
   ! grep -Fq "status: completed" "$WRAPPER_PLAN" || \
   ! grep -Fq "fresh temporary Gradle user home" "$WRAPPER_PLAN" || \
   ! grep -Fq "rejected the deliberately incorrect distribution checksum" "$WRAPPER_PLAN" || \
   ! grep -Fq 'SDK-backed `make check` passed' "$WRAPPER_PLAN" || \
   ! grep -Fq "external working directory" "$WRAPPER_PLAN" || \
   ! grep -Fq "hostile mutation checks rejected" "$WRAPPER_PLAN" || \
   ! grep -Fq 'pull-request `Check` run `27439059851` passed' "$WRAPPER_PLAN" || \
   ! grep -Fq 'CodeQL run `27439056892` passed' "$WRAPPER_PLAN" || \
   ! grep -Fq "064cd895e2895ca962da4a5dbd49ed3a721eebac" "$WRAPPER_PLAN"; then
  printf '%s\n' "Gradle wrapper verification plan must record completed local verification evidence." >&2
  exit 1
fi

if ! grep -Fq "distributionSha256Sum" "$README" || \
   ! grep -Fq "does not make the first build offline-reproducible" "$README" || \
   ! grep -Fq "2026-06-12-gradle-wrapper-verification.md" "$README" || \
   ! grep -Fq "wrapper JAR and Gradle distribution checksums" "$SECURITY"; then
  printf '%s\n' "Repository docs must describe wrapper verification and its online dependency boundary." >&2
  exit 1
fi

if ! grep -Fq "canonical GitHub Actions workflow installs Android API 22" "$README" || \
   ! grep -Fq "2026-06-12-hosted-android-verification.md" "$README"; then
  printf '%s\n' "README must document the hosted Android gate and plan." >&2
  exit 1
fi

if [ ! -f "$CODEOWNERS" ] ||
  [ "$(wc -l < "$CODEOWNERS" | tr -d ' ')" -ne 4 ] ||
  ! grep -Fxq '/.github/CODEOWNERS @garethpaul' "$CODEOWNERS" ||
  ! grep -Fxq '/.github/workflows/ @garethpaul' "$CODEOWNERS" ||
  ! grep -Fxq '/Makefile @garethpaul' "$CODEOWNERS" ||
  ! grep -Fxq '/scripts/check-baseline.sh @garethpaul' "$CODEOWNERS"; then
  printf '%s\n' "CODEOWNERS must protect the workflow, Makefile, and baseline checker." >&2
  exit 1
fi

for make_contract in \
  'override ROOT := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))' \
  'ANDROID_HOME ?=' \
  'ANDROID_SDK_ROOT ?=' \
  'GRADLE ?= $(ROOT)gradlew' \
  'ANDROID_SDK := $(if $(ANDROID_HOME),$(ANDROID_HOME),$(ANDROID_SDK_ROOT))'; do
  if ! grep -Fxq "$make_contract" "$ROOT_DIR/Makefile"; then
    printf '%s\n' "Makefile must keep contract: $make_contract" >&2
    exit 1
  fi
done

if [ "$(grep -Fc '$(ROOT)scripts/check-baseline.sh' "$ROOT_DIR/Makefile")" -ne 1 ]; then
  printf '%s\n' "Makefile lint must run the baseline checker from the protected root." >&2
  exit 1
fi
if [ "$(grep -Fc 'cd $(ROOT) && ANDROID_HOME=' "$ROOT_DIR/Makefile")" -ne 3 ]; then
  printf '%s\n' "All three Gradle gates must execute from the protected root." >&2
  exit 1
fi
for gradle_contract in \
  '$(GRADLE) lint --no-daemon' \
  '$(GRADLE) test --no-daemon' \
  '$(GRADLE) assembleDebug --no-daemon'; do
  if [ "$(grep -Fc "$gradle_contract" "$ROOT_DIR/Makefile")" -ne 1 ]; then
    printf '%s\n' "Makefile must keep one rooted Gradle contract: $gradle_contract" >&2
    exit 1
  fi
done
if ! grep -Fxq "Status: Completed" "$ROOT_DIR/docs/plans/2026-06-14-android-battery-make-root-override-protection.md"; then
  printf '%s\n' "Android battery Make root protection plan must record completed status." >&2
  exit 1
fi

if grep -Fq "/home/gjones" "$ROOT_DIR/Makefile"; then
  printf '%s\n' "Makefile must not embed a maintainer-specific Android SDK path." >&2
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

if ! grep -Fq "aaptOptions {" "$ROOT_DIR/app/build.gradle" || \
   ! grep -Fq "useNewCruncher false" "$ROOT_DIR/app/build.gradle"; then
  printf '%s\n' "Legacy Android builds must avoid the nondeterministic queued PNG cruncher." >&2
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

for model_fallback_contract in \
  "return getValue(Build.MODEL, new SourceReader()" \
  'String model = deviceModel == null ? "" : deviceModel.toLowerCase(Locale.US);' \
  'model.contains("desire hd")'; do
  if ! grep -Fq "$model_fallback_contract" "$CURRENT_READER"; then
    printf '%s\n' "CurrentReader must keep model fallback contract: $model_fallback_contract" >&2
    exit 1
  fi
done

device_model_line=$(grep -nF "return getValue(Build.MODEL, new SourceReader()" "$CURRENT_READER" | cut -d: -f1)
normalized_model_line=$(grep -nF 'String model = deviceModel == null ? "" : deviceModel.toLowerCase(Locale.US);' "$CURRENT_READER" | cut -d: -f1)
model_match_line=$(grep -nF 'model.contains("desire hd")' "$CURRENT_READER" | cut -d: -f1)
if [ -z "$device_model_line" ] || [ -z "$normalized_model_line" ] || \
   [ -z "$model_match_line" ] || [ "$device_model_line" -ge "$normalized_model_line" ] || \
   [ "$normalized_model_line" -ge "$model_match_line" ]; then
  printf '%s\n' "CurrentReader must normalize nullable model metadata before model-specific probes." >&2
  exit 1
fi

for model_fallback_document in "$README" "$SECURITY" "$VISION" "$CHANGES"; do
  if ! grep -Fq "missing model metadata preserves generic current probes" \
    "$model_fallback_document"; then
    printf '%s\n' "$model_fallback_document must document missing model current fallback." >&2
    exit 1
  fi
done

for model_fallback_plan_contract in "Status: Completed" "make check" "mutations"; do
  if ! grep -Fqi "$model_fallback_plan_contract" "$MODEL_FALLBACK_PLAN"; then
    printf '%s\n' "Battery model fallback plan must preserve completion evidence: $model_fallback_plan_contract" >&2
    exit 1
  fi
done

for device_name_contract in \
  'return BatteryTelemetry.deviceName(Build.MANUFACTURER, Build.MODEL);' \
  'static String deviceName(String manufacturerValue, String modelValue)' \
  'hasRejectedContent(manufacturerValue)' \
  'hasRejectedContent(modelValue)' \
  'model.toLowerCase(Locale.US).startsWith(manufacturer.toLowerCase(Locale.US))' \
  'return capitalize(manufacturer) + " " + capitalize(model);'; do
  if ! grep -Fq "$device_name_contract" "$MAIN_ACTIVITY" "$BATTERY_TELEMETRY"; then
    printf '%s\n' "Battery device-name policy must keep contract: $device_name_contract" >&2
    exit 1
  fi
done

if ! grep -Fq 'Character.isISOControl(character)' "$BATTERY_TELEMETRY" || \
   ! grep -Fq 'Character.getType(character) == Character.FORMAT' "$BATTERY_TELEMETRY"; then
  printf '%s\n' "Battery vendor labels must reject control and format characters." >&2
  exit 1
fi

for device_name_document in "$README" "$SECURITY" "$CHANGES"; do
  if ! grep -Fq "missing device identity metadata falls back to the available value or \`Unknown\`" \
    "$device_name_document"; then
    printf '%s\n' "$device_name_document must document the device-name fallback." >&2
    exit 1
  fi
done

for device_name_plan_contract in \
  "Status: Completed" \
  "make check" \
  "hostile mutations" \
  "No physical-device Build metadata was exercised"; do
  if ! grep -Fqi "$device_name_plan_contract" "$DEVICE_NAME_FALLBACK_PLAN"; then
    printf '%s\n' "Battery device-name plan must preserve completion evidence: $device_name_plan_contract" >&2
    exit 1
  fi
done

for fallback_contract in \
  "interface SourceReader" \
  "if (!source.exists())" \
  "return OneLineReader.getValue(source, divisor);" \
  "BatteryTelemetry.isCurrentPlausible(value)"; do
  if ! grep -Fq "$fallback_contract" "$CURRENT_READER"; then
    printf '%s\n' "CurrentReader must keep source fallback contract: $fallback_contract" >&2
    exit 1
  fi
done
if [ "$(grep -Fc 'BatteryTelemetry.isCurrentPlausible(value)' "$CURRENT_READER")" -ne 2 ] || \
   [ "$(grep -Fc 'sourceReader.read(path, divisor)' "$CURRENT_READER")" -ne 1 ]; then
  printf '%s\n' "CurrentReader must continue after unavailable or implausible source reads." >&2
  exit 1
fi

for microamp_path in \
  '/sys/devices/platform/ds2784-battery/getcurrent' \
  '/sys/devices/platform/i2c-adapter/i2c-0/0-0036/power_supply/ds2746-battery/current_now' \
  '/sys/devices/platform/i2c-adapter/i2c-0/0-0036/power_supply/battery/current_now' \
  '/sys/class/power_supply/battery/current_now' \
  '/sys/class/power_supply/max17042-0/current_now'; do
  if ! grep -Fq "$microamp_path" "$CURRENT_READER"; then
    printf '%s\n' "CurrentReader must preserve current source: $microamp_path" >&2
    exit 1
  fi
done
if ! grep -Fq 'int[] divisors = {1000, 1000, 1000, 1, 1, 1000, 1, 1, 1000};' "$CURRENT_READER"; then
  printf '%s\n' "CurrentReader must convert standard current_now microamps to milliamps." >&2
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
  "batteryStatus.getIntExtra(BatteryManager.EXTRA_VOLTAGE, -1)" \
  "private static String batteryVoltageText(int millivolts)" \
  "return BatteryTelemetry.voltageText(millivolts);" \
  "return \"Unknown\";"; do
  if ! grep -Fq "$pattern" "$MAIN_ACTIVITY" "$BATTERY_TELEMETRY"; then
    printf '%s\n' "Missing voltage display contract: $pattern" >&2
    exit 1
  fi
done

for pattern in \
  "batteryCurrentText(CurrentReader.getValue())" \
  "private static String batteryCurrentText(Long currentValue)" \
  "return BatteryTelemetry.currentText(currentValue);" \
  "isCurrentPlausible(Long currentValue)"; do
  if ! grep -Fq "$pattern" "$MAIN_ACTIVITY" "$BATTERY_TELEMETRY"; then
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
  "BatteryManager.EXTRA_TECHNOLOGY"; do
  if ! grep -Fq "$pattern" "$MAIN_ACTIVITY"; then
    printf '%s\n' "Missing battery status/technology display contract: $pattern" >&2
    exit 1
  fi
done

if ! grep -A6 "private static String batteryTechnologyText(Intent batteryStatus)" "$MAIN_ACTIVITY" | grep -Fq "if (batteryStatus == null)"; then
  printf '%s\n' "Battery technology display helper must tolerate missing battery intents." >&2
  exit 1
fi

technology_method=$(sed -n \
  '/private static String batteryTechnologyText(Intent batteryStatus)/,/^    }/p' \
  "$MAIN_ACTIVITY")
technology_compact=$(printf '%s\n' "$technology_method" | tr -d '[:space:]')
for technology_contract in \
  'returnBatteryTelemetry.normalizedLabel(' \
  'batteryStatus.getStringExtra(BatteryManager.EXTRA_TECHNOLOGY));'; do
  if ! printf '%s\n' "$technology_compact" | grep -Fq "$technology_contract"; then
    printf '%s\n' "Battery technology display must keep normalized contract: $technology_contract" >&2
    exit 1
  fi
done

if ! grep -Fq 'MAX_LABEL_LENGTH = 80' "$BATTERY_TELEMETRY"; then
  printf '%s\n' "Battery technology display must bound vendor-controlled labels." >&2
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

plugged_method=$(sed -n \
  '/private static String batteryPluggedText(int chargePlug)/,/^    }/p' \
  "$MAIN_ACTIVITY")
plugged_compact=$(printf '%s\n' "$plugged_method" | tr -d '[:space:]')
for plugged_contract in \
  'caseBatteryManager.BATTERY_PLUGGED_AC:return"ACCharging";' \
  'caseBatteryManager.BATTERY_PLUGGED_USB:return"USBCharging";' \
  'caseBatteryManager.BATTERY_PLUGGED_WIRELESS:return"WirelessCharging";' \
  'case0:return"OnBattery";' \
  'default:return"Unknown";'; do
  if ! printf '%s\n' "$plugged_compact" | grep -Fq "$plugged_contract"; then
    printf '%s\n' "Battery plugged-state display must keep contract: $plugged_contract" >&2
    exit 1
  fi
done

if ! grep -Fq "BatteryManager.EXTRA_PLUGGED, -1" "$MAIN_ACTIVITY"; then
  printf '%s\n' "Missing plugged-state data must keep the unavailable sentinel." >&2
  exit 1
fi

if printf '%s\n' "$plugged_method" | sed -n '/default:/,$p' | grep -Fq 'return "On Battery";'; then
  printf '%s\n' "The plugged-state default must not report unavailable data as on battery." >&2
  exit 1
fi

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

if grep -Eq '(^|[^A-Za-z])(temp|get_temp|receivedTemperature)([^A-Za-z]|$)' "$BAT_INFO_RECEIVER"; then
  printf '%s\n' "Battery receiver must not retain a duplicate temperature cache." >&2
  exit 1
fi

for live_status_contract in \
  "interface BatteryStatusListener" \
  "batteryStatusListener.onBatteryStatusChanged(intent);"; do
  if ! grep -Fq "$live_status_contract" "$BAT_INFO_RECEIVER"; then
    printf '%s\n' "Battery receiver live updates must keep contract: $live_status_contract" >&2
    exit 1
  fi
done

if [ "$(grep -Fc 'batteryStatusListener.onBatteryStatusChanged(intent);' "$BAT_INFO_RECEIVER")" -ne 1 ]; then
  printf '%s\n' "Battery receiver must deliver each non-null full status exactly once." >&2
  exit 1
fi

for activity_status_contract in \
  "implements mBatInfoReceiver.BatteryStatusListener" \
  "new mBatInfoReceiver(this)" \
  "private void renderBatteryStatus(Intent batteryStatus)" \
  "public void onBatteryStatusChanged(Intent batteryStatus)" \
  "renderBatteryStatus(batteryStatus);"; do
  if ! grep -Fq "$activity_status_contract" "$MAIN_ACTIVITY"; then
    printf '%s\n' "Battery activity live status updates must keep contract: $activity_status_contract" >&2
    exit 1
  fi
done

if ! awk '
  /private void setup\(\)/ { in_setup = 1 }
  /private void renderBatteryStatus\(Intent batteryStatus\)/ { in_setup = 0; in_render = 1 }
  /private static Intent batteryStatusIntent\(Context context\)/ { in_render = 0 }
  in_setup && /registerBatteryReceiver\(\);/ { register_receiver = NR }
  /Intent batteryStatus = this\.registerReceiver/ { sticky_register = NR }
  /renderBatteryStatus\(batteryStatus\);/ { initial_render = NR }
  in_render && /batteryLevelPercent\(batteryStatus\)/ { level = NR }
  in_render && /BatteryManager.EXTRA_STATUS/ { status = NR }
  in_render && /BatteryManager.EXTRA_HEALTH/ { health = NR }
  in_render && /BatteryManager.EXTRA_PLUGGED/ { plugged = NR }
  in_render && /batteryTemperatureText\(batteryStatus\)/ { temperature = NR }
  in_render && /BatteryManager.EXTRA_VOLTAGE/ { voltage = NR }
  in_render && /batteryTechnologyText\(batteryStatus\)/ { technology = NR }
  END {
    exit !(register_receiver && sticky_register && initial_render && sticky_register < initial_render &&
      level && status && health && plugged && temperature && voltage && technology)
  }
' "$MAIN_ACTIVITY"; then
  printf '%s\n' "Battery broadcasts must render all intent-backed fields from the supplied status intent." >&2
  exit 1
fi

if [ ! -f "$LIVE_STATUS_PLAN" ] || \
   ! grep -Fq "status: completed" "$LIVE_STATUS_PLAN" || \
   ! grep -Fq "## Verification Completed" "$LIVE_STATUS_PLAN" || \
   ! grep -Fq "make check" "$LIVE_STATUS_PLAN" || \
   ! grep -Fq "hostile mutations" "$LIVE_STATUS_PLAN"; then
  printf '%s\n' "Battery live-status plan must record completed verification." >&2
  exit 1
fi

for live_status_doc in "$README" "$SECURITY" "$VISION" "$CHANGES"; do
  if ! tr '\n' ' ' < "$live_status_doc" | tr -s '[:space:]' ' ' | \
      grep -Fiq "full battery display from each live broadcast"; then
    printf '%s\n' "$live_status_doc must document full live battery refreshes." >&2
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

if ! grep -Fq 'return BatteryTelemetry.temperatureText(temperatureTenths);' "$MAIN_ACTIVITY" || \
   ! grep -Fq 'temperatureTenths < MIN_TEMPERATURE_TENTHS' "$BATTERY_TELEMETRY"; then
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

if [ "$(grep -Fc 'Log.e("CurrentWidget"' "$BATT_ATTR_TEXT_READER" || true)" -ne 4 ] || \
   [ "$(grep -Fc 'Log.e("CurrentWidget"' "$ONE_LINE_READER" || true)" -ne 3 ] || \
   [ "$(grep -Fc 'Log.e("CurrentWidget"' "$SMEM_TEXT_READER" || true)" -ne 3 ]; then
  printf '%s\n' "Battery text readers must keep exactly ten reviewed generic error logs." >&2
  exit 1
fi
invalid_current_count=$((
  $(grep -Fc '"invalid battery current value"' "$ONE_LINE_READER" || true) +
  $(grep -Fc '"invalid battery current value"' "$SMEM_TEXT_READER" || true)
))
current_read_count=$((
  $(grep -Fc '"battery current read failed"' "$ONE_LINE_READER" || true) +
  $(grep -Fc '"battery current read failed"' "$SMEM_TEXT_READER" || true)
))
if [ "$(grep -Fc '"invalid battery attribute value"' "$BATT_ATTR_TEXT_READER" || true)" -ne 2 ] || \
   [ "$(grep -Fc '"battery attribute read failed"' "$BATT_ATTR_TEXT_READER" || true)" -ne 1 ] || \
   [ "$invalid_current_count" -ne 2 ] || \
   [ "$current_read_count" -ne 2 ]; then
  printf '%s\n' "Battery text readers must keep exact generic read and parse categories." >&2
  exit 1
fi
for reader in "$BATT_ATTR_TEXT_READER" "$ONE_LINE_READER" "$SMEM_TEXT_READER"; do
  for sensitive_log in "getMessage()" "printStackTrace()" "Log.getStackTraceString" ", ex);" ", nfe);"; do
    if grep -Fq "$sensitive_log" "$reader"; then
      printf '%s\n' "$reader must not log exception-derived battery reader details: $sensitive_log" >&2
      exit 1
    fi
  done
done

for reader in "$BATT_ATTR_TEXT_READER" "$ONE_LINE_READER" "$SMEM_TEXT_READER"; do
  if [ "$(grep -Fc "BufferedReader br = null;" "$reader" || true)" -ne 1 ] || \
     [ "$(grep -Fc "} finally {" "$reader" || true)" -ne 1 ] || \
     [ "$(grep -Fc "if (br != null)" "$reader" || true)" -ne 1 ] || \
     [ "$(grep -Fc "br.close();" "$reader" || true)" -ne 1 ] || \
     [ "$(grep -Fc 'Log.e("CurrentWidget", "battery reader close failed");' "$reader" || true)" -ne 1 ]; then
    printf '%s\n' "$reader must close its reader once from a guarded finally block." >&2
    exit 1
  fi
  if grep -Eq '(fr|fs|sr)\.close\(\);' "$reader"; then
    printf '%s\n' "$reader must rely on the buffered reader to close subordinate streams." >&2
    exit 1
  fi
  if ! awk '
    /} finally \{/ { finally_line = NR }
    /if \(br != null\)/ { guard = NR }
    /br\.close\(\);/ { close_line = NR }
    /battery reader close failed/ { close_log = NR }
    END {
      exit !(finally_line && guard && close_line && close_log &&
        finally_line < guard && guard < close_line && close_line < close_log)
    }
  ' "$reader"; then
    printf '%s\n' "$reader must order guarded close and generic logging inside finally." >&2
    exit 1
  fi
done

if [ ! -f "$READER_LOG_PLAN" ] || \
   ! grep -Fq "Status: Completed" "$READER_LOG_PLAN" || \
   ! grep -Fq "make check" "$READER_LOG_PLAN" || \
   ! grep -Fq "hostile mutations" "$READER_LOG_PLAN"; then
  printf '%s\n' "Battery reader log-redaction plan must record completed verification." >&2
  exit 1
fi

if [ ! -f "$CURRENT_FALLBACK_PLAN" ] || \
   ! grep -Fq "Status: Completed" "$CURRENT_FALLBACK_PLAN" || \
   ! grep -Fq "make check" "$CURRENT_FALLBACK_PLAN" || \
   ! grep -Fq "focused hostile mutations" "$CURRENT_FALLBACK_PLAN"; then
  printf '%s\n' "Battery current source fallback plan must record completed verification." >&2
  exit 1
fi

if [ ! -f "$READER_FINALLY_PLAN" ] || \
   ! grep -Fq "Status: Completed" "$READER_FINALLY_PLAN" || \
   ! grep -Fq "make check" "$READER_FINALLY_PLAN" || \
   ! grep -Fq "hostile mutations" "$READER_FINALLY_PLAN"; then
  printf '%s\n' "Battery reader finally-cleanup plan must record completed verification." >&2
  exit 1
fi

for reader_doc in "$README" "$SECURITY" "$CHANGES"; do
  if ! tr '\n' ' ' < "$reader_doc" | tr -s '[:space:]' ' ' | \
      grep -Fiq "generic battery reader failure logs"; then
    printf '%s\n' "$reader_doc must document generic battery reader failure logs." >&2
    exit 1
  fi
done

for reader_cleanup_doc in "$README" "$SECURITY" "$VISION" "$CHANGES"; do
  if ! grep -Fq "Battery text readers close from finally blocks" "$reader_cleanup_doc"; then
    printf '%s\n' "$reader_cleanup_doc must document exception-safe reader cleanup." >&2
    exit 1
  fi
done

if [ ! -f "$PLUGGED_DISPLAY_PLAN" ] || \
   ! grep -Fq "Status: Completed" "$PLUGGED_DISPLAY_PLAN" || \
   ! grep -Fq "make check" "$PLUGGED_DISPLAY_PLAN" || \
   ! grep -Fq "hostile mutations" "$PLUGGED_DISPLAY_PLAN"; then
  printf '%s\n' "Battery plugged-state display plan must record completed verification." >&2
  exit 1
fi

for plugged_doc in "$ROOT_DIR/AGENTS.md" "$README" "$SECURITY" "$VISION" "$CHANGES"; do
  if ! tr '\n' ' ' < "$plugged_doc" | tr -s '[:space:]' ' ' | \
      grep -Fiq "unavailable charging-source data"; then
    printf '%s\n' "$plugged_doc must distinguish unavailable charging-source data." >&2
    exit 1
  fi
done

if [ ! -f "$TECHNOLOGY_DISPLAY_PLAN" ] || \
   ! grep -Fq "status: completed" "$TECHNOLOGY_DISPLAY_PLAN" || \
   ! grep -Fq "## Verification Completed" "$TECHNOLOGY_DISPLAY_PLAN" || \
   ! grep -Fq "make check" "$TECHNOLOGY_DISPLAY_PLAN" || \
   ! grep -Fq "Six focused hostile mutations" "$TECHNOLOGY_DISPLAY_PLAN" || \
   ! grep -Fq "generated-artifact and credential-shaped" "$TECHNOLOGY_DISPLAY_PLAN"; then
  printf '%s\n' "Battery technology normalization plan must record completed verification." >&2
  exit 1
fi

for technology_doc in "$README" "$SECURITY" "$VISION" "$CHANGES"; do
  normalized_technology_doc=$(tr '\n' ' ' < "$technology_doc" | tr -s '[:space:]' ' ')
  if ! printf '%s\n' "$normalized_technology_doc" | grep -Fiq "technology" || \
     ! printf '%s\n' "$normalized_technology_doc" | grep -Fiq "trim" || \
     ! printf '%s\n' "$normalized_technology_doc" | grep -Fiq "whitespace"; then
    printf '%s\n' "$technology_doc must document trimmed technology and whitespace fallback behavior." >&2
    exit 1
  fi
done

printf '%s\n' "Battery receiver lifecycle checks passed."
