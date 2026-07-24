import Foundation
import DynamicSignatureDomain

/// Orchestrates a rotation: generate a signature, push it into Mail, then
/// persist rotation state and quote usage statistics.
@MainActor
public final class RotationService {

    private let signatureService: SignatureService
    private let quoteRepository: QuoteRepository
    private let stateRepository: RotationStateRepository
    private let mailUpdater: MailSignatureUpdating

    public init(
        signatureService: SignatureService,
        quoteRepository: QuoteRepository,
        stateRepository: RotationStateRepository,
        mailUpdater: MailSignatureUpdating
    ) {
        self.signatureService = signatureService
        self.quoteRepository = quoteRepository
        self.stateRepository = stateRepository
        self.mailUpdater = mailUpdater
    }

    public func isRotationDue(configuration: RotationConfiguration, now: Date = .now) -> Bool {
        guard configuration.isEnabled else { return false }
        let lastRotated = (try? stateRepository.load())?.lastRotated
        return RotationPolicy.shouldRotate(
            lastRotated: lastRotated,
            interval: configuration.interval,
            now: now
        )
    }

    /// Rotates to a new quote and syncs Mail. Throws without touching state
    /// if generation or the Mail update fails, so a failed sync is retried
    /// rather than silently skipped.
    @discardableResult
    public func rotate(configuration: RotationConfiguration, now: Date = .now) throws -> GeneratedSignature {
        let generated = try signatureService.generate(configuration: configuration)
        try mailUpdater.apply(content: generated.text, toSignatureNamed: configuration.signatureName)

        var state = try stateRepository.load()
        if let quote = generated.quote {
            state.record(quoteID: quote.id, at: now, keepingRecent: configuration.recentQuoteLimit)

            var quotes = try quoteRepository.loadAll()
            if let index = quotes.firstIndex(where: { $0.id == quote.id }) {
                quotes[index].usageCount += 1
                quotes[index].lastUsed = now
                try quoteRepository.saveAll(quotes)
            }
        } else {
            state.lastRotated = now
            state.currentQuoteID = nil
        }
        try stateRepository.save(state)

        return generated
    }

    /// Re-syncs the current signature to Mail without picking a new quote
    /// (used after identity or template edits).
    public func resync(configuration: RotationConfiguration) throws {
        guard let current = try signatureService.current(configuration: configuration) else {
            try rotate(configuration: configuration)
            return
        }
        try mailUpdater.apply(content: current.text, toSignatureNamed: configuration.signatureName)
    }
}
