# App Permissions

Dynamic Signature Manager requests exactly one macOS privacy permission.

## Automation (Apple Events) → Mail

Prompted the first time the app syncs a signature. This lets the app run the
equivalent of:

```applescript
tell application "Mail"
    set content of signature "Dynamic Quote" to "…"
end tell
```

The app only creates/updates the signature it owns (name configurable in
Settings → Rotation). It never reads messages, contacts, or other Mail data.

Manage it under **System Settings → Privacy & Security → Automation →
Dynamic Signature Manager → Mail**.

## What is deliberately NOT required

- **Full Disk Access** — the app does not touch `~/Library/Mail` directly
  (see ADR 0002; the file-writing approach was rejected).
- **Network access** — the app makes no network requests. Quotes are local
  JSON files.
- **Accessibility** — no input synthesis of any kind.

## Login item

Optional "Launch at login" uses `SMAppService` and shows up under
System Settings → General → Login Items like any standard app.
