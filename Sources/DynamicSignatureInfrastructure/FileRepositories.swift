import Foundation
import DynamicSignatureDomain
import DynamicSignatureApplication

public final class FileQuoteRepository: QuoteRepository {

    private let store: JSONFileStore

    public init(fileURL: URL) {
        self.store = JSONFileStore(fileURL: fileURL)
    }

    /// True once a quotes file has ever been written; used to distinguish
    /// "first run" from "user deleted every quote".
    public var hasStoredData: Bool {
        store.fileExists
    }

    public func loadAll() throws -> [Quote] {
        try store.load([Quote].self) ?? []
    }

    public func saveAll(_ quotes: [Quote]) throws {
        try store.save(quotes)
    }
}

public final class FileProfileRepository: ProfileRepository {

    private let store: JSONFileStore

    public init(fileURL: URL) {
        self.store = JSONFileStore(fileURL: fileURL)
    }

    public func loadAll() throws -> [SignatureProfile] {
        try store.load([SignatureProfile].self) ?? []
    }

    public func saveAll(_ profiles: [SignatureProfile]) throws {
        try store.save(profiles)
    }
}

/// Legacy single-identity file (identity.json); read once during migration.
public final class FileIdentityRepository: IdentityRepository {

    private let store: JSONFileStore

    public init(fileURL: URL) {
        self.store = JSONFileStore(fileURL: fileURL)
    }

    public func load() throws -> Identity? {
        try store.load(Identity.self)
    }

    public func save(_ identity: Identity) throws {
        try store.save(identity)
    }
}

public final class FileRotationStateRepository: RotationStateRepository {

    private let store: JSONFileStore

    public init(fileURL: URL) {
        self.store = JSONFileStore(fileURL: fileURL)
    }

    public func load() throws -> RotationState {
        try store.load(RotationState.self) ?? RotationState()
    }

    public func save(_ state: RotationState) throws {
        try store.save(state)
    }
}
