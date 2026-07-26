import Foundation

/// Builds the AppleScript that creates or updates the app-owned signature
/// in Apple Mail. Pure string construction, unit-testable without Mail.
public enum MailSignatureScript {

    /// Escapes a Swift string for embedding inside an AppleScript string literal.
    public static func escape(_ string: String) -> String {
        var result = ""
        result.reserveCapacity(string.count)
        for character in string {
            switch character {
            case "\\": result += "\\\\"
            case "\"": result += "\\\""
            case "\n": result += "\\n"
            case "\r": result += "\\r"
            case "\t": result += "\\t"
            default: result.append(character)
            }
        }
        return result
    }

    public static func upsertScript(name: String, content: String) -> String {
        let escapedName = escape(name)
        let escapedContent = escape(content)
        return """
        tell application "Mail"
            if (exists signature "\(escapedName)") then
                set content of signature "\(escapedName)" to "\(escapedContent)"
            else
                make new signature with properties {name:"\(escapedName)", content:"\(escapedContent)"}
            end if
        end tell
        """
    }
}
