import Foundation
import DynamicSignatureDomain

public protocol QuoteRepository: AnyObject {
    func loadAll() throws -> [Quote]
    func saveAll(_ quotes: [Quote]) throws
}

public protocol ProfileRepository: AnyObject {
    func loadAll() throws -> [SignatureProfile]
    func saveAll(_ profiles: [SignatureProfile]) throws
}

/// Legacy single-identity storage (pre-profiles). Kept only so existing
/// installs can be migrated into a default profile; see ProfileMigration.
public protocol IdentityRepository: AnyObject {
    func load() throws -> Identity?
    func save(_ identity: Identity) throws
}

public protocol RotationStateRepository: AnyObject {
    func load() throws -> RotationState
    func save(_ state: RotationState) throws
}
