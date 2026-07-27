# Dynamic Signature Manager

A macOS menu bar app that keeps your Apple Mail signatures fresh: it composes
your name/title/contact block plus a rotating quote from an editable quote
library, and pushes it into Apple Mail automatically on a schedule you choose.
Multiple profiles are supported — one identity and signature per mail
account.

## How it works

Apple Mail has no supported plugin API for signatures, so the app maintains
one signature inside Mail per profile (a single **Dynamic Quote** signature
by default) via Apple's scripting interface. You select each profile's
signature for the matching account once; the app keeps the content rotating
from then on.

- **Profiles**: separate identities for work, personal, or any number of
  mail accounts, each with its own Mail signature and template options. All
  profiles rotate together and share the same quote.
- **Rotation**: hourly, daily, or weekly, plus a "New Quote Now" menu item.
- **No repeats**: recently used quotes are avoided (configurable window).
- **Weighted selection**: give favorite quotes a higher weight.
- **Seasonal tags**: tag a quote with a season, month, or holiday
  (`winter`, `december`, `christmas`, `halloween`, `new-year`, …) and it
  only appears — and is preferred — at that time of year. Untagged quotes
  rotate year-round; other tags are purely organizational. Settings →
  Rotation has an on/off toggle and a hemisphere picker (southern
  hemisphere flips the seasons; months and holidays are unaffected).
- **Editable database**: add, edit, disable, delete, search; import/export
  the library as JSON. Data lives in plain JSON files you can edit directly.
- **Mail can be closed**: if Mail isn't running when rotation is due, the
  sync is deferred and applied the moment Mail launches.

## Requirements

- macOS 14 (Sonoma) or later
- Xcode 16+ toolchain to build (Swift 6)

## Build & install

```bash
Scripts/package-app.sh
```

This produces `build/DynamicSignatureManager.app`. Move it to
`/Applications` and launch it — it appears as a quote bubble in the menu bar
(no Dock icon).

For development: `swift build` and `swift test` work directly.

## First-run setup

1. Open **Settings → Profiles** from the menu bar icon and enter at least
   your name in the default profile. Add more profiles if you have several
   mail accounts — give each one a distinct Mail signature name.
2. Click **New Quote Now**. macOS will ask for permission to control Mail —
   allow it. (If you declined, re-enable under System Settings → Privacy &
   Security → Automation.)
3. In **Mail → Settings → Signatures**, drag each profile's signature
   (**Dynamic Quote** by default) onto the matching account and choose it as
   the default (or pick it in the Signature popup when composing).

That's it. The app rotates the quote on your chosen interval whenever it's
running; enable **Launch at login** in Settings → General to make that
permanent.

## iPhone & iPad app

`Apps/iOS/DynamicSignatureMobile.xcodeproj` contains a universal
iPhone/iPad companion app built on the same Domain, Application, and
Infrastructure targets. It manages the quote library and profiles, rotates
the quote on your chosen interval (caught up whenever the app is opened —
iOS allows no background scheduling), and shows each profile's rendered
signature with a **Copy Signature** button.

iOS has no scripting interface into Mail, so the app can't update the Mail
signature automatically the way the Mac app does: paste the copied
signature into **Settings → Mail → Signature** whenever you want a fresh
quote on the device. Data is stored per-device; use the Quotes tab's
Export/Import to move the library between devices.

Open the project in Xcode 16+ and run the `DynamicSignatureMobile` scheme,
or build from the command line:

```bash
xcodebuild -project Apps/iOS/DynamicSignatureMobile.xcodeproj -scheme DynamicSignatureMobile -destination 'generic/platform=iOS Simulator' build
```

(Running on a physical device requires selecting your development team in
Xcode's Signing & Capabilities tab.)

## Quote library format

Import accepts either the app's own export format or a minimal JSON array:

```json
[
  { "text": "Well begun is half done.", "author": "Aristotle" },
  { "text": "An unattributed quote" },
  { "text": "A seasonal quote", "author": "Someone", "tags": ["winter", "christmas"] }
]
```

Data files live in `~/Library/Application Support/DynamicSignatureManager/`
(`quotes.json`, `profiles.json`, `rotation-state.json`). A pre-1.1
`identity.json` is migrated into a "Default" profile automatically and then
left untouched.

## Architecture

One Swift package, layered by target:

| Target | Role |
|---|---|
| `DynamicSignatureDomain` | Models and pure logic: quotes, identity, composer, weighted selection, rotation policy |
| `DynamicSignatureApplication` | Use cases: rotation orchestration, quote library CRUD/import/export, repository protocols |
| `DynamicSignatureInfrastructure` | JSON file persistence, storage directory, seed quotes |
| `DynamicSignatureMail` | AppleScript bridge to Apple Mail, clipboard |
| `DynamicSignatureManager` | SwiftUI menu bar app |

The iPhone/iPad app (`Apps/iOS/`) is a separate Xcode target that links the
Domain, Application, and Infrastructure products; it replaces the Mail
layer with clipboard-based copy/paste (see ADR 0004).

Design decisions are recorded in `Documentation/ADR/`.

## Limitations

- Signatures are plain text (Mail's scripting interface doesn't accept
  styled content). See ADR 0002.
- Rotation can't be truly per-message — macOS offers no hook for it. The
  practical ceiling is hourly rotation while the app runs.
- iCloud "sync signatures" across devices works, but other devices receive
  whatever quote was last synced from this Mac.
