import Foundation
import DynamicSignatureDomain

public protocol QuoteRepository: AnyObject {
    func loadAll() throws -> [Quote]
    func saveAll(_ quotes: [Quote]) throws
}

public protocol IdentityRepository: AnyObject {
    func load() throws -> Identity?
    func save(_ identity: Identity) throws
}

public protocol RotationStateRepository: AnyObject {
    func load() throws -> RotationState
    func save(_ state: RotationState) throws
}
