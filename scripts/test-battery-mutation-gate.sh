#!/bin/sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
WORK_DIR=${TMPDIR:-/tmp}/android-battery-mutation-gate.$$
trap 'rm -rf "$WORK_DIR"' EXIT HUP INT TERM

mkdir -p "$WORK_DIR"

write_tool_wrappers() {
  failing_tool=$1
  wrapper_dir="$WORK_DIR/$failing_tool/bin"
  state_file="$WORK_DIR/$failing_tool/invocations"
  mkdir -p "$wrapper_dir"
  cat > "$wrapper_dir/javac" <<EOF
#!/bin/sh
if [ "$failing_tool" != javac ]; then
  exit 0
fi
count=0
if [ -f "$state_file" ]; then
  count=\$(cat "$state_file")
fi
count=\$((count + 1))
printf '%s\n' "\$count" > "$state_file"
if [ "\$count" -eq 1 ]; then
  exit 0
fi
printf '%s\n' "injected javac failure after successful preflight" >&2
exit 73
EOF
  cat > "$wrapper_dir/java" <<EOF
#!/bin/sh
if [ "$failing_tool" != java ]; then
  printf '%s\n' "BatteryHostTest: simulated assertions passed"
  exit 0
fi
count=0
if [ -f "$state_file" ]; then
  count=\$(cat "$state_file")
fi
count=\$((count + 1))
printf '%s\n' "\$count" > "$state_file"
if [ "\$count" -eq 1 ]; then
  printf '%s\n' "BatteryHostTest: simulated assertions passed"
  exit 0
fi
printf '%s\n' "injected java failure after successful preflight" >&2
exit 73
EOF
  chmod +x "$wrapper_dir/javac" "$wrapper_dir/java"
}

assert_late_tool_failure_is_not_a_killed_mutation() {
  tool=$1
  log="$WORK_DIR/$tool.log"
  write_tool_wrappers "$tool"

  if PATH="$WORK_DIR/$tool/bin:$PATH" "$ROOT_DIR/scripts/test-battery-mutations.sh" >"$log" 2>&1; then
    printf '%s\n' "Mutation gate accepted a post-preflight $tool failure." >&2
    cat "$log" >&2
    return 1
  fi
  if ! grep -Fq "Mutation infrastructure failed: current-unit" "$log"; then
    printf '%s\n' "Mutation gate did not classify the post-preflight $tool failure." >&2
    cat "$log" >&2
    return 1
  fi
}

assert_preflight_failure_fails_closed() {
  wrapper_dir="$WORK_DIR/preflight-failure/bin"
  log="$WORK_DIR/preflight-failure.log"
  mkdir -p "$wrapper_dir"
  cat > "$wrapper_dir/javac" <<'EOF'
#!/bin/sh
printf '%s\n' "injected preflight javac failure" >&2
exit 73
EOF
  cat > "$wrapper_dir/java" <<'EOF'
#!/bin/sh
exit 0
EOF
  chmod +x "$wrapper_dir/javac" "$wrapper_dir/java"

  if PATH="$wrapper_dir:$PATH" "$ROOT_DIR/scripts/test-battery-mutations.sh" >"$log" 2>&1; then
    printf '%s\n' "Mutation gate returned success after a failed preflight." >&2
    cat "$log" >&2
    return 1
  fi
  if ! grep -Fq "Battery host tests must pass before mutation testing." "$log"; then
    printf '%s\n' "Mutation gate did not report the failed preflight." >&2
    cat "$log" >&2
    return 1
  fi
}

assert_commented_preflight_decoy_is_rejected() {
  probe_root="$WORK_DIR/commented-preflight"
  log="$WORK_DIR/commented-preflight.log"
  mkdir -p "$probe_root"
  tar -C "$ROOT_DIR" --exclude=.git -cf - . | tar -C "$probe_root" -xf -
  perl -0pi -e 's/^run_preflight$/# run_preflight/m' \
    "$probe_root/scripts/test-battery-mutations.sh"

  if "$probe_root/scripts/check-baseline.sh" >"$log" 2>&1; then
    printf '%s\n' "Baseline accepted a commented preflight decoy." >&2
    return 1
  fi
  if ! grep -Fq "Battery mutation gate must prove the unmutated host baseline before mutating." "$log"; then
    printf '%s\n' "Baseline rejected the decoy for an unrelated reason." >&2
    cat "$log" >&2
    return 1
  fi
}

failures=0
assert_preflight_failure_fails_closed || failures=$((failures + 1))
assert_late_tool_failure_is_not_a_killed_mutation javac || failures=$((failures + 1))
assert_late_tool_failure_is_not_a_killed_mutation java || failures=$((failures + 1))
assert_commented_preflight_decoy_is_rejected || failures=$((failures + 1))

if [ "$failures" -ne 0 ]; then
  printf '%s\n' "Battery mutation gate regressions failed: $failures" >&2
  exit 1
fi

printf '%s\n' "Battery mutation gate regressions passed."
