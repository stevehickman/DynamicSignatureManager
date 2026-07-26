import Foundation
import DynamicSignatureDomain

/// Rendered signature content for one profile.
public struct GeneratedSignature: Equatable, Sendable {
    public let profileID: UUID
    /// Name of the signature in Apple Mail this content belongs to.
    public let signatureName: String
    public let text: String
    public let quote: Quote?

    public init(profileID: UUID, signatureName: String, text: String, quote: Quote?) {
        self.profileID = profileID
        self.signatureName = signatureName
        self.text = text
        self.quote = quote
    }
}

/// One rendering pass over every active profile. All profiles that include
/// a quote share the same one, so every Mail account shows the same quote
/// at any given time.
public struct GeneratedSignatureBatch: Equatable, Sendable {
    public let signatures: [GeneratedSignature]
    /// The quote used by profiles that include one; nil when no active
    /// profile renders quotes.
    public let quote: Quote?

    public init(signatures: [GeneratedSignature], quote: Quote?) {
        self.signatures = signatures
        self.quote = quote
    }
}

/// Produces signature content for every active profile from the stored
/// profiles and quote library.
@MainActor
public final class SignatureService {

    private let profileRepository: ProfileRepository
    private let quoteRepository: QuoteRepository
    private let stateRepository: RotationStateRepository
    private let engine = QuoteSelectionEngine()
    private let composer = SignatureComposer()

    public init(
        profileRepository: ProfileRepository,
        quoteRepository: QuoteRepository,
        stateRepository: RotationStateRepository
    ) {
        self.profileRepository = profileRepository
        self.quoteRepository = quoteRepository
        self.stateRepository = stateRepository
    }

    /// Generates signatures for all active profiles with a freshly selected
    /// quote (shared across the profiles that include one).
    public func generate() throws -> GeneratedSignatureBatch {
        let profiles = try activeProfiles()

        var quote: Quote?
        if profiles.contains(where: { $0.template.includeQuote }) {
            let quotes = try quoteRepository.loadAll()
            let state = try stateRepository.load()
            quote = engine.select(from: quotes, avoiding: state.recentQuoteIDs)
            guard quote != nil else {
                throw ApplicationError.noQuotesAvailable
            }
        }

        return compose(profiles: profiles, quote: quote)
    }

    /// Re-renders the signatures for the quote currently recorded in rotation
    /// state, without selecting a new one. Returns nil when no rotation has
    /// happened yet.
    public func current() throws -> GeneratedSignatureBatch? {
        let profiles = try activeProfiles()
        let state = try stateRepository.load()

        guard let currentID = state.currentQuoteID else { return nil }
        guard let quote = try quoteRepository.loadAll().first(where: { $0.id == currentID }) else {
            return nil
        }

        return compose(profiles: profiles, quote: quote)
    }

    private func compose(profiles: [SignatureProfile], quote: Quote?) -> GeneratedSignatureBatch {
        let signatures = profiles.map { profile in
            let usedQuote = profile.template.includeQuote ? quote : nil
            let text = composer.compose(
                identity: profile.identity,
                quote: usedQuote,
                template: profile.template
            )
            return GeneratedSignature(
                profileID: profile.id,
                signatureName: profile.signatureName,
                text: text,
                quote: usedQuote
            )
        }
        return GeneratedSignatureBatch(signatures: signatures, quote: quote)
    }

    /// Enabled, configured profiles — the ones rotation should touch.
    public func activeProfiles() throws -> [SignatureProfile] {
        let profiles = try profileRepository.loadAll().filter { $0.isEnabled && $0.isConfigured }
        guard !profiles.isEmpty else {
            throw ApplicationError.noProfilesConfigured
        }
        return profiles
    }
}
