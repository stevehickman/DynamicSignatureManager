import Foundation
import DynamicSignatureDomain

public struct GeneratedSignature: Equatable, Sendable {
    public let text: String
    public let quote: Quote?

    public init(text: String, quote: Quote?) {
        self.text = text
        self.quote = quote
    }
}

/// Produces signature content from the stored identity and quote library.
@MainActor
public final class SignatureService {

    private let identityRepository: IdentityRepository
    private let quoteRepository: QuoteRepository
    private let stateRepository: RotationStateRepository
    private let engine = QuoteSelectionEngine()
    private let composer = SignatureComposer()

    public init(
        identityRepository: IdentityRepository,
        quoteRepository: QuoteRepository,
        stateRepository: RotationStateRepository
    ) {
        self.identityRepository = identityRepository
        self.quoteRepository = quoteRepository
        self.stateRepository = stateRepository
    }

    /// Generates a signature with a freshly selected quote.
    public func generate(configuration: RotationConfiguration) throws -> GeneratedSignature {
        let identity = try configuredIdentity()

        var quote: Quote?
        if configuration.template.includeQuote {
            let quotes = try quoteRepository.loadAll()
            let state = try stateRepository.load()
            quote = engine.select(from: quotes, avoiding: state.recentQuoteIDs)
            guard quote != nil else {
                throw ApplicationError.noQuotesAvailable
            }
        }

        let text = composer.compose(identity: identity, quote: quote, template: configuration.template)
        return GeneratedSignature(text: text, quote: quote)
    }

    /// Re-renders the signature currently recorded in rotation state, without
    /// selecting a new quote. Returns nil when no rotation has happened yet.
    public func current(configuration: RotationConfiguration) throws -> GeneratedSignature? {
        let identity = try configuredIdentity()
        let state = try stateRepository.load()

        guard let currentID = state.currentQuoteID else { return nil }
        guard let quote = try quoteRepository.loadAll().first(where: { $0.id == currentID }) else {
            return nil
        }

        let text = composer.compose(identity: identity, quote: quote, template: configuration.template)
        return GeneratedSignature(text: text, quote: quote)
    }

    private func configuredIdentity() throws -> Identity {
        guard let identity = try identityRepository.load(), identity.isConfigured else {
            throw ApplicationError.identityNotConfigured
        }
        return identity
    }
}
