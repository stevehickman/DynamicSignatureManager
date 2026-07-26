import AppKit
import Foundation
import SwiftUI
import UniformTypeIdentifiers
import DynamicSignatureDomain
import DynamicSignatureApplication
import DynamicSignatureInfrastructure
import DynamicSignatureMail

/// Wires storage, services, and Mail sync together and exposes observable
/// state to the SwiftUI views.
@MainActor
final class AppModel: ObservableObject {

    enum DefaultsKey {
        static let rotationEnabled = "rotationEnabled"
        static let rotationInterval = "rotationInterval"
        static let recentQuoteLimit = "recentQuoteLimit"
        static let preferSeasonalQuotes = "preferSeasonalQuotes"
        static let hemisphere = "hemisphere"
        // Legacy keys from the single-identity era; read once to migrate
        // their values into the default profile.
        static let signatureName = "signatureName"
        static let includeQuote = "includeQuote"
        static let includeContactDetails = "includeContactDetails"
    }

    @Published private(set) var quotes: [Quote] = []
    @Published private(set) var profiles: [SignatureProfile] = []
    @Published private(set) var currentQuote: Quote?
    @Published private(set) var lastSyncDate: Date?
    @Published private(set) var statusMessage: String?
    @Published private(set) var hasPendingSync = false

    let storageDirectory: StorageDirectory

    private let quoteRepository: FileQuoteRepository
    private let profileRepository: FileProfileRepository
    private let stateRepository: FileRotationStateRepository
    private let library: QuoteLibrary
    private let signatureService: SignatureService
    private let rotationService: RotationService
    private let mailUpdater: AppleScriptMailSignatureUpdater
    private let clipboard = ClipboardService()

    private var rotationTimer: Timer?
    private var mailLaunchObserver: NSObjectProtocol?

    init() {
        UserDefaults.standard.register(defaults: [
            DefaultsKey.rotationEnabled: true,
            DefaultsKey.rotationInterval: RotationInterval.daily.rawValue,
            DefaultsKey.signatureName: "Dynamic Quote",
            DefaultsKey.recentQuoteLimit: 10,
            DefaultsKey.preferSeasonalQuotes: true,
            DefaultsKey.hemisphere: Hemisphere.northern.rawValue,
            DefaultsKey.includeQuote: true,
            DefaultsKey.includeContactDetails: true
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
        mailUpdater = AppleScriptMailSignatureUpdater()
        rotationService = RotationService(
            signatureService: signatureService,
            quoteRepository: quoteRepository,
            stateRepository: stateRepository,
            mailUpdater: mailUpdater
        )

        seedDefaultQuotesIfFirstRun()
        migrateLegacyIdentityIfNeeded()
        reloadFromDisk()
        startRotationTimer()
        observeMailLaunches()
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

    var isMailRunning: Bool {
        mailUpdater.isMailRunning
    }

    /// Profiles rotation currently syncs (enabled and configured).
    var activeProfiles: [SignatureProfile] {
        profiles.filter { $0.isEnabled && $0.isConfigured }
    }

    // MARK: - Rotation

    func rotateNow() {
        attemptRotation(manual: true)
    }

    /// Pushes the current signatures (or first ones) to Mail after profile
    /// or template edits, without burning a new quote.
    func resyncToMail() {
        do {
            try rotationService.resync(configuration: configuration)
            markSynced()
        } catch {
            handleSyncFailure(error)
        }
    }

    private func rotateIfDue() {
        guard rotationService.isRotationDue(configuration: configuration) else { return }
        attemptRotation(manual: false)
    }

    private func attemptRotation(manual: Bool) {
        do {
            let result = try rotationService.rotate(configuration: configuration)
            currentQuote = result.quote
            markSynced()
            reloadFromDisk()
        } catch {
            if manual || (error as? ApplicationError) != .mailNotRunning {
                handleSyncFailure(error)
            } else {
                hasPendingSync = true
            }
        }
    }

    private func markSynced() {
        lastSyncDate = .now
        statusMessage = nil
        hasPendingSync = false
    }

    private func handleSyncFailure(_ error: Error) {
        if (error as? ApplicationError) == .mailNotRunning {
            hasPendingSync = true
        }
        statusMessage = error.localizedDescription
    }

    private func startRotationTimer() {
        rotationTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.rotateIfDue()
            }
        }
    }

    private func observeMailLaunches() {
        mailLaunchObserver = NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didLaunchApplicationNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication
            guard app?.bundleIdentifier == "com.apple.mail" else { return }
            Task { @MainActor in
                guard let self else { return }
                if self.hasPendingSync {
                    self.attemptRotation(manual: false)
                } else {
                    self.rotateIfDue()
                }
            }
        }
    }

    // MARK: - Signature helpers

    /// Copies one profile's signature to the clipboard, rotating first if no
    /// quote has been selected yet.
    func copySignature(profileID: UUID) {
        do {
            let batch: GeneratedSignatureBatch
            if let current = try signatureService.current() {
                batch = current
            } else {
                batch = try rotationService.rotate(configuration: configuration)
                currentQuote = batch.quote
                markSynced()
                reloadFromDisk()
            }
            if let signature = batch.signatures.first(where: { $0.profileID == profileID }) {
                clipboard.copy(signature.text)
                statusMessage = nil
            }
        } catch {
            // Even if the Mail sync is blocked, still put a signature on the clipboard.
            if (error as? ApplicationError) == .mailNotRunning,
               let batch = try? signatureService.generate(),
               let signature = batch.signatures.first(where: { $0.profileID == profileID }) {
                clipboard.copy(signature.text)
            }
            handleSyncFailure(error)
        }
    }

    // MARK: - Profiles

    func saveProfile(_ profile: SignatureProfile) {
        var updated = profiles
        if let index = updated.firstIndex(where: { $0.id == profile.id }) {
            updated[index] = profile
        } else {
            updated.append(profile)
        }
        persistProfiles(updated, syncAfter: profile.isEnabled && profile.isConfigured)
    }

    func deleteProfile(id: UUID) {
        persistProfiles(profiles.filter { $0.id != id }, syncAfter: false)
    }

    private func persistProfiles(_ updated: [SignatureProfile], syncAfter: Bool) {
        do {
            try profileRepository.saveAll(updated)
            profiles = updated
            statusMessage = nil
            guard syncAfter, !activeProfiles.isEmpty else { return }
            if currentQuote != nil {
                resyncToMail()
            } else {
                // First-run flow: a usable profile was the missing piece, so
                // kick off the initial rotation instead of waiting for the
                // next tick.
                rotateIfDue()
            }
        } catch {
            statusMessage = "Couldn't save profiles: \(error.localizedDescription)"
        }
    }

    private func migrateLegacyIdentityIfNeeded() {
        let defaults = UserDefaults.standard
        let legacyIdentityRepository = FileIdentityRepository(
            fileURL: storageDirectory.file("identity.json")
        )
        do {
            try ProfileMigration.migrateIfNeeded(
                profileRepository: profileRepository,
                legacyIdentityRepository: legacyIdentityRepository,
                legacySignatureName: defaults.string(forKey: DefaultsKey.signatureName) ?? "Dynamic Quote",
                legacyTemplate: SignatureTemplate(
                    includeIdentity: true,
                    includeContactDetails: defaults.bool(forKey: DefaultsKey.includeContactDetails),
                    includeQuote: defaults.bool(forKey: DefaultsKey.includeQuote)
                )
            )
        } catch {
            statusMessage = "Couldn't migrate identity to profiles: \(error.localizedDescription)"
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

    func importQuotes() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.json]
        panel.allowsMultipleSelection = false
        panel.message = "Choose a JSON file of quotes to import"
        guard panel.runModal() == .OK, let url = panel.url else { return }

        perform {
            let data = try Data(contentsOf: url)
            let added = try library.importQuotes(from: data)
            statusMessage = "Imported \(added) quote\(added == 1 ? "" : "s")."
        }
    }

    func exportQuotes() {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.json]
        panel.nameFieldStringValue = "quotes.json"
        panel.message = "Export the quote library as JSON"
        guard panel.runModal() == .OK, let url = panel.url else { return }

        perform {
            let data = try library.exportData()
            try data.write(to: url, options: .atomic)
            statusMessage = "Exported \(quotes.count) quote\(quotes.count == 1 ? "" : "s")."
        }
    }

    func revealDataFolder() {
        NSWorkspace.shared.activateFileViewerSelecting([storageDirectory.url])
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

    private func reloadFromDisk() {
        quotes = (try? library.allQuotes()) ?? []
        profiles = (try? profileRepository.loadAll()) ?? []

        if let state = try? stateRepository.load() {
            lastSyncDate = state.lastRotated
            if let id = state.currentQuoteID {
                currentQuote = quotes.first { $0.id == id }
            }
        }
    }
}
