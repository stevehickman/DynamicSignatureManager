import Foundation
import DynamicSignatureDomain

/// Orchestrates a rotation: generate signatures for every active profile,
/// push them into Mail, then persist rotation state and quote usage
/// statistics.
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

    /// Rotates to a new quote and syncs every active profile's signature to
    /// Mail. Throws without touching state if generation or any Mail update
    /// fails, so a failed sync is retried rather than silently skipped
    /// (re-applying an already-updated signature is harmless).
    @discardableResult
    public func rotate(configuration: RotationConfiguration, now: Date = .now) throws -> GeneratedSignatureBatch {
        let batch = try signatureService.generate()
        try apply(batch)

        var state = try stateRepository.load()
        if let quote = batch.quote {
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

        return batch
    }

    /// Re-syncs the current signatures to Mail without picking a new quote
    /// (used after profile or template edits).
    public func resync(configuration: RotationConfiguration) throws {
        guard let current = try signatureService.current() else {
            try rotate(configuration: configuration)
            return
        }
        try apply(current)
    }

    private func apply(_ batch: GeneratedSignatureBatch) throws {
        for signature in batch.signatures {
            try mailUpdater.apply(content: signature.text, toSignatureNamed: signature.signatureName)
        }
    }
}
