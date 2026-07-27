# Changelog

## 1.3.0 — 2026-07-27

Companion iPhone and iPad app.

### Added
- iOS app (`Apps/iOS/DynamicSignatureMobile.xcodeproj`): a universal
  iPhone/iPad SwiftUI app built on the same Domain, Application, and
  Infrastructure targets. It manages the quote library and profiles,
  rotates quotes on the configured schedule (caught up when the app comes
  to the foreground — iOS allows no background scheduling), and renders
  each profile's signature with a Copy button for pasting into
  Settings → Mail → Signature. iOS has no scripting bridge into Mail, so
  automatic signature sync remains macOS-only.
- Quote library import/export on iOS via the Files document pickers.

### Changed
- The package now declares an iOS 17 platform alongside macOS 14 so the
  shared targets build for both platforms. Mac-only code
  (`DynamicSignatureMail`, the menu bar app) is untouched and not linked
  into the iOS app.

## 1.2.0 — 2026-07-26

Seasonal quote selection via tags.

### Added
- Seasonal tags: quotes tagged with a season (`winter`, `spring`, `summer`,
  `autumn`/`fall`), a month (`january`…`december`), or a holiday span
  (`new-year`, `valentines`, `halloween`, `thanksgiving`, `christmas`) are
  only selected while that tag is active, and are preferred over untagged
  quotes during their period. Matching is case-insensitive; unrecognized
  tags remain purely organizational. Seasons use meteorological
  boundaries.
- Tags editing in the quote editor (comma-separated field with a live
  seasonal indicator), tag display in the quote list (calendar icon for
  seasonal, tag icon for organizational), and tag-aware search.
- "Match quotes to the time of year" toggle in Settings → Rotation
  (on by default), plus a Hemisphere picker (Northern/Southern, defaulting
  to Northern): season tags flip in the southern hemisphere while month and
  holiday tags stay calendar-based.
- Simple JSON import format now accepts an optional `"tags"` array.
- Four seasonal starter quotes in the default library.

### Changed
- `QuoteSelectionEngine.select` accepts optional `activeSeasonalTags`;
  `SignatureService.generate` takes `now`/`preferSeasonalQuotes`;
  `RotationConfiguration` gains `preferSeasonalQuotes`. When every enabled
  quote is out of season, seasonality is ignored rather than failing
  rotation.

## 1.1.0 — 2026-07-26

Multiple signature profiles, one per mail account.

### Added
- Signature profiles: each profile bundles an identity (name, title,
  contact details), its own Mail signature name, and per-profile template
  toggles (quote / contact details). Rotation updates every enabled
  profile's signature in one pass; all profiles share the same quote at any
  given time. Assign each profile's signature to the matching account in
  Mail → Settings → Signatures.
- Profiles settings tab with a list + editor (add, remove, enable/disable),
  including a guard against two profiles claiming the same Mail signature
  name.
- Per-profile "Copy Signature" menu when more than one profile is active.
- Automatic migration: existing `identity.json` plus the old signature-name
  and template preferences become a "Default" profile in `profiles.json` on
  first launch.

### Changed
- Signature name and template toggles moved from Rotation settings into
  each profile.
- `SignatureService`/`RotationService` now operate on profile batches;
  `ApplicationError.identityNotConfigured` replaced by
  `.noProfilesConfigured`.

## 1.0.0 — 2026-07-24

First working release. Rebuilt the initial scaffold into a functioning app.

### Added
- Apple Mail integration via AppleScript: the app creates and maintains a
  "Dynamic Quote" signature in Mail (one-time Automation permission; no Full
  Disk Access). Deferred sync when Mail is closed, applied on Mail launch.
- Scheduled rotation (hourly / daily / weekly) plus "New Quote Now",
  with weighted random selection and a configurable no-repeat window.
- Editable quote library UI: add, edit, enable/disable, delete, search,
  JSON import (full or `[{"text","author"}]` format) and export, usage
  counts, per-quote weights.
- Identity editor, rotation/template settings, launch-at-login,
  copy-signature-to-clipboard.
- 16 seeded starter quotes on first run.
- App packaging script (`Scripts/package-app.sh`) producing a signed
  menu-bar `.app` from the Swift package — no Xcode project required.
- 35 unit tests across all four library targets; CI builds, tests, and
  uploads the app artifact.

### Changed
- Restructured six unbuildable sibling packages into one Swift package with
  layered targets (see ADR 0002).
- Normalized code style; removed the `.everyMessage` rotation interval
  (impossible without a Mail plugin API).

### Removed
- Speculative scaffolding: PluginAPI and HTML packages; Banner, Rule,
  Profile, Signature-entity, migration, and backup stubs.
