import Foundation
import Testing
import DynamicSignatureDomain
@testable import DynamicSignatureApplication

@MainActor
@Suite struct RotationServiceTests {

    private let profile = SignatureProfile(
        name: "Default",
        identity: Identity(displayName: "Steve Hickman"),
        signatureName: "Dynamic Quote"
    )

    private func makeServices(
        quotes: [Quote],
        profiles: [SignatureProfile]
    ) -> (RotationService, InMemoryQuoteRepository, InMemoryRotationStateRepository, FakeMailUpdater) {
        let quoteRepository = InMemoryQuoteRepository(quotes: quotes)
        let profileRepository = InMemoryProfileRepository(profiles: profiles)
        let stateRepository = InMemoryRotationStateRepository()
        let updater = FakeMailUpdater()

        let signatureService = SignatureService(
            profileRepository: profileRepository,
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
        let (service, quoteRepository, stateRepository, updater) = makeServices(quotes: [quote], profiles: [profile])

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

    @Test func rotateSyncsEveryEnabledProfileWithSharedQuote() throws {
        let quote = Quote(text: "Shared quote")
        let work = SignatureProfile(
            name: "Work",
            identity: Identity(displayName: "Steve Hickman", organization: "Acme"),
            signatureName: "Work Signature"
        )
        let personal = SignatureProfile(
            name: "Personal",
            identity: Identity(displayName: "Steve"),
            signatureName: "Personal Signature"
        )
        let disabled = SignatureProfile(
            name: "Old",
            identity: Identity(displayName: "Steve"),
            signatureName: "Old Signature",
            isEnabled: false
        )
        let (service, quoteRepository, _, updater) = makeServices(
            quotes: [quote],
            profiles: [work, personal, disabled]
        )

        let result = try service.rotate(configuration: RotationConfiguration())

        #expect(result.quote?.id == quote.id)
        #expect(updater.applied.count == 2)
        #expect(updater.applied.map(\.name) == ["Work Signature", "Personal Signature"])
        #expect(updater.applied.allSatisfy { $0.content.contains("Shared quote") })
        #expect(updater.applied.first?.content.contains("Acme") == true)
        // The shared quote is charged one use per rotation, not per profile.
        #expect(quoteRepository.quotes.first?.usageCount == 1)
    }

    @Test func rotateSkipsQuoteForProfilesThatExcludeIt() throws {
        let quote = Quote(text: "Quoted text")
        var noQuoteProfile = SignatureProfile(
            name: "Plain",
            identity: Identity(displayName: "Steve"),
            signatureName: "Plain Signature"
        )
        noQuoteProfile.template.includeQuote = false
        let (service, _, _, updater) = makeServices(
            quotes: [quote],
            profiles: [profile, noQuoteProfile]
        )

        try service.rotate(configuration: RotationConfiguration())

        let plain = updater.applied.first { $0.name == "Plain Signature" }
        let quoted = updater.applied.first { $0.name == "Dynamic Quote" }
        #expect(plain?.content.contains("Quoted text") == false)
        #expect(quoted?.content.contains("Quoted text") == true)
    }

    @Test func rotateAvoidsImmediateRepeatAcrossRotations() throws {
        let quotes = (0..<5).map { Quote(text: "Quote \($0)") }
        let (service, _, stateRepository, _) = makeServices(quotes: quotes, profiles: [profile])

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

    @Test func rotateThrowsWithoutProfiles() {
        let (service, _, _, updater) = makeServices(quotes: [Quote(text: "Q")], profiles: [])

        #expect(throws: ApplicationError.noProfilesConfigured) {
            try service.rotate(configuration: RotationConfiguration())
        }
        #expect(updater.applied.isEmpty)
    }

    @Test func rotateThrowsWhenOnlyProfileIsUnconfigured() {
        let unconfigured = SignatureProfile(name: "Empty", identity: Identity())
        let (service, _, _, updater) = makeServices(quotes: [Quote(text: "Q")], profiles: [unconfigured])

        #expect(throws: ApplicationError.noProfilesConfigured) {
            try service.rotate(configuration: RotationConfiguration())
        }
        #expect(updater.applied.isEmpty)
    }

    @Test func rotateThrowsWithoutQuotes() {
        let (service, _, _, _) = makeServices(quotes: [], profiles: [profile])

        #expect(throws: ApplicationError.noQuotesAvailable) {
            try service.rotate(configuration: RotationConfiguration())
        }
    }

    @Test func rotateWithQuotesDisabledStillSyncsIdentityOnly() throws {
        var noQuoteProfile = profile
        noQuoteProfile.template.includeQuote = false
        let (service, _, stateRepository, updater) = makeServices(quotes: [], profiles: [noQuoteProfile])

        let result = try service.rotate(configuration: RotationConfiguration())

        #expect(result.quote == nil)
        #expect(updater.applied.count == 1)
        #expect(stateRepository.state.currentQuoteID == nil)
        #expect(stateRepository.state.lastRotated != nil)
    }

    @Test func failedMailSyncLeavesStateUntouched() {
        let quote = Quote(text: "Q")
        let (service, quoteRepository, stateRepository, updater) = makeServices(quotes: [quote], profiles: [profile])
        updater.errorToThrow = ApplicationError.mailNotRunning

        #expect(throws: ApplicationError.mailNotRunning) {
            try service.rotate(configuration: RotationConfiguration())
        }
        #expect(stateRepository.state.lastRotated == nil)
        #expect(quoteRepository.quotes.first?.usageCount == 0)
    }

    @Test func rotationDueRespectsEnabledFlagAndInterval() throws {
        let (service, _, stateRepository, _) = makeServices(quotes: [Quote(text: "Q")], profiles: [profile])

        var configuration = RotationConfiguration()
        #expect(service.isRotationDue(configuration: configuration))

        try service.rotate(configuration: configuration)
        #expect(!service.isRotationDue(configuration: configuration))

        configuration.isEnabled = false
        stateRepository.state.lastRotated = nil
        #expect(!service.isRotationDue(configuration: configuration))
    }
}
