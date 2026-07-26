import Foundation
import Testing
import DynamicSignatureDomain
@testable import DynamicSignatureApplication

@MainActor
@Suite struct RotationServiceTests {

    private let identity = Identity(displayName: "Steve Hickman")

    private func makeServices(
        quotes: [Quote],
        identity: Identity?
    ) -> (RotationService, InMemoryQuoteRepository, InMemoryRotationStateRepository, FakeMailUpdater) {
        let quoteRepository = InMemoryQuoteRepository(quotes: quotes)
        let identityRepository = InMemoryIdentityRepository(identity: identity)
        let stateRepository = InMemoryRotationStateRepository()
        let updater = FakeMailUpdater()

        let signatureService = SignatureService(
            identityRepository: identityRepository,
            quoteRepository: quoteRepository,
            stateRepository: stateRepository
        )
        let rotationService = RotationService(
            signatureService: signatureService,
            quoteRepository: quoteRepository,
            stateRepository: stateRepository,
            mailUpdater: updater
        )
        return (rotationService, quoteRepository, stateRepository, updater)
    }

    @Test func rotateSyncsMailAndRecordsState() throws {
        let quote = Quote(text: "Only quote")
        let (service, quoteRepository, stateRepository, updater) = makeServices(quotes: [quote], identity: identity)

        let result = try service.rotate(configuration: RotationConfiguration())

        #expect(result.quote?.id == quote.id)
        #expect(updater.applied.count == 1)
        #expect(updater.applied.first?.name == "Dynamic Quote")
        #expect(updater.applied.first?.content.contains("Only quote") == true)
        #expect(stateRepository.state.currentQuoteID == quote.id)
        #expect(stateRepository.state.lastRotated != nil)
        #expect(quoteRepository.quotes.first?.usageCount == 1)
        #expect(quoteRepository.quotes.first?.lastUsed != nil)
    }

    @Test func rotateAvoidsImmediateRepeatAcrossRotations() throws {
        let quotes = (0..<5).map { Quote(text: "Quote \($0)") }
        let (service, _, stateRepository, _) = makeServices(quotes: quotes, identity: identity)

        var configuration = RotationConfiguration()
        configuration.recentQuoteLimit = 2

        var previousID: UUID?
        for _ in 0..<10 {
            let result = try service.rotate(configuration: configuration)
            #expect(result.quote?.id != previousID)
            previousID = result.quote?.id
        }
        #expect(stateRepository.state.recentQuoteIDs.count == 2)
    }

    @Test func rotateThrowsWithoutIdentity() {
        let (service, _, _, updater) = makeServices(quotes: [Quote(text: "Q")], identity: nil)

        #expect(throws: ApplicationError.identityNotConfigured) {
            try service.rotate(configuration: RotationConfiguration())
        }
        #expect(updater.applied.isEmpty)
    }

    @Test func rotateThrowsWithoutQuotes() {
        let (service, _, _, _) = makeServices(quotes: [], identity: identity)

        #expect(throws: ApplicationError.noQuotesAvailable) {
            try service.rotate(configuration: RotationConfiguration())
        }
    }

    @Test func rotateWithQuotesDisabledStillSyncsIdentityOnly() throws {
        let (service, _, stateRepository, updater) = makeServices(quotes: [], identity: identity)

        var configuration = RotationConfiguration()
        configuration.template.includeQuote = false

        let result = try service.rotate(configuration: configuration)

        #expect(result.quote == nil)
        #expect(updater.applied.count == 1)
        #expect(stateRepository.state.currentQuoteID == nil)
        #expect(stateRepository.state.lastRotated != nil)
    }

    @Test func failedMailSyncLeavesStateUntouched() {
        let quote = Quote(text: "Q")
        let (service, quoteRepository, stateRepository, updater) = makeServices(quotes: [quote], identity: identity)
        updater.errorToThrow = ApplicationError.mailNotRunning

        #expect(throws: ApplicationError.mailNotRunning) {
            try service.rotate(configuration: RotationConfiguration())
        }
        #expect(stateRepository.state.lastRotated == nil)
        #expect(quoteRepository.quotes.first?.usageCount == 0)
    }

    @Test func rotationDueRespectsEnabledFlagAndInterval() throws {
        let (service, _, stateRepository, _) = makeServices(quotes: [Quote(text: "Q")], identity: identity)

        var configuration = RotationConfiguration()
        #expect(service.isRotationDue(configuration: configuration))

        try service.rotate(configuration: configuration)
        #expect(!service.isRotationDue(configuration: configuration))

        configuration.isEnabled = false
        stateRepository.state.lastRotated = nil
        #expect(!service.isRotationDue(configuration: configuration))
    }
}
