# Android Battery Level

<!-- README-OVERVIEW-IMAGE -->
![Project overview](docs/readme-overview.svg)

Legacy Android app that displays battery health, charge source, current,
temperature, voltage, and device model information.

## Toolchain

This project currently uses the original Android build stack:

- Gradle wrapper 2.2.1
- Android Gradle Plugin 1.1.0
- compile SDK 22 / target SDK 22
- Android build-tools 24.0.3

Configure an Android SDK path before running Gradle:

```sh
export ANDROID_HOME=/path/to/android-sdk
```

or create an untracked `local.properties` file:

```properties
sdk.dir=/path/to/android-sdk
```

## Verify

Run the SDK-free source baseline check first:

```sh
scripts/check-baseline.sh
```

Then run Gradle after Android SDK configuration is available:

```sh
./gradlew lint --no-daemon
./gradlew test --no-daemon
./gradlew assembleDebug --no-daemon
```

If Gradle reports `SDK location not found`, configure `ANDROID_HOME` or
`local.properties` and rerun the command.

## Modernization Notes

The current baseline fixes broadcast receiver lifecycle handling and keeps
Android lint clean for the legacy battery UI resources. `app/lint.xml`
suppresses only the obsolete lint API database error from this old toolchain and
the missing-density-folder warning for bitmap assets intentionally kept in
`drawable-nodpi`. A future pass should modernize Gradle, SDK levels, runtime
permission handling, battery formatting logic, and Android test coverage in an
SDK-capable environment.
