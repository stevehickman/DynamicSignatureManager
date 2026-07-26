import Foundation
import Testing
@testable import DynamicSignatureMail

@Suite struct MailSignatureScriptTests {

    @Test func escapesQuotesBackslashesAndNewlines() {
        let input = "He said \"hi\" \\ bye\nnew line\ttab"
        let escaped = MailSignatureScript.escape(input)

        #expect(escaped == "He said \\\"hi\\\" \\\\ bye\\nnew line\\ttab")
    }

    @Test func scriptTargetsMailAndUpsertsByName() {
        let script = MailSignatureScript.upsertScript(name: "Dynamic Quote", content: "Steve\n\u{201C}Hello\u{201D}")

        #expect(script.contains("tell application \"Mail\""))
        #expect(script.contains("if (exists signature \"Dynamic Quote\")"))
        #expect(script.contains("set content of signature \"Dynamic Quote\""))
        #expect(script.contains("make new signature with properties"))
        #expect(script.contains("Steve\\n\u{201C}Hello\u{201D}"))
    }

    @Test func escapesMaliciousSignatureNames() {
        let script = MailSignatureScript.upsertScript(name: "x\" & quit \"", content: "body")

        // The embedded quote must be escaped so it cannot break out of the
        // AppleScript string literal.
        #expect(script.contains("signature \"x\\\" & quit \\\"\""))
        #expect(!script.contains("signature \"x\" & quit"))
    }
}
