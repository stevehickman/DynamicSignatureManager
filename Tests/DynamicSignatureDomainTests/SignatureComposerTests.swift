import Foundation
import Testing
@testable import DynamicSignatureDomain

@Suite struct SignatureComposerTests {

    private let identity = Identity(
        displayName: "Steve Hickman",
        title: "Founder",
        organization: "Acme",
        email: "steve@example.com"
    )

    @Test func composesIdentityAndQuote() {
        let quote = Quote(text: "Innovation distinguishes leaders.", author: "Steve Jobs")
        let body = SignatureComposer().compose(identity: identity, quote: quote)

        #expect(body.contains("Steve Hickman"))
        #expect(body.contains("Founder · Acme"))
        #expect(body.contains("steve@example.com"))
        #expect(body.contains("\u{201C}Innovation distinguishes leaders.\u{201D}"))
        #expect(body.contains("— Steve Jobs"))
    }

    @Test func omitsQuoteBlockWhenNoQuote() {
        let body = SignatureComposer().compose(identity: identity, quote: nil)

        #expect(body.contains("Steve Hickman"))
        #expect(!body.contains("\u{201C}"))
    }

    @Test func omitsAuthorLineWhenAuthorMissing() {
        let quote = Quote(text: "Anonymous wisdom.")
        let body = SignatureComposer().compose(identity: identity, quote: quote)

        #expect(body.contains("Anonymous wisdom."))
        #expect(!body.contains("—"))
    }

    @Test func respectsTemplateFlags() {
        let quote = Quote(text: "Hello.", author: "Someone")
        let template = SignatureTemplate(includeIdentity: true, includeContactDetails: false, includeQuote: false)
        let body = SignatureComposer().compose(identity: identity, quote: quote, template: template)

        #expect(body.contains("Steve Hickman"))
        #expect(!body.contains("steve@example.com"))
        #expect(!body.contains("Hello."))
    }
}
