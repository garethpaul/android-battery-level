.PHONY: build check lint test verify

ANDROID_HOME ?=
GRADLE ?= ./gradlew

lint:
	scripts/check-baseline.sh
	@if [ -n "$(ANDROID_HOME)" ] && [ -d "$(ANDROID_HOME)" ]; then \
		ANDROID_HOME="$(ANDROID_HOME)" $(GRADLE) lint --no-daemon; \
	else \
		echo "Android SDK not configured; Gradle lint skipped."; \
	fi

test:
	@if [ -n "$(ANDROID_HOME)" ] && [ -d "$(ANDROID_HOME)" ]; then \
		ANDROID_HOME="$(ANDROID_HOME)" $(GRADLE) test --no-daemon; \
	else \
		echo "Android SDK not configured; Gradle tests skipped."; \
	fi

build:
	@if [ -n "$(ANDROID_HOME)" ] && [ -d "$(ANDROID_HOME)" ]; then \
		ANDROID_HOME="$(ANDROID_HOME)" $(GRADLE) assembleDebug --no-daemon; \
	else \
		echo "Android SDK not configured; Gradle build skipped."; \
	fi

verify: lint test build

check: verify
