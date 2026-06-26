#!/bin/sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
BUILD_DIR=${TMPDIR:-/tmp}/android-battery-host-test.$$
trap 'rm -rf "$BUILD_DIR"' EXIT HUP INT TERM

mkdir -p "$BUILD_DIR/classes"

if javac -source 7 -target 7 -encoding UTF-8 -d "$BUILD_DIR/classes" \
    "$ROOT_DIR/host-tests/src/android/content/BroadcastReceiver.java" \
    "$ROOT_DIR/host-tests/src/android/content/Context.java" \
    "$ROOT_DIR/host-tests/src/android/content/Intent.java" \
    "$ROOT_DIR/host-tests/src/android/os/Build.java" \
    "$ROOT_DIR/host-tests/src/android/util/Log.java" \
    "$ROOT_DIR/app/src/main/java/garethpaul/com/chargeme/mBatInfoReceiver.java" \
    "$ROOT_DIR/app/src/main/java/garethpaul/com/chargeme/BatteryTelemetry.java" \
    "$ROOT_DIR/app/src/main/java/garethpaul/com/chargeme/OneLineReader.java" \
    "$ROOT_DIR/app/src/main/java/garethpaul/com/chargeme/SMemTextReader.java" \
    "$ROOT_DIR/app/src/main/java/garethpaul/com/chargeme/CurrentReader.java" \
    "$ROOT_DIR/host-tests/src/garethpaul/com/chargeme/BatteryHostTest.java"; then
  :
else
  exit $?
fi

JAVA_LOG="$BUILD_DIR/java.log"
if java -cp "$BUILD_DIR/classes" garethpaul.com.chargeme.BatteryHostTest >"$JAVA_LOG" 2>&1; then
  cat "$JAVA_LOG"
  exit 0
else
  java_status=$?
fi

cat "$JAVA_LOG" >&2
if grep -Fq "java.lang.AssertionError" "$JAVA_LOG" && \
   grep -Fq "garethpaul.com.chargeme.BatteryHostTest" "$JAVA_LOG"; then
  exit 42
fi
exit "$java_status"
