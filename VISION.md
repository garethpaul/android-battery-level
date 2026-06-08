## Android Battery Level Vision

Android Battery Level is a legacy Android app that displays battery health,
charge source, current, temperature, voltage, and device model information.

The repository is useful as a small example of reading battery broadcasts and
presenting device power state. Project setup and verification notes live in
[`README.md`](README.md).

The goal is to keep the battery-status sample buildable, accurate, and easy to
modernize without losing the original signal it demonstrates.

The current focus is:

Priority:

- Preserve the documented legacy Android build stack
- Keep broadcast receiver lifecycle handling correct
- Maintain an SDK-free baseline check for quick verification
- Keep displayed battery values clear and traceable to Android system inputs

Next priorities:

- Modernize Gradle, SDK levels, and Android plugin versions in a dedicated pass
- Add tests for battery formatting and lifecycle edge cases
- Review behavior across charging states and newer Android versions
- Improve UI labels without changing the sample's simple purpose

Contribution rules:

- One PR = one focused change.
- Run `scripts/check-baseline.sh` before pushing.
- Run `./gradlew tasks --no-daemon` and `./gradlew assembleDebug --no-daemon`
  when a compatible Android SDK is configured.
- Document any Android API behavior change that affects reported values.

## Security And Privacy

Battery state is low-risk compared with account or location data, but device
model and power information should still be treated as local diagnostic data.
Do not add network reporting, analytics, or logging of device details without a
clear reason and explicit documentation.

## What We Will Not Merge (For Now)

- Analytics or telemetry built on battery/device information
- UI rewrites that make the sample harder to inspect
- Build migrations bundled with unrelated behavior changes
- Verification gate removals without equivalent replacement checks
