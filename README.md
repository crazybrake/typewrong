# TypeWrong

TypeWrong is an iPhone app with a custom system keyboard extension.

The keyboard looks like a standard Russian JCUKEN layout, but it inserts English characters by physical key position on a US QWERTY keyboard.

Examples:

- `пароль` -> `gfhjkm`
- `привет` -> `ghbdtn`

## Project Structure

The project contains two programs:

- `TypeWrongApp`
  - The host iOS app.
  - Shows onboarding text and a test input area.
  - Exists mainly so iOS can install and expose the keyboard extension.

- `TypeWrongKeyboard`
  - The custom iOS keyboard extension.
  - Displays Russian keycaps.
  - Inserts Latin characters mapped by keyboard position.

- `TypeWrongTests`
  - Unit tests for the positional Russian-to-English mapping.
  - Verifies examples and the standard computer JCUKEN mapping.

## How It Works

The keyboard does not transliterate by sound or dictionary rules.

It maps each Russian key to the English symbol that would be produced from the same physical key on a US keyboard:

- `ё -> \``
- `й -> q`
- `ц -> w`
- `у -> e`
- `п -> g`
- `р -> h`
- `и -> b`

That is why `привет` becomes `ghbdtn`.

## Requirements

- macOS with Xcode installed
- Xcode command line tools
- `xcodegen`

Check the tools:

```bash
xcodebuild -version
xcodegen --version
```

If Xcode was just installed or updated, run:

```bash
xcodebuild -runFirstLaunch
```

## Generate The Project

This repository stores the XcodeGen spec in `project.yml`.

Generate `TypeWrong.xcodeproj` from CLI:

```bash
xcodegen generate
```

Or:

```bash
make generate
```

## Build From CLI

List available simulators:

```bash
xcrun simctl list devices available
```

Or:

```bash
make simulators
```

Show destinations visible to the scheme:

```bash
xcodebuild -showdestinations \
  -project TypeWrong.xcodeproj \
  -scheme TypeWrongApp
```

Or:

```bash
make destinations
```

Build for a specific simulator:

```bash
xcodebuild \
  -project TypeWrong.xcodeproj \
  -scheme TypeWrongApp \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  build
```

Or:

```bash
make
make build
make build DESTINATION='platform=iOS Simulator,name=iPhone 15 Pro'
```

The default `make` target is `build`.

The `make build` target is incremental. It writes `DerivedData` into the local `build/DerivedData` directory and disables code signing for simulator builds.

If device names vary on your machine, replace `iPhone 17` with one of the names returned by `simctl`.

You can also build using a simulator UUID:

```bash
xcodebuild \
  -project TypeWrong.xcodeproj \
  -scheme TypeWrongApp \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,id=SIMULATOR-UUID' \
  build
```

The default `make build` target uses `generic/platform=iOS Simulator`, which is more robust than hardcoding a device name. Override it only when you need a specific simulator.

The `make test` target is different: `xcodebuild test` requires a concrete simulator, so the default test destination is `platform=iOS Simulator,name=iPhone 17`.

For a forced clean rebuild:

```bash
make rebuild
```

Run unit tests:

```bash
make test
make test TEST_DESTINATION='platform=iOS Simulator,name=iPhone 15 Pro'
```

## Run On A Simulator From CLI

Boot a simulator:

```bash
xcrun simctl boot 'iPhone 17'
```

Open Simulator.app:

```bash
open -a Simulator
```

Build and launch from Xcode, or install with more explicit CLI tooling after a successful build.

Install the built app into the currently booted simulator and launch it:

```bash
make install-sim
```

To clean build products:

```bash
make clean
```

## Install And Enable The Keyboard

After the app is installed on an iPhone or simulator:

1. Open `Settings`.
2. Go to `General -> Keyboard -> Keyboards`.
3. Tap `Add New Keyboard`.
4. Select `TypeWrong Keyboard`.
5. In any text field, switch keyboards using the globe button.

## iOS Limitations

- Custom keyboards do not appear in every input context.
- Secure text fields may force the Apple system keyboard.
- Some system apps and protected fields restrict custom keyboard behavior.

## Main Source Files

- `AGENTS.md` - task definition and implementation scope
- `Makefile` - convenient CLI entry points for generate/build/clean
- `TypeWrongTests/KeyboardLayoutTests.swift` - mapping regression tests
- `project.yml` - XcodeGen project spec
- `TypeWrongApp/ContentView.swift` - host app UI and setup instructions
- `TypeWrongApp/TypeWrongApp.swift` - app entry point
- `TypeWrongKeyboard/KeyboardLayout.swift` - Russian-to-English positional mapping
- `TypeWrongKeyboard/KeyboardViewController.swift` - keyboard extension controller
- `TypeWrongKeyboard/KeyboardButton.swift` - key button UI
- `TypeWrongKeyboard/Info.plist` - extension metadata

## Troubleshooting

### Xcode cannot find a destination

If `xcodebuild` reports that no valid iOS destination is available, install the required iOS platform and simulator runtime in:

- `Xcode -> Settings -> Components`

Then rerun:

```bash
xcodebuild -showdestinations \
  -project TypeWrong.xcodeproj \
  -scheme TypeWrongApp
```

### Xcode plugin or runtime mismatch after update

Run:

```bash
xcodebuild -runFirstLaunch
```

If that is not enough, reopen Xcode and let it finish any pending component installation.
