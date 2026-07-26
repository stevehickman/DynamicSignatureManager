# ADR 0002: Mail Integration via AppleScript; Single-Package Restructure

## Status

Accepted

## Context

The original scaffold (ADR 0001) proposed six sibling packages plus an Xcode
app, but shipped without package manifests and with the Apple Mail
integration stubbed. Apple provides no supported plugin API for signatures:
MailKit extensions cannot modify signatures or inject per-message content,
and legacy Mail bundles are unsupported.

Two viable integration mechanisms exist:

1. **AppleScript automation** — Mail's scripting dictionary exposes
   `signature` objects with `name` and `content`. The app can create and
   update a dedicated signature. Requires the one-time Automation (Apple
   Events) permission and Mail running.
2. **Direct file writes** — `.mailsignature` files under
   `~/Library/Mail/V*/MailData/Signatures/`. Requires Full Disk Access,
   breaks across macOS versions and with iCloud-synced signatures.

## Decision

- Use **AppleScript** as the sole Mail integration for v1. The app owns one
  signature (default name "Dynamic Quote"); the user selects it once in
  Mail → Settings → Signatures. If Mail is closed when a rotation is due,
  the sync is deferred and retried when Mail launches (observed via
  `NSWorkspace`).
- Rotation is wall-clock scheduled (hourly/daily/weekly) plus manual.
  Per-message rotation was dropped as unimplementable without private API.
- Collapse the multi-package layout into **one Swift package** with library
  targets `DynamicSignatureDomain`, `DynamicSignatureApplication`,
  `DynamicSignatureInfrastructure`, `DynamicSignatureMail`, and an
  executable menu-bar app target. Layering is preserved by target
  dependencies; the PluginAPI and HTML packages and the Banner / Rule /
  Profile / Signature-entity models were removed as speculative.
- The app is packaged from the SPM build by `Scripts/package-app.sh`
  (no Xcode project needed).

## Consequences

- No Full Disk Access or Mail restarts needed; permission surface is one
  Automation prompt.
- Signature content is plain text (Mail's scriptable `content` property).
  Styled HTML signatures would require the file-based mechanism and are out
  of scope for v1.
- Rotation only happens while the menu-bar app runs; launch-at-login is
  offered via `SMAppService`.
