PROJECT := TypeWrong
SCHEME := TypeWrongApp
TEST_SCHEME := TypeWrongApp
APP_BUNDLE_ID := com.fam.TypeWrong
APP_PATH := build/DerivedData/Build/Products/Debug-iphonesimulator/TypeWrongApp.app
DESTINATION ?= generic/platform=iOS Simulator
TEST_DESTINATION ?= platform=iOS Simulator,name=iPhone 17
DERIVED_DATA_PATH ?= build/DerivedData

.PHONY: build generate rebuild install-sim test destinations simulators clean

build:
	xcodebuild \
		-project $(PROJECT).xcodeproj \
		-scheme $(SCHEME) \
		-destination '$(DESTINATION)' \
		-derivedDataPath $(DERIVED_DATA_PATH) \
		CODE_SIGNING_ALLOWED=NO \
		build

rebuild:
	rm -rf $(DERIVED_DATA_PATH)
	$(MAKE) build DESTINATION='$(DESTINATION)' DERIVED_DATA_PATH='$(DERIVED_DATA_PATH)'

generate:
	xcodegen generate

install-sim:
	xcrun simctl uninstall booted $(APP_BUNDLE_ID) || true
	xcrun simctl install booted $(APP_PATH)
	xcrun simctl launch booted $(APP_BUNDLE_ID)

test:
	xcodebuild \
		-project $(PROJECT).xcodeproj \
		-scheme $(TEST_SCHEME) \
		-destination '$(TEST_DESTINATION)' \
		-derivedDataPath $(DERIVED_DATA_PATH) \
		CODE_SIGNING_ALLOWED=NO \
		test

destinations:
	xcodebuild \
		-showdestinations \
		-project $(PROJECT).xcodeproj \
		-scheme $(SCHEME)

simulators:
	xcrun simctl list devices available

clean:
	rm -rf build
