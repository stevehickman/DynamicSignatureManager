# Changelog

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
