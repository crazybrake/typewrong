# TypeWrong

## Goal

Build and maintain an iPhone app with a custom system keyboard
extension.

The keyboard layout should visually follow the standard Russian
JCUKEN layout, but it must insert English characters based on key
position on a US QWERTY keyboard.

Examples:

- `пароль` -> `gfhjkm`
- `привет` -> `ghbdtn`

## Current State

- Host iOS app with setup instructions and a test input area.
- Custom iPhone keyboard extension.
- Standard Russian computer keycaps with positional Latin output.
- Letter layer, `123` layer, and `#+=` layer.
- `Shift`, `Caps Lock`, `Backspace`, `Space`, `Return`, and globe
  switcher support.
- Unit tests for the mapping layer.
- GitHub Actions workflow for generate, build, and test steps.

## Technical Notes

- Platform: iOS
- UI stack: SwiftUI for the host app, UIKit for the keyboard extension
- Project generation: XcodeGen
- Local workflow: `make`, `make build`, `make generate`,
  `make install-sim`, `make test`
- Main architecture:
  - Positional Russian-to-English mapper in `KeyboardLayout`
  - Keyboard UI and behavior in `KeyboardViewController`
  - Host app onboarding and test surface in SwiftUI

## Constraints

- iOS custom keyboards cannot fully replace the system keyboard in
  every context.
- Secure text fields and some system-controlled inputs may force the
  default Apple keyboard.
- First version is portrait-first and optimized for iPhone.
- System surfaces may apply their own appearance, sizing, and behavior
  around the keyboard extension.
- The goal is to stay close to the system keyboard UX, not to clone it
  exactly.

## Verification

- Generate project: `make generate`
- Build app: `make` or `make build`
- Install into the booted simulator: `make install-sim`
- Run tests on a concrete simulator destination: `make test`

## Next Improvements

- Long-press repeat for backspace.
- Key popup previews on touch-down.
- Further geometry tuning to better match system keyboard proportions.
- More refinement for edge-case system contexts in Simulator and iOS.
