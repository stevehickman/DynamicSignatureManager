# ADR 0003: Signature Profiles for Multiple Mail Accounts

## Status

Accepted (1.1.0)

## Context

The app originally maintained exactly one identity and one signature in
Apple Mail. Users with several mail accounts (work, personal, …) want a
different identity block per account, but Mail's scripting interface only
lets us manage signatures by name — assigning a signature to an account is a
manual, one-time step the user performs in Mail's settings.

## Decision

Introduce `SignatureProfile` in the domain layer: identity + the name of the
Mail signature the profile owns + per-profile `SignatureTemplate` + an
enabled flag. Profiles are stored as an array in `profiles.json`.

- **Rotation stays global.** One schedule, one shared `RotationState`, and
  one quote per rotation applied to every enabled, configured profile. This
  keeps the no-repeat window meaningful and avoids per-profile state files.
  Profiles with `includeQuote = false` render without the quote.
- **`SignatureService` renders a batch** (`GeneratedSignatureBatch`) — one
  `GeneratedSignature` per active profile. `RotationService` applies each to
  its Mail signature and persists state only if every apply succeeded, so a
  partial failure is retried in full (re-applying is idempotent).
- **Signature names must be unique** across profiles; the editor blocks
  duplicates since two profiles writing the same Mail signature would
  silently overwrite each other.
- **Migration**: on first launch after the upgrade, if `profiles.json` is
  empty, the legacy `identity.json` plus the old signature-name and template
  preferences become a single "Default" profile. The legacy file is left in
  place (harmless, allows downgrade).

## Alternatives considered

- **Per-profile quotes and rotation state**: rejected for now — it
  multiplies state files, complicates partial-failure semantics, and the
  main user need is per-account identity, not per-account quote streams.
  The batch design leaves room to add it later (per-profile quote filters
  would slot into `SignatureService.compose`).
- **Automatic account assignment via scripting**: Mail exposes signature
  assignment poorly and unreliably across macOS versions; we keep the
  documented manual drag-in-Mail step instead.
