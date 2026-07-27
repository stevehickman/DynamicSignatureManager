import Foundation
import SwiftUI
import UIKit
import DynamicSignatureDomain
import DynamicSignatureApplication
import DynamicSignatureInfrastructure

/// iOS has no scripting bridge into Mail, so rotation only records state and
/// renders signatures; the user copies a signature and pastes it into
/// Settings → Mail → Signature.
@MainActor
private final class NoMailUpdater: MailSignatureUpdating {
    var isMailRunning: Bool { true }
    func apply(content: String, toSignatureNamed name: String) throws {}
}

/// Wires storage and services together and exposes observable state to the
/// SwiftUI views. iOS counterpart of the Mac app's `AppModel`: same data
/// files and rotation logic, minus the Apple Mail sync.
@MainActor
final class MobileAppModel: ObservableObject {

    enum DefaultsKey {
        static let rotationEnabled = "rotationEnabled"
        static let rotationInterval = "rotationInterval"
        static let recentQuoteLimit = "recentQuoteLimit"
        static let preferSeasonalQuotes = "preferSeasonalQuotes"
        static let hemisphere = "hemisphere"
    }

    @Published private(set) var quotes: [Quote] = []
    @Published private(set) var profiles: [SignatureProfile] = []
    @Published private(set) var currentQuote: Quote?
    @Published private(set) var currentSignatures: [GeneratedSignature] = []
    @Published private(set) var lastRotationDate: Date?
    @Published private(set) var statusMessage: String?

    let storageDirectory: StorageDirectory

    private let quoteRepository: FileQuoteRepository
    private let profileRepository: FileProfileRepository
    private let stateRepository: FileRotationStateRepository
    private let library: QuoteLibrary
    private let signatureService: SignatureService
    private let rotationService: RotationService

    init() {
        UserDefaults.standard.register(defaults: [
            DefaultsKey.rotationEnabled: true,
            DefaultsKey.rotationInterval: RotationInterval.daily.rawValue,
            DefaultsKey.recentQuoteLimit: 10,
            DefaultsKey.preferSeasonalQuotes: true,
            DefaultsKey.hemisphere: Hemisphere.northern.rawValue
        ])

        storageDirectory = StorageDirectory.applicationSupport()
        do {
            try storageDirectory.createIfNeeded()
        } catch {
            statusMessage = "Couldn't create the data folder: \(error.localizedDescription)"
        }

        quoteRepository = FileQuoteRepository(fileURL: storageDirectory.file("quotes.json"))
        profileRepository = FileProfileRepository(fileURL: storageDirectory.file("profiles.json"))
        stateRepository = FileRotationStateRepository(fileURL: storageDirectory.file("rotation-state.json"))

        library = QuoteLibrary(repository: quoteRepository)
        signatureService = SignatureService(
            profileRepository: profileRepository,
            quoteRepository: quoteRepository,
            stateRepository: stateRepository
        )
        rotationService = RotationService(
            signatureService: signatureService,
            quoteRepository: quoteRepository,
            stateRepository: stateRepository,
            mailUpdater: NoMailUpdater()
        )

        seedDefaultQuotesIfFirstRun()
        createDefaultProfileIfFirstRun()
        reloadFromDisk()
        rotateIfDue()
    }

    var configuration: RotationConfiguration {
        let defaults = UserDefaults.standard
        let interval = RotationInterval(
            rawValue: defaults.string(forKey: DefaultsKey.rotationInterval) ?? ""
        ) ?? .daily

        return RotationConfiguration(
            isEnabled: defaults.bool(forKey: DefaultsKey.rotationEnabled),
            interval: interval,
            recentQuoteLimit: defaults.integer(forKey: DefaultsKey.recentQuoteLimit),
            preferSeasonalQuotes: defaults.bool(forKey: DefaultsKey.preferSeasonalQuotes),
            hemisphere: Hemisphere(
                rawValue: defaults.string(forKey: DefaultsKey.hemisphere) ?? ""
            ) ?? .northern
        )
    }

    /// Profiles rotation currently renders (enabled and configured).
    var activeProfiles: [SignatureProfile] {
        profiles.filter { $0.isEnabled && $0.isConfigured }
    }

    // MARK: - Rotation

    func rotateNow() {
        attemptRotation()
    }

    func rotateIfDue() {
        guard rotationService.isRotationDue(configuration: configuration) else { return }
        attemptRotation()
    }

    private func attemptRotation() {
        do {
            let result = try rotationService.rotate(configuration: configuration)
            currentQuote = result.quote
            statusMessage = nil
            reloadFromDisk()
        } catch {
            // The Signature tab's empty state already walks the user through
            // creating a profile; don't repeat it as an error banner.
            if (error as? ApplicationError) == .noProfilesConfigured {
                statusMessage = nil
            } else {
                statusMessage = error.localizedDescription
            }
        }
    }

    // MARK: - Signature helpers

    /// Copies one profile's signature to the clipboard, rotating first if no
    /// quote has been selected yet. Returns true when something was copied.
    @discardableResult
    func copySignature(profileID: UUID) -> Bool {
        if currentSignatures.isEmpty {
            attemptRotation()
        }
        guard let signature = currentSignatures.first(where: { $0.profileID == profileID }) else {
            return false
        }
        UIPasteboard.general.string = signature.text
        statusMessage = nil
        return true
    }

    // MARK: - Profiles

    func saveProfile(_ profile: SignatureProfile) {
        var updated = profiles
        if let index = updated.firstIndex(where: { $0.id == profile.id }) {
            updated[index] = profile
        } else {
            updated.append(profile)
        }
        persistProfiles(updated)
    }

    func deleteProfile(id: UUID) {
        persistProfiles(profiles.filter { $0.id != id })
    }

    /// Proposes a signature name not already used by another profile.
    func uniqueSignatureName() -> String {
        let existing = Set(profiles.map { $0.signatureName.lowercased() })
        if !existing.contains("dynamic quote") { return "Dynamic Quote" }
        var index = 2
        while existing.contains("dynamic quote \(index)") { index += 1 }
        return "Dynamic Quote \(index)"
    }

    private func persistProfiles(_ updated: [SignatureProfile]) {
        do {
            try profileRepository.saveAll(updated)
            profiles = updated
            statusMessage = nil
            if currentQuote == nil, !activeProfiles.isEmpty {
                // First-run flow: a usable profile was the missing piece, so
                // kick off the initial rotation instead of waiting.
                rotateIfDue()
            } else {
                reloadFromDisk()
            }
        } catch {
            statusMessage = "Couldn't save profiles: \(error.localizedDescription)"
        }
    }

    // MARK: - Quote library

    func addQuote(_ quote: Quote) {
        perform { try library.add(quote) }
    }

    func updateQuote(_ quote: Quote) {
        perform { try library.update(quote) }
    }

    func deleteQuotes(ids: Set<UUID>) {
        perform { try library.delete(ids: ids) }
    }

    func setQuoteEnabled(_ isEnabled: Bool, id: UUID) {
        perform { try library.setEnabled(isEnabled, id: id) }
    }

    func importQuotes(from data: Data) {
        perform {
            let added = try library.importQuotes(from: data)
            statusMessage = "Imported \(added) quote\(added == 1 ? "" : "s")."
        }
    }

    func reportImportFailure(_ error: Error) {
        statusMessage = "Couldn't import quotes: \(error.localizedDescription)"
    }

    func exportData() -> Data? {
        do {
            return try library.exportData()
        } catch {
            statusMessage = error.localizedDescription
            return nil
        }
    }

    private func perform(_ operation: () throws -> Void) {
        do {
            try operation()
            reloadFromDisk()
        } catch DomainError.emptyText {
            statusMessage = "Quote text can't be empty."
        } catch DomainError.invalidWeight {
            statusMessage = "Quote weight must be greater than zero."
        } catch {
            statusMessage = error.localizedDescription
        }
    }

    // MARK: - Loading

    private func seedDefaultQuotesIfFirstRun() {
        guard !quoteRepository.hasStoredData else { return }
        try? quoteRepository.saveAll(DefaultQuotes.all)
    }

    private func createDefaultProfileIfFirstRun() {
        // Reuses the migration helper: with no legacy identity file present it
        // simply creates an empty "Default" profile to fill in.
        try? ProfileMigration.migrateIfNeeded(
            profileRepository: profileRepository,
            legacyIdentityRepository: FileIdentityRepository(
                fileURL: storageDirectory.file("identity.json")
            ),
            legacySignatureName: "Dynamic Quote",
            legacyTemplate: SignatureTemplate()
        )
    }

    private func reloadFromDisk() {
        quotes = (try? library.allQuotes()) ?? []
        profiles = (try? profileRepository.loadAll()) ?? []
        currentSignatures = (try? signatureService.current())?.signatures ?? []

        if let state = try? stateRepository.load() {
            lastRotationDate = state.lastRotated
            if let id = state.currentQuoteID {
                currentQuote = quotes.first { $0.id == id }
            }
        }
    }
}
