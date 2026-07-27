# ADR 0004: iOS Companion App with Clipboard-Based Signature Delivery

## Status

Accepted

## Context

The Mac app keeps Apple Mail signatures fresh via AppleScript (ADR 0002).
Users also read and write mail on iPhone and iPad, where the signature is a
single plain-text field in Settings → Mail → Signature. iOS offers no
automation surface for it: no AppleScript, no Shortcuts action, no Mail
extension point, and no background scheduling reliable enough for
wall-clock rotation.

Options considered for bringing rotation to iOS:

1. **No iOS app** — rely on iCloud's "sync signatures" from the Mac.
   Rejected: the synced content is whatever quote the Mac last pushed, and
   users without the Mac app running get nothing.
2. **Companion app that renders and copies** — reuse the Domain,
   Application, and Infrastructure targets; replace the Mail layer with a
   copy button and a paste instruction. Chosen.
3. **Web/clipboard widget or share extension** — smaller surface but the
   same manual paste step, without library or profile management.

## Decision

Add a universal iPhone/iPad SwiftUI app at
`Apps/iOS/DynamicSignatureMobile.xcodeproj`:

- The package declares `.iOS(.v17)` alongside `.macOS(.v14)`. The app
  links `DynamicSignatureDomain`, `DynamicSignatureApplication`, and
  `DynamicSignatureInfrastructure` as local package products.
  `DynamicSignatureMail` (AppleScript, AppKit) and the menu bar target are
  never built for iOS.
- `RotationService` is reused with a no-op `MailSignatureUpdating`
  implementation: rotation still selects quotes, records state, and tracks
  usage; delivery is the user copying a rendered signature and pasting it
  into Settings → Mail → Signature.
- Overdue rotations are caught up when the app enters the foreground
  (`scenePhase`), mirroring the Mac app's timer-based catch-up.
- Storage is the same JSON files (`quotes.json`, `profiles.json`,
  `rotation-state.json`) in the app sandbox's Application Support
  directory. Devices do not sync; the export/import JSON format is the
  transfer mechanism.
- The Xcode project uses file-system-synchronized groups, so new Swift
  files under `Apps/iOS/DynamicSignatureMobile/` join the target without
  project edits.

## Consequences

- Quote rotation on iOS is manual-delivery: the app can prepare a fresh
  signature but cannot install it. The paste step is documented in-app.
- The shared layers must stay Foundation-only; anything AppKit- or
  AppleScript-flavored belongs in `DynamicSignatureMail` or the Mac app
  target.
- Profiles keep their `signatureName` field on iOS for data compatibility,
  where it is only a label.
- CI builds of the iOS app require an Xcode toolchain with the iOS SDK
  (`xcodebuild -scheme DynamicSignatureMobile`); `swift build`/`swift test`
  continue to cover the shared layers on macOS.
