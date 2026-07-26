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
        static let signatureName = "signatureName"
        static let recentQuoteLimit = "recentQuoteLimit"
        static let includeQuote = "includeQuote"
        static let includeContactDetails = "includeContactDetails"
    }

    @Published private(set) var quotes: [Quote] = []
    @Published private(set) var identity = Identity()
    @Published private(set) var currentQuote: Quote?
    @Published private(set) var lastSyncDate: Date?
    @Published private(set) var statusMessage: String?
    @Published private(set) var hasPendingSync = false

    let storageDirectory: StorageDirectory

    private let quoteRepository: FileQuoteRepository
    private let identityRepository: FileIdentityRepository
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
        identityRepository = FileIdentityRepository(fileURL: storageDirectory.file("identity.json"))
        stateRepository = FileRotationStateRepository(fileURL: storageDirectory.file("rotation-state.json"))

        library = QuoteLibrary(repository: quoteRepository)
        signatureService = SignatureService(
            identityRepository: identityRepository,
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
        let name = defaults.string(forKey: DefaultsKey.signatureName) ?? "Dynamic Quote"

        return RotationConfiguration(
            isEnabled: defaults.bool(forKey: DefaultsKey.rotationEnabled),
            interval: interval,
            signatureName: name.isEmpty ? "Dynamic Quote" : name,
            recentQuoteLimit: defaults.integer(forKey: DefaultsKey.recentQuoteLimit),
            template: SignatureTemplate(
                includeIdentity: true,
                includeContactDetails: defaults.bool(forKey: DefaultsKey.includeContactDetails),
                includeQuote: defaults.bool(forKey: DefaultsKey.includeQuote)
            )
        )
    }

    var isMailRunning: Bool {
        mailUpdater.isMailRunning
    }

    var currentSignatureText: String? {
        try? signatureService.current(configuration: configuration)?.text
    }

    // MARK: - Rotation

    func rotateNow() {
        attemptRotation(manual: true)
    }

    /// Pushes the current signature (or a first one) to Mail after identity
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

    func copyCurrentSignature() {
        do {
            if let current = try signatureService.current(configuration: configuration) {
                clipboard.copy(current.text)
                statusMessage = nil
            } else {
                let generated = try rotationService.rotate(configuration: configuration)
                currentQuote = generated.quote
                clipboard.copy(generated.text)
                markSynced()
                reloadFromDisk()
            }
        } catch {
            // Even if the Mail sync is blocked, still put a signature on the clipboard.
            if (error as? ApplicationError) == .mailNotRunning,
               let generated = try? signatureService.generate(configuration: configuration) {
                clipboard.copy(generated.text)
            }
            handleSyncFailure(error)
        }
    }

    // MARK: - Identity

    func saveIdentity(_ newIdentity: Identity) {
        do {
            try identityRepository.save(newIdentity)
            identity = newIdentity
            statusMessage = nil
            guard newIdentity.isConfigured else { return }
            if currentQuote != nil {
                resyncToMail()
            } else {
                // First-run flow: identity was the missing piece, so kick off
                // the initial rotation instead of waiting for the next tick.
                rotateIfDue()
            }
        } catch {
            statusMessage = "Couldn't save identity: \(error.localizedDescription)"
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
        identity = (try? identityRepository.load()) ?? Identity()

        if let state = try? stateRepository.load() {
            lastSyncDate = state.lastRotated
            if let id = state.currentQuoteID {
                currentQuote = quotes.first { $0.id == id }
            }
        }
    }
}
