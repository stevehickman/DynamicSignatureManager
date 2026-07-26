import Foundation

/// Controls which blocks appear in the composed signature.
public struct SignatureTemplate: Codable, Hashable, Sendable {
    public var includeIdentity: Bool
    public var includeContactDetails: Bool
    public var includeQuote: Bool

    public init(
        includeIdentity: Bool = true,
        includeContactDetails: Bool = true,
        includeQuote: Bool = true
    ) {
        self.includeIdentity = includeIdentity
        self.includeContactDetails = includeContactDetails
        self.includeQuote = includeQuote
    }
}
