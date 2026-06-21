#!/bin/sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
WORK_DIR=${TMPDIR:-/tmp}/android-battery-mutations.$$
trap 'rm -rf "$WORK_DIR"' EXIT HUP INT TERM

run_mutation() {
  name=$1
  expression=$2
  target=$3
  mutation_dir="$WORK_DIR/$name"
  mkdir -p "$mutation_dir/app/src/main/java/garethpaul/com/chargeme" \
    "$mutation_dir/host-tests/src/android/os" \
    "$mutation_dir/host-tests/src/android/util" \
    "$mutation_dir/host-tests/src/garethpaul/com/chargeme" \
    "$mutation_dir/scripts"
  cp "$ROOT_DIR/app/src/main/java/garethpaul/com/chargeme/BatteryTelemetry.java" \
    "$ROOT_DIR/app/src/main/java/garethpaul/com/chargeme/CurrentReader.java" \
    "$ROOT_DIR/app/src/main/java/garethpaul/com/chargeme/OneLineReader.java" \
    "$ROOT_DIR/app/src/main/java/garethpaul/com/chargeme/SMemTextReader.java" \
    "$mutation_dir/app/src/main/java/garethpaul/com/chargeme/"
  cp "$ROOT_DIR/host-tests/src/android/os/Build.java" "$mutation_dir/host-tests/src/android/os/"
  cp "$ROOT_DIR/host-tests/src/android/util/Log.java" "$mutation_dir/host-tests/src/android/util/"
  cp "$ROOT_DIR/host-tests/src/garethpaul/com/chargeme/BatteryHostTest.java" \
    "$mutation_dir/host-tests/src/garethpaul/com/chargeme/"
  cp "$ROOT_DIR/scripts/test-battery-host.sh" "$mutation_dir/scripts/"
  chmod +x "$mutation_dir/scripts/test-battery-host.sh"

  perl -0pi -e "$expression" "$mutation_dir/$target"
  if "$mutation_dir/scripts/test-battery-host.sh" >/dev/null 2>&1; then
    printf '%s\n' "Mutation survived: $name" >&2
    exit 1
  fi
}

if ! "$ROOT_DIR/scripts/test-battery-host.sh" >/dev/null 2>&1; then
  printf '%s\n' "Battery host tests must pass before mutation testing." >&2
  exit 1
fi

run_mutation current-unit 's/int\[\] divisors = \{1000,/int[] divisors = {1,/' \
  app/src/main/java/garethpaul/com/chargeme/CurrentReader.java
run_mutation current-range 's/MAX_CURRENT_MILLIAMPS = 1000000L/MAX_CURRENT_MILLIAMPS = Long.MAX_VALUE/' \
  app/src/main/java/garethpaul/com/chargeme/BatteryTelemetry.java
run_mutation label-format 's/\|\| Character\.getType\(character\) == Character\.FORMAT//' \
  app/src/main/java/garethpaul/com/chargeme/BatteryTelemetry.java
run_mutation voltage-range 's/MAX_VOLTAGE_MILLIVOLTS = 100000/MAX_VOLTAGE_MILLIVOLTS = Integer.MAX_VALUE/' \
  app/src/main/java/garethpaul/com/chargeme/BatteryTelemetry.java
run_mutation temperature-range 's/MAX_TEMPERATURE_TENTHS = 2000/MAX_TEMPERATURE_TENTHS = Integer.MAX_VALUE/' \
  app/src/main/java/garethpaul/com/chargeme/BatteryTelemetry.java
run_mutation percentage-clamp 's/Math\.min\(100L, roundedPercent\)/Math.min(101L, roundedPercent)/' \
  app/src/main/java/garethpaul/com/chargeme/BatteryTelemetry.java

printf '%s\n' "Battery mutations: 6 rejected"
