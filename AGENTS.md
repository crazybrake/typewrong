# TypeWrong

## Goal

Build an iPhone app with a custom system keyboard extension.

The keyboard layout should visually follow the standard Russian JCUKEN layout, but it must insert English characters based on key position on a US QWERTY keyboard.

Examples:

- `пароль` -> `gfhjkm`
- `привет` -> `ghbdtn`

## Product Scope

- Host iOS app that explains setup and activation steps.
- Custom keyboard extension for iPhone.
- Basic Russian visual layout with Latin output.
- Backspace, space, return, and shift support.

## Technical Notes

- Platform: iOS
- UI stack: SwiftUI for the host app, UIKit for the keyboard extension
- Project generation: XcodeGen
- Minimum viable architecture:
  - Shared transliteration-by-position mapper
  - Keyboard view controller
  - Host app with onboarding text

## Constraints

- iOS custom keyboards cannot fully replace the system keyboard in every context.
- Secure text fields and some system-controlled inputs may force the default Apple keyboard.
- First version is portrait-first and optimized for iPhone.

## Immediate Tasks

1. Scaffold iOS app and keyboard extension.
2. Implement Russian-keycap-to-English-output mapping.
3. Add a usable on-screen key grid and basic editing controls.
4. Generate the Xcode project and validate build configuration.
