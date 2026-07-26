import Foundation

/// Abstraction over pushing signature content into the user's mail client.
/// Implemented by DynamicSignatureMail; kept here so the application layer
/// stays independent of AppKit and AppleScript.
@MainActor
public protocol MailSignatureUpdating: AnyObject {
    var isMailRunning: Bool { get }
    func apply(content: String, toSignatureNamed name: String) throws
}
