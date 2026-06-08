#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
MAIN_ACTIVITY="$ROOT_DIR/app/src/main/java/garethpaul/com/chargeme/MainActivity.java"

if grep -A3 "public void onPause()" "$MAIN_ACTIVITY" | grep -Fq "setup();"; then
  printf '%s\n' "onPause must unregister the battery receiver instead of calling setup()." >&2
  exit 1
fi

if grep -A3 "public void onStop()" "$MAIN_ACTIVITY" | grep -Fq "setup();"; then
  printf '%s\n' "onStop must unregister the battery receiver instead of calling setup()." >&2
  exit 1
fi

for pattern in \
  "private boolean batteryReceiverRegistered;" \
  "private void registerBatteryReceiver()" \
  "private void unregisterBatteryReceiver()" \
  "unregisterReceiver(myBatInfoReceiver);"; do
  if ! grep -Fq "$pattern" "$MAIN_ACTIVITY"; then
    printf '%s\n' "Missing lifecycle guard pattern: $pattern" >&2
    exit 1
  fi
done

if ! grep -Fq 'buildToolsVersion "24.0.3"' "$ROOT_DIR/app/build.gradle"; then
  printf '%s\n' "Android build-tools must stay pinned to 24.0.3 for 64-bit aapt." >&2
  exit 1
fi

if ! grep -Fq "Android build-tools 24.0.3" "$ROOT_DIR/README.md"; then
  printf '%s\n' "README must document the pinned Android build-tools version." >&2
  exit 1
fi

printf '%s\n' "Battery receiver lifecycle checks passed."
