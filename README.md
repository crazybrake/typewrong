# TypeWrong

Custom iPhone keyboard that shows a Russian JCUKEN layout but types English
characters by physical key position.

`привет` becomes `ghbdtn`.  
`пароль` becomes `gfhjkm`.

## What It Is

TypeWrong is an iOS app with a custom keyboard extension for users who
think in Russian keyboard positions but need English output.

The on-screen keycaps follow the standard Russian computer layout. The
inserted text follows the matching US QWERTY positions instead of phonetic
transliteration.

This is positional remapping, not transliteration by pronunciation or
dictionary rules.

## How It Works

Examples:

- `ё -> \``
- `й -> q`
- `ц -> w`
- `у -> e`
- `п -> g`
- `р -> h`
- `и -> b`

So:

- `привет -> ghbdtn`
- `пароль -> gfhjkm`

## Project Layout

- `TypeWrongApp`
  Host iOS app with setup instructions and a test input area.

- `TypeWrongKeyboard`
  Custom iOS keyboard extension.

- `TypeWrongTests`
  Unit tests for the positional mapping layer.

## Requirements

- macOS
- Xcode
- Xcode command line tools
- `xcodegen`

Check the toolchain:

```bash
xcodebuild -version
xcodegen --version
```

If Xcode was just installed or updated:

```bash
xcodebuild -runFirstLaunch
```

## Local Development

Generate the Xcode project:

```bash
make generate
```

Build:

```bash
make
make build
```

Build for a specific simulator:

```bash
make build DESTINATION='platform=iOS Simulator,name=iPhone 15 Pro'
```

Rebuild from scratch:

```bash
make rebuild
```

List simulators:

```bash
make simulators
```

Show available scheme destinations:

```bash
make destinations
```

Run tests:

```bash
make test
make test TEST_DESTINATION='platform=iOS Simulator,name=iPhone 15 Pro'
```

Note: `make build` uses `generic/platform=iOS Simulator`, but `make test`
needs a concrete simulator destination because `xcodebuild test` cannot run
against a generic simulator target.

## Install In Simulator

Build first, then install and launch the app in the currently booted
simulator:

```bash
make build
make install-sim
```

If needed:

```bash
xcrun simctl boot 'iPhone 17'
open -a Simulator
```

## Enable The Keyboard

After installing the app on a device or simulator:

1. Open `Settings`.
2. Go to `General -> Keyboard -> Keyboards`.
3. Tap `Add New Keyboard`.
4. Select `TypeWrong`.
5. In any text field, switch keyboards with the globe button.

## Limitations

- iOS custom keyboards do not appear in every input context.
- Secure text fields may force the system keyboard.
- Some system surfaces apply their own keyboard appearance and sizing
  behavior.

## Testing

Mapping coverage lives in `TypeWrongTests/KeyboardLayoutTests.swift`.

The tests verify:

- the documented examples
- the standard Russian computer layout mapping
- uppercase behavior
- passthrough for unrelated characters

## CI

GitHub Actions configuration lives in `.github/workflows/ci.yml`.

The workflow:

1. installs `xcodegen`
2. generates the project
3. builds the app for testing
4. runs tests on the first available iPhone simulator

## Main Files

- `project.yml` — XcodeGen project spec
- `Makefile` — local build, test, and simulator commands
- `TypeWrongKeyboard/KeyboardLayout.swift` — positional Russian-to-English
  mapping
- `TypeWrongKeyboard/KeyboardViewController.swift` — keyboard extension UI
  and behavior
- `TypeWrongTests/KeyboardLayoutTests.swift` — mapping regression tests
- `AGENTS.md` — task notes and implementation scope

## Troubleshooting

If Xcode cannot find a simulator destination, install the required iOS
platform and simulator runtime in:

- `Xcode -> Settings -> Components`

Then rerun:

```bash
make destinations
```
