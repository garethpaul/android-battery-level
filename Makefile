.PHONY: build check lint test verify

ANDROID_HOME ?= /home/gjones/android-sdk
GRADLE ?= ./gradlew

lint:
	scripts/check-baseline.sh
	@if [ -d "$(ANDROID_HOME)" ]; then \
		ANDROID_HOME="$(ANDROID_HOME)" $(GRADLE) lint --no-daemon; \
	else \
		echo "Android SDK not found at $(ANDROID_HOME); Gradle lint skipped."; \
	fi

test:
	@if [ -d "$(ANDROID_HOME)" ]; then \
		ANDROID_HOME="$(ANDROID_HOME)" $(GRADLE) test --no-daemon; \
	else \
		echo "Android SDK not found at $(ANDROID_HOME); Gradle tests skipped."; \
	fi

build:
	@if [ -d "$(ANDROID_HOME)" ]; then \
		ANDROID_HOME="$(ANDROID_HOME)" $(GRADLE) assembleDebug --no-daemon; \
	else \
		echo "Android SDK not found at $(ANDROID_HOME); Gradle build skipped."; \
	fi

verify: lint test build

check: verify
