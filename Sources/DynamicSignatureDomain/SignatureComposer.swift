import Foundation

/// Renders an identity plus an optional quote into plain-text signature content.
public struct SignatureComposer: Sendable {

    public init() {}

    public func compose(
        identity: Identity,
        quote: Quote?,
        template: SignatureTemplate = SignatureTemplate()
    ) -> String {
        var blocks: [String] = []

        if template.includeIdentity {
            var lines: [String] = [identity.displayName]

            let role = [identity.title, identity.organization]
                .compactMap { $0?.trimmingCharacters(in: .whitespaces) }
                .filter { !$0.isEmpty }
            if !role.isEmpty {
                lines.append(role.joined(separator: " · "))
            }

            if template.includeContactDetails {
                let contact = [identity.email, identity.phone, identity.website]
                    .compactMap { $0?.trimmingCharacters(in: .whitespaces) }
                    .filter { !$0.isEmpty }
                if !contact.isEmpty {
                    lines.append(contact.joined(separator: " · "))
                }
            }

            blocks.append(lines.joined(separator: "\n"))
        }

        if template.includeQuote, let quote {
            var lines = ["\u{201C}\(quote.text)\u{201D}"]
            if let author = quote.author, !author.isEmpty {
                lines.append("— \(author)")
            }
            blocks.append(lines.joined(separator: "\n"))
        }

        return blocks.joined(separator: "\n\n")
    }
}
