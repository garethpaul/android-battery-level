#!/bin/sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
BUILD_DIR=${TMPDIR:-/tmp}/android-battery-host-test.$$
trap 'rm -rf "$BUILD_DIR"' EXIT HUP INT TERM

mkdir -p "$BUILD_DIR/classes"

javac -source 7 -target 7 -d "$BUILD_DIR/classes" \
  "$ROOT_DIR/host-tests/src/android/os/Build.java" \
  "$ROOT_DIR/host-tests/src/android/util/Log.java" \
  "$ROOT_DIR/app/src/main/java/garethpaul/com/chargeme/BatteryTelemetry.java" \
  "$ROOT_DIR/app/src/main/java/garethpaul/com/chargeme/OneLineReader.java" \
  "$ROOT_DIR/app/src/main/java/garethpaul/com/chargeme/SMemTextReader.java" \
  "$ROOT_DIR/app/src/main/java/garethpaul/com/chargeme/CurrentReader.java" \
  "$ROOT_DIR/host-tests/src/garethpaul/com/chargeme/BatteryHostTest.java"

java -cp "$BUILD_DIR/classes" garethpaul.com.chargeme.BatteryHostTest
