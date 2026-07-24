import AppKit
import Foundation
import DynamicSignatureApplication

/// Pushes signature content into Apple Mail by scripting it.
///
/// Requires the one-time Automation permission ("DynamicSignatureManager
/// wants to control Mail"). By default it refuses to run when Mail is
/// closed, because `tell application "Mail"` would launch it visibly;
/// callers catch `ApplicationError.mailNotRunning` and retry when Mail opens.
@MainActor
public final class AppleScriptMailSignatureUpdater: MailSignatureUpdating {

    private static let mailBundleID = "com.apple.mail"

    /// AppleEvents "not authorized" error code.
    private static let automationDeniedCode = -1743

    public var launchesMailIfNeeded: Bool

    public init(launchesMailIfNeeded: Bool = false) {
        self.launchesMailIfNeeded = launchesMailIfNeeded
    }

    public var isMailRunning: Bool {
        !NSRunningApplication.runningApplications(withBundleIdentifier: Self.mailBundleID).isEmpty
    }

    public func apply(content: String, toSignatureNamed name: String) throws {
        guard isMailRunning || launchesMailIfNeeded else {
            throw ApplicationError.mailNotRunning
        }

        let source = MailSignatureScript.upsertScript(name: name, content: content)
        guard let script = NSAppleScript(source: source) else {
            throw ApplicationError.mailSyncFailed("Could not compile the Mail script.")
        }

        var errorInfo: NSDictionary?
        script.executeAndReturnError(&errorInfo)

        if let errorInfo {
            let code = errorInfo[NSAppleScript.errorNumber] as? Int
            if code == Self.automationDeniedCode {
                throw ApplicationError.mailSyncFailed(
                    "Permission to control Mail was denied. Enable it in "
                    + "System Settings → Privacy & Security → Automation."
                )
            }
            let message = errorInfo[NSAppleScript.errorMessage] as? String ?? "Unknown AppleScript error."
            throw ApplicationError.mailSyncFailed(message)
        }
    }
}
